USE FD_DWH;

-- Stored Procedure to Dimension DeliveryPartner
-- ----------------------------------------------


DELIMITER //

CREATE PROCEDURE FD_DWH.Load_DimDeliveryPartner()
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
            'DimDeliveryPartner',
            v_LoadStartTime,
            'FAILED',
            0,
            CONCAT('Error ', v_ErrorCode, ': ', v_ErrorMessage)
        );
    END;

    -- Capture Load Start

    SET v_LoadStartTime = NOW(6);

    -- Get Last Successful Load

    SELECT LastSuccessfulLoadTime
    INTO v_LastSuccessfulLoad
    FROM FD_DWH.ETL_Load_Control
    WHERE TableName = 'DimDeliveryPartner';

    IF v_LastSuccessfulLoad IS NULL THEN
        SET v_LastSuccessfulLoad = '1900-01-01';
    END IF;

    -- Extract Delta

    DROP TEMPORARY TABLE IF EXISTS tmp_partner_delta;

    CREATE TEMPORARY TABLE tmp_partner_delta AS
    SELECT *
    FROM fooddelivery.delivery_partner
    WHERE updated_at > v_LastSuccessfulLoad
      AND updated_at <= v_LoadStartTime;

    SELECT COUNT(*) INTO v_SourceCount
    FROM tmp_partner_delta;

    IF v_SourceCount = 0 THEN

        CALL FD_DWH.Update_ETL_Load_Control(
            'DimDeliveryPartner',
            v_LoadStartTime,
            'NO_DATA',
            0,
            NULL
        );

    ELSE

        START TRANSACTION;

        -- Update Existing (Type 1 Overwrite)

        UPDATE FD_DWH.DimDeliveryPartner d
        JOIN tmp_partner_delta t
            ON d.PartnerID = t.partner_id
        SET d.PartnerName = t.partner_name
        WHERE d.PartnerName <> t.partner_name;

        -- Insert New

        INSERT INTO FD_DWH.DimDeliveryPartner
        (
            PartnerID,
            PartnerName
        )
        SELECT
            t.partner_id,
            t.partner_name
        FROM tmp_partner_delta t
        LEFT JOIN FD_DWH.DimDeliveryPartner d
            ON t.partner_id = d.PartnerID
        WHERE d.PartnerID IS NULL;
        
        COMMIT;

        CALL FD_DWH.Update_ETL_Load_Control(
            'DimDeliveryPartner',
            v_LoadStartTime,
            'SUCCESS',
            v_SourceCount,
            NULL
        );

    END IF;

END //

DELIMITER ;


-- Test the stored procedure

SELECT * FROM fooddelivery.delivery_partner;

SELECT * FROM FD_DWH.DimDeliveryPartner;


CAll FD_DWH.Load_DimDeliveryPartner();

SELECT * FROM FD_DWH.etl_load_control
WHERE TableName = 'DimDeliveryPartner';


SELECT * FROM FD_DWH.DimDeliveryPartner;


INSERT INTO fooddelivery.delivery_partner (partner_name)
VALUES 
('Lucky Kumar'), 
('Anil Yadva');


UPDATE fooddelivery.delivery_partner
SET partner_name = 'Amit Sharma'
Where partner_id = 3;


CAll FD_DWH.Load_DimDeliveryPartner();


SELECT * FROM FD_DWH.etl_load_control
WHERE TableName = 'DimDeliveryPartner';


SELECT * FROM FD_DWH.DimDeliveryPartner