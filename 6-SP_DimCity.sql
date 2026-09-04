-- SQLBook: Code

-- Stored Procedure — DimCity 
-- ----------------------------
USE FD_DWH;

DROP PROCEDURE IF EXISTS fd_dwh.Load_DimCity;


DELIMITER //

CREATE PROCEDURE fd_dwh.Load_DimCity()
BEGIN

    DECLARE v_LastSuccessfulLoad DATETIME;
    DECLARE v_LoadStartTime DATETIME;
    -- DECLARE v_RowCount INT DEFAULT 0;
    DECLARE v_HasData INT DEFAULT 0;

    DECLARE v_ErrorMessage TEXT;
    DECLARE v_SQLState CHAR(5);
    DECLARE v_ErrorCode INT;


    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        GET DIAGNOSTICS CONDITION 1
            v_SQLState = RETURNED_SQLSTATE,
            v_ErrorCode = MYSQL_ERRNO,
            v_ErrorMessage = MESSAGE_TEXT;

        ROLLBACK;

        CALL Update_ETL_Load_Control(
            'DimCity',
            v_LoadStartTime,
            'FAILED',
            0,
            CONCAT('Error ', v_ErrorCode, ': ', v_ErrorMessage)
        );
    END;
    
    SET v_LoadStartTime = NOW();
    
    SELECT LastSuccessfulLoadTime
    INTO v_LastSuccessfulLoad
    FROM fd_dwh.ETL_Load_Control
    WHERE TableName = 'DimCity';
    
    IF v_LastSuccessfulLoad IS NULL THEN
        SET v_LastSuccessfulLoad = '1900-01-01';
    END IF;

    DROP TEMPORARY TABLE IF EXISTS tmp_city_delta;

    CREATE TEMPORARY TABLE fd_dwh.tmp_city_delta AS
    SELECT *
    FROM fooddelivery.cities
    WHERE updated_at > v_LastSuccessfulLoad
      AND updated_at <= v_LoadStartTime;
   
    SELECT COUNT(*)
    INTO v_HasData
    FROM fd_dwh.tmp_city_delta;

    SELECT v_HasData as Count;
    
    IF v_HasData = 0 THEN

        CALL fd_dwh.Update_ETL_Load_Control(
            'DimCity',
            v_LoadStartTime,
            'NO_DATA',
            0,
            NULL
        );

    ELSE
        
        START TRANSACTION;
        
        UPDATE DimCity dc
        JOIN tmp_city_delta t ON dc.CityID = t.city_id
        SET dc.CityName = t.city_name,
            dc.State = t.state;

        -- SET v_RowCount = v_RowCount + ROW_COUNT();

        INSERT INTO DimCity (CityID, CityName, State)
        SELECT t.city_id, t.city_name, t.state
        FROM tmp_city_delta t
        LEFT JOIN DimCity dc ON t.city_id = dc.CityID
        WHERE dc.CityID IS NULL;

        -- SET v_RowCount = v_RowCount + ROW_COUNT();
        
        COMMIT;
        
        CALL Update_ETL_Load_Control(
            'DimCity',
            v_LoadStartTime,
            'SUCCESS',
            v_HasData,
            NULL
        );

    END IF;

END //

DELIMITER ;





-- Query cities table to verify data
SELECT * FROM fooddelivery.cities;


-- TRUNCATE TABLE fd_dwh.DimCity;
-- Query DimCity table
SELECT * FROM fd_dwh.DimCity;


-- Query ETL_Load_Control table for DimCity Load history
-- DELETE FROM fd_dwh.etl_load_control WHERE TableName = 'DimCity';
SELECT * FROM fd_dwh.etl_load_control
WHERE TableName = 'DimCity';


CALL fd_dwh.Load_DimCity();


-- Verify DimCity
SELECT * FROM fd_dwh.DimCity;




-- Simulate Updates for Incremental Testing
-- ------------------------------------------


UPDATE fooddelivery.cities
SET state = 'NCT'
WHERE city_name = 'Delhi';



-- Now updated_at will change for Delhi only.
SELECT * FROM fooddelivery.cities
WHERE city_name = 'Delhi';


-- Add a new city for Insert testing
-- DELETE FROM fooddelivery.cities WHERE city_name = 'Gurugram';
INSERT INTO fooddelivery.cities (city_name, state) 
VALUES ('Indore', 'Madhya Pradesh');
-- VALUES ('Gurugram', 'Haryana');


-- UPDATE fooddelivery.cities
-- SET state = 'MP'
-- WHERE city_name = 'Indore';


SELECT * FROM fooddelivery.cities;


-- Run the procedure again to capture updates and new inserts
CALL fd_dwh.Load_DimCity();



-- Verify DimCity after update and insert
SELECT * FROM fd_dwh.DimCity;


-- Check ETL Load Control for DimCity
SELECT * FROM fd_dwh.etl_load_control
WHERE TableName = 'DimCity';