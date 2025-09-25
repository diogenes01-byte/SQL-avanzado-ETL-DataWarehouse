-- Ejercicio 11: Generar repeated_phone_24H y cause_recall_phone_24H
WITH calls_with_dates AS (
  SELECT 
    calls_ivr_id,
    calls_phone_number,
    calls_start_date,
    LAG(calls_start_date) OVER (PARTITION BY calls_phone_number ORDER BY calls_start_date) AS previous_call,
    LEAD(calls_start_date) OVER (PARTITION BY calls_phone_number ORDER BY calls_start_date) AS next_call
  FROM `keepcoding.ivr_detail`
)
SELECT 
  calls_ivr_id,
  calls_phone_number,
  calls_start_date,
  CASE 
    WHEN previous_call IS NOT NULL 
     AND TIMESTAMP_DIFF(calls_start_date, previous_call, HOUR) <= 24 
    THEN 1 
    ELSE 0 
  END AS repeated_phone_24H,
  CASE 
    WHEN next_call IS NOT NULL 
     AND TIMESTAMP_DIFF(next_call, calls_start_date, HOUR) <= 24 
    THEN 1 
    ELSE 0 
  END AS cause_recall_phone_24H
FROM calls_with_dates
ORDER BY calls_phone_number, calls_start_date;