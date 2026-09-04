-- SQLBook: Code
-- Load Data
-- -----------

USE FD_DWH;

-- Stored Procedure to Load Fact
-- ---------------------------------


DROP PROCEDURE IF EXISTS FD_DWH.Load_FactOrders;


DELIMITER //

CREATE PROCEDURE FD_DWH.Load_FactOrders()
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
            'FactOrders',
            v_LoadStartTime,
            'FAILED',
            0,
            CONCAT('Error ', v_ErrorCode, ': ', v_ErrorMessage)
        );
    END;

    -- Capture Load Start Time

    SET v_LoadStartTime = NOW(6);

    -- Get Last Successful Load

    SELECT LastSuccessfulLoadTime
    INTO v_LastSuccessfulLoad
    FROM FD_DWH.ETL_Load_Control
    WHERE TableName = 'FactOrders';

    IF v_LastSuccessfulLoad IS NULL THEN
        SET v_LastSuccessfulLoad = '1900-01-01';
    END IF;

    -- Extract Delta Orders

    DROP TEMPORARY TABLE IF EXISTS tmp_orders_delta;

    CREATE TEMPORARY TABLE tmp_orders_delta AS
    SELECT *
    FROM fooddelivery.orders
    WHERE updated_at > v_LastSuccessfulLoad
      AND updated_at <= v_LoadStartTime;
    --   AND order_status = 'Delivered';

    SELECT COUNT(*) INTO v_SourceCount
    FROM tmp_orders_delta;

    IF v_SourceCount = 0 THEN

        CALL FD_DWH.Update_ETL_Load_Control(
            'FactOrders',
            v_LoadStartTime,
            'NO_DATA',
            0,
            NULL
        );

    ELSE

        START TRANSACTION;

        -- Insert Fact Rows

        INSERT INTO FD_DWH.FactOrders
        (
            DateKey,
            CustomerKey,
            RestaurantKey,
            FoodKey,
            DeliveryPartnerKey,
            OrderID,
            Quantity,
            ItemPrice,
            OrderAmount,
            DiscountAmount,
            DeliveryFee,
            DeliveryMinutes
        )
        SELECT
            DATE_FORMAT(o.order_date, '%Y%m%d'),

            dc.CustomerKey,
            dr.RestaurantKey,
            df.FoodKey,
            dp.PartnerKey,

            o.order_id,
            od.quantity,
            od.price,
            od.quantity * od.price,
            o.discount,
            o.delivery_fee,
            TIMESTAMPDIFF(MINUTE, o.order_date, o.delivered_at)

        FROM tmp_orders_delta o
        JOIN fooddelivery.order_details od
            ON o.order_id = od.order_id
        -- Lookup Customer (Current Version)
        JOIN FD_DWH.DimCustomer dc
            ON o.customer_id = dc.CustomerID
           AND dc.IsCurrent = 'Y'
        -- Lookup Restaurant
        JOIN FD_DWH.DimRestaurant dr
            ON o.restaurant_id = dr.RestaurantID
        -- Lookup Food
        JOIN FD_DWH.DimFood df
            ON od.food_id = df.FoodID
        -- Lookup Delivery Partner
        JOIN FD_DWH.DimDeliveryPartner dp
            ON o.delivery_partner_id = dp.PartnerID;

        COMMIT;

        CALL FD_DWH.Update_ETL_Load_Control(
            'FactOrders',
            v_LoadStartTime,
            'SUCCESS',
            v_SourceCount,
            NULL
        );

    END IF;

END //

DELIMITER ;


-- -------------------------
 SELECT * FROM fooddelivery.orders;

SELECT COUNT(*)
FROM fooddelivery.order_details od
JOIN fooddelivery.food_items f
    ON od.food_id = f.food_id


-- DELETE FROM FD_DWH.FactOrders;
-- DELETE FROM FD_DWH.ETL_Load_Control
-- WHERE TableName = 'FactOrders';

SELECT * FROM FD_DWH.FactOrders;

CALL FD_DWH.Load_FactOrders();

SELECT * FROM fd_dwh.etl_load_control
WHERE TableName = 'FactOrders';


SELECT count(*) FROM FD_DWH.FactOrders;