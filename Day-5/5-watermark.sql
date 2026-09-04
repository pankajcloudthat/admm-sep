-- Create ETL Control Table
-- ---------------------------
-- This table tracks last successful load per table.

USE FD_DWH;

DROP TABLE IF EXISTS ETL_Load_Control;

CREATE TABLE ETL_Load_Control (
    
    TableName VARCHAR(100) PRIMARY KEY,
    -- Load Window Tracking
    LoadStartTime DATETIME,
    LoadEndTime DATETIME,
    -- Last Successful Load Time (used for incremental filter)
    LastSuccessfulLoadTime DATETIME,
    -- Execution Details
    LastLoadStatus VARCHAR(20),      -- SUCCESS / FAILED / NO_DATA
    LastLoadRowCount INT DEFAULT 0,
    ErrorMessage TEXT,
    -- Duration (seconds)
    LoadDurationSeconds INT,
    -- Audit
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);



-- Initial Seed Records
-- ----------------------

INSERT INTO ETL_Load_Control (
    TableName,
    LastSuccessfulLoadTime,
    LastLoadStatus,
    LastLoadRowCount
)
VALUES
('DimCity', '1900-01-01', 'INIT', 0),
('DimFood', '1900-01-01', 'INIT', 0),
('DimRestaurant', '1900-01-01', 'INIT', 0),
('DimCustomer', '1900-01-01', 'INIT', 0),
('DimDeliveryPartner', '1900-01-01', 'INIT', 0),
('FactOrders', '1900-01-01', 'INIT', 0);



SELECT * FROM ETL_Load_Control;


-- Create Generic Update Procedure
-- ---------------------------------
DROP PROCEDURE IF EXISTS Update_ETL_Load_Control;


DELIMITER //

CREATE PROCEDURE Update_ETL_Load_Control (
    IN p_TableName VARCHAR(100),
    IN p_LoadStartTime DATETIME,
    IN p_Status VARCHAR(20),
    IN p_RowCount INT,
    IN p_ErrorMessage TEXT
)
BEGIN

    DECLARE v_LoadEndTime DATETIME;
    DECLARE v_Duration INT;
    -- Capture End Time
    SET v_LoadEndTime = NOW();
    -- Calculate Duration in Seconds
    SET v_Duration = TIMESTAMPDIFF(SECOND, p_LoadStartTime, v_LoadEndTime);
    -- Insert or Update Logic
    INSERT INTO ETL_Load_Control
    (
        TableName,
        LoadStartTime,
        LoadEndTime,
        LastSuccessfulLoadTime,
        LastLoadStatus,
        LastLoadRowCount,
        ErrorMessage,
        LoadDurationSeconds
    )
    VALUES
    (
        p_TableName,
        p_LoadStartTime,
        v_LoadEndTime,
        CASE WHEN p_Status = 'SUCCESS' 
             THEN p_LoadStartTime 
             ELSE NULL 
        END,
        p_Status,
        p_RowCount,
        p_ErrorMessage,
        v_Duration
    )
    ON DUPLICATE KEY UPDATE

        LoadStartTime = p_LoadStartTime,
        LoadEndTime = v_LoadEndTime,
        LastLoadStatus = p_Status,
        LastLoadRowCount = p_RowCount,
        ErrorMessage = p_ErrorMessage,
        LoadDurationSeconds = v_Duration,
        -- Update LastSuccessfulLoadTime ONLY if SUCCESS
        LastSuccessfulLoadTime =
            CASE
                WHEN p_Status = 'SUCCESS'
                THEN p_LoadStartTime
                ELSE LastSuccessfulLoadTime
            END;

END //

DELIMITER ;