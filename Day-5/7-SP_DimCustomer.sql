-- Load Data
-- -----------

USE FD_DWH;

-- Stored Procedure to Dimension Customer for SCD Type 2
-- --------------------------------------------------------

DELIMITER //

CREATE PROCEDURE FD_DWH.Load_DimCustomer()
BEGIN

    DECLARE v_LastSuccessfulLoad DATETIME;
    DECLARE v_LoadStartTime DATETIME;
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
            'DimCustomer',
            v_LoadStartTime,
            'FAILED',
            0,
            CONCAT('Error ', v_ErrorCode, ': ', v_ErrorMessage)
        );
    END;
    
    SET v_LoadStartTime = NOW();

    -- Get Last Successful Load

    SELECT LastSuccessfulLoadTime
    INTO v_LastSuccessfulLoad
    FROM FD_DWH.ETL_Load_Control
    WHERE TableName = 'DimCustomer';

    IF v_LastSuccessfulLoad IS NULL THEN
        SET v_LastSuccessfulLoad = '1900-01-01';
    END IF;

    -- Create Delta Temp Table

    DROP TEMPORARY TABLE IF EXISTS tmp_customer_delta;

    CREATE TEMPORARY TABLE tmp_customer_delta AS
    SELECT *
    FROM fooddelivery.customers
    WHERE updated_at > v_LastSuccessfulLoad
      AND updated_at <= v_LoadStartTime;

    -- Count delta rows

    SELECT COUNT(*) INTO v_SourceCount
    FROM tmp_customer_delta;

    IF v_SourceCount = 0 THEN

        CALL FD_DWH.Update_ETL_Load_Control(
            'DimCustomer',
            v_LoadStartTime,
            'NO_DATA',
            0,
            NULL
        );

    ELSE

        START TRANSACTION;

        -- Step 1: Expire changed current records

        UPDATE FD_DWH.DimCustomer dc
        JOIN tmp_customer_delta t
            ON dc.CustomerID = t.customer_id
           AND dc.IsCurrent = 'Y'
        SET dc.EndDate = v_LoadStartTime,
            dc.IsCurrent = 'N'
        WHERE dc.Email <> t.email
           OR dc.CityID <> t.city_id
           OR dc.Name <> CONCAT(t.first_name,' ',t.last_name);

        -- Step 2: Insert new version (for new or changed)

        INSERT INTO FD_DWH.DimCustomer
        (
            CustomerID,
            Name,
            Email,
            CityID,
            StartDate,
            EndDate,
            IsCurrent
        )
        SELECT
            t.customer_id,
            CONCAT(t.first_name,' ',t.last_name),
            t.email,
            t.city_id,
            v_LoadStartTime,
            NULL,
            'Y'
        FROM tmp_customer_delta t
        LEFT JOIN FD_DWH.DimCustomer dc
            ON t.customer_id = dc.CustomerID
           AND dc.IsCurrent = 'Y'
        WHERE dc.CustomerID IS NULL
           OR dc.Email <> t.email
           OR dc.CityID <> t.city_id
           OR dc.Name <> CONCAT(t.first_name,' ',t.last_name);

        COMMIT;

        CALL FD_DWH.Update_ETL_Load_Control(
            'DimCustomer',
            v_LoadStartTime,
            'SUCCESS',
            v_SourceCount,
            NULL
        );

    END IF;

END //

DELIMITER ;


-- Test the procedure

SELECT * FROM fooddelivery.customers;

SELECT * FROM FD_DWH.DimCustomer;

CALL FD_DWH.Load_DimCustomer();


SELECT * FROM FD_DWH.etl_load_control
WHERE TableName = 'DimCustomer';


SELECT * FROM FD_DWH.DimCustomer;

UPDATE fooddelivery.customers
SET email = 'rahul.new@email.com'
WHERE customer_id = 1;

INSERT INTO fooddelivery.customers
(first_name, last_name, email, city_id)
VALUES ('Anjali', 'Verma', 'anjali.verma@rmail.com',3);


INSERT INTO fooddelivery.customers
(first_name, last_name, email, city_id)
VALUES ('Rajesh', 'Patil', 'rajesh.p@email.com', 11);

CALL FD_DWH.Load_DimCustomer();


SELECT * FROM FD_DWH.etl_load_control
WHERE TableName = 'DimCustomer';

SELECT * FROM FD_DWH.DimCustomer;