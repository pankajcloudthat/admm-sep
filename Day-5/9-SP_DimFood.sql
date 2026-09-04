USE FD_DWH;

-- Stored Procedure to Dimension Food_Item
-- -----------------------------------------

DELIMITER //

CREATE PROCEDURE FD_DWH.Load_DimFood()
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
            'DimFood',
            v_LoadStartTime,
            'FAILED',
            0,
            CONCAT('Error ', v_ErrorCode, ': ', v_ErrorMessage)
        );
    END;

    -- Capture Load Start Time

    SET v_LoadStartTime = NOW(6);

    -- Get Last Successful Load Time

    SELECT LastSuccessfulLoadTime
    INTO v_LastSuccessfulLoad
    FROM FD_DWH.ETL_Load_Control
    WHERE TableName = 'DimFood';

    IF v_LastSuccessfulLoad IS NULL THEN
        SET v_LastSuccessfulLoad = '1900-01-01';
    END IF;

    -- Extract Delta

    DROP TEMPORARY TABLE IF EXISTS tmp_food_delta;

    CREATE TEMPORARY TABLE tmp_food_delta AS
    SELECT *
    FROM fooddelivery.food_items
    WHERE updated_at > v_LastSuccessfulLoad
      AND updated_at <= v_LoadStartTime;

    SELECT COUNT(*) INTO v_SourceCount
    FROM tmp_food_delta;

    IF v_SourceCount = 0 THEN

        CALL FD_DWH.Update_ETL_Load_Control(
            'DimFood',
            v_LoadStartTime,
            'NO_DATA',
            0,
            NULL
        );

    ELSE

        START TRANSACTION;

        -- Update Existing (Type 1 overwrite)

        UPDATE FD_DWH.DimFood d
        JOIN tmp_food_delta t
            ON d.FoodID = t.food_id
        SET d.FoodName = t.food_name,
            d.Category = t.category,
            d.RestaurantID = t.restaurant_id,
            d.CurrentPrice = t.price
        WHERE d.FoodName <> t.food_name
           OR d.Category <> t.category
           OR d.RestaurantID <> t.restaurant_id
           OR d.CurrentPrice <> t.price;
        
        -- Insert New

        INSERT INTO FD_DWH.DimFood
        (
            FoodID,
            FoodName,
            Category,
            RestaurantID,
            CurrentPrice
        )
        SELECT
            t.food_id,
            t.food_name,
            t.category,
            t.restaurant_id,
            t.price
        FROM tmp_food_delta t
        LEFT JOIN FD_DWH.DimFood d
            ON t.food_id = d.FoodID
        WHERE d.FoodID IS NULL;

        COMMIT;

        CALL FD_DWH.Update_ETL_Load_Control(
            'DimFood',
            v_LoadStartTime,
            'SUCCESS',
            v_SourceCount,
            NULL
        );

    END IF;

END //

DELIMITER ;


-- Test the stored procedure

SELECT * FROM fooddelivery.food_items;

SELECT * FROM FD_DWH.DimFood;


CALL FD_DWH.Load_DimFood();

SELECT * FROM FD_DWH.etl_load_control
WHERE TableName = 'DimFood';


SELECT * FROM FD_DWH.DimFood;


-- Add a new food item to source
INSERT INTO fooddelivery.food_items (food_name, category, price, restaurant_id)
VALUES ('Veggie Burger', 'Burger', 5.99, 7);


UPDATE fooddelivery.food_items
SET price = 20
WHERE food_name = 'Tandoori Roti';

CALL fd_dwh.Load_DimFood();


SELECT * FROM FD_DWH.etl_load_control
WHERE TableName = 'DimFood';

SELECT * FROM FD_DWH.DimFood
WHERE FoodName IN ('Veggie Burger', 'Tandoori Roti');