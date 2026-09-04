SET SESSION cte_max_recursion_depth = 2000;

INSERT INTO FD_DWH.DimDate
(
    DateKey,
    FullDate,
    Day,
    Month,
    Year,
    Quarter,
    DayName
)
WITH RECURSIVE date_seq AS
(
    SELECT DATE('2025-01-01') AS dt
    UNION ALL
    SELECT dt + INTERVAL 1 DAY
    FROM date_seq
    WHERE dt < '2027-12-31'
)
SELECT
    DATE_FORMAT(dt, '%Y%m%d') AS DateKey,
    dt AS FullDate,
    DAY(dt),
    MONTH(dt),
    YEAR(dt),
    QUARTER(dt),
    DAYNAME(dt)
FROM date_seq;
