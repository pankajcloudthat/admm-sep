USE FD_DWH;

-- Stored Procedure to Dimension Restaurant
-- -----------------------------------------

DELIMITER //

CREATE PROCEDURE FD_DWH.Load_Restaurant()
BEGIN

    DECLARE v_LastSuccessfulLoad DATETIME(6);
    DECLARE v_LoadStartTime DATETIME(6);
    DECLARE v_SourceCount INT DEFAULT 0;

    DECLARE v_ErrorMessage TEXT;
    DECLARE v_SQLState CHAR(5);
    DECLARE v_ErrorCode INT;

    -- Error Handler

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_SQLState = RETURNED_SQLSTATE,
            v_ErrorCode = MYSQL_ERRNO,
            v_ErrorMessage = MESSAGE_TEXT;

        ROLLBACK;

        CALL FD_DWH.Update_ETL_Load_Control(
            'DimRestaurant',
            v_LoadStartTime,
            'FAILED',
            0,
            CONCAT('Error ', v_ErrorCode, ': ', v_ErrorMessage)
        );
    END;

    -- Capture load start

    SET v_LoadStartTime = NOW(6);

    -- Get last successful load

    SELECT LastSuccessfulLoadTime
    INTO v_LastSuccessfulLoad
    FROM FD_DWH.ETL_Load_Control
    WHERE TableName = 'DimRestaurant';

    IF v_LastSuccessfulLoad IS NULL THEN
        SET v_LastSuccessfulLoad = '1900-01-01';
    END IF;

    -- Extract Delta Rows

    DROP TEMPORARY TABLE IF EXISTS tmp_restaurant_delta;

    CREATE TEMPORARY TABLE tmp_restaurant_delta AS
    SELECT *
    FROM fooddelivery.restaurants
    WHERE updated_at > v_LastSuccessfulLoad
      AND updated_at <= v_LoadStartTime;

    SELECT COUNT(*) INTO v_SourceCount
    FROM tmp_restaurant_delta;

    IF v_SourceCount = 0 THEN

        CALL FD_DWH.Update_ETL_Load_Control(
            'DimRestaurant',
            v_LoadStartTime,
            'NO_DATA',
            0,
            NULL
        );

    ELSE

        START TRANSACTION;

        -- Update Existing (Type 1 Overwrite)

        UPDATE FD_DWH.DimRestaurant d
        JOIN tmp_restaurant_delta t
            ON d.RestaurantID = t.restaurant_id
        SET d.RestaurantName = t.restaurant_name,
            d.Category = t.category,
            d.CityID = t.city_id
        WHERE d.RestaurantName <> t.restaurant_name
           OR d.Category <> t.category
           OR d.CityID <> t.city_id;
        
        -- Insert New

        INSERT INTO FD_DWH.DimRestaurant
        (
            RestaurantID,
            RestaurantName,
            Category,
            CityID
        )
        SELECT
            t.restaurant_id,
            t.restaurant_name,
            t.category,
            t.city_id
        FROM tmp_restaurant_delta t
        LEFT JOIN FD_DWH.DimRestaurant d
            ON t.restaurant_id = d.RestaurantID
        WHERE d.RestaurantID IS NULL;

        COMMIT;

        CALL FD_DWH.Update_ETL_Load_Control(
            'DimRestaurant',
            v_LoadStartTime,
            'SUCCESS',
            v_SourceCount,
            NULL
        );

    END IF;

END //

DELIMITER ;



-- Test the Load_Restaurant procedure

SELECT * FROM fooddelivery.restaurants;

SELECT * FROM fd_dwh.DimRestaurant;

CALL fd_dwh.Load_Restaurant();


-- DELETE FROM FD_DWH.etl_load_control
-- WHERE TableName = 'DimRestaurant';

-- DELETE FROM FD_DWH.DimRestaurant;

SELECT * FROM FD_DWH.etl_load_control
WHERE TableName = 'DimRestaurant';

SELECT * FROM fd_dwh.DimRestaurant;

INSERT INTO fooddelivery.restaurants (restaurant_name, category, city_id)
VALUES
('Delhi Darbar', 'Premium Mughlai', 1);


UPDATE fooddelivery.restaurants
SET category = 'Cafe Coffee'
WHERE restaurant_name = 'Pune Cafe';

SELECT * FROM fooddelivery.restaurants;


CALL FD_DWH.Load_Restaurant();

SELECT * FROM FD_DWH.etl_load_control
WHERE TableName = 'DimRestaurant';

SELECT * FROM fd_dwh.DimRestaurant;