-- Ejercicio 12: Crear tabla ivr_summary
CREATE OR REPLACE TABLE `keepcoding.ivr_summary` AS
WITH phone_flags AS (
  -- Ejercicio 11: Repeated phone 24H flags
  SELECT 
    calls_ivr_id,
    CASE 
      WHEN LAG(calls_start_date) OVER (PARTITION BY calls_phone_number ORDER BY calls_start_date) IS NOT NULL 
       AND TIMESTAMP_DIFF(calls_start_date, LAG(calls_start_date) OVER (PARTITION BY calls_phone_number ORDER BY calls_start_date), HOUR) <= 24 
      THEN 1 
      ELSE 0 
    END AS repeated_phone_24H,
    CASE 
      WHEN LEAD(calls_start_date) OVER (PARTITION BY calls_phone_number ORDER BY calls_start_date) IS NOT NULL 
       AND TIMESTAMP_DIFF(LEAD(calls_start_date) OVER (PARTITION BY calls_phone_number ORDER BY calls_start_date), calls_start_date, HOUR) <= 24 
      THEN 1 
      ELSE 0 
    END AS cause_recall_phone_24H
  FROM `keepcoding.ivr_detail`
),
document_info AS (
  -- Ejercicio 5: Document type e identification
  SELECT 
    calls_ivr_id,
    ARRAY_AGG(document_type IGNORE NULLS)[OFFSET(0)] AS document_type,
    ARRAY_AGG(document_identification IGNORE NULLS)[OFFSET(0)] AS document_identification
  FROM `keepcoding.ivr_detail`
  WHERE document_type IS NOT NULL OR document_identification IS NOT NULL
  GROUP BY calls_ivr_id
),
customer_phone_info AS (
  -- Ejercicio 6: Customer phone
  SELECT 
    calls_ivr_id,
    ARRAY_AGG(customer_phone IGNORE NULLS)[OFFSET(0)] AS customer_phone
  FROM `keepcoding.ivr_detail`
  WHERE customer_phone IS NOT NULL
  GROUP BY calls_ivr_id
),
billing_info AS (
  -- Ejercicio 7: Billing account ID
  SELECT 
    calls_ivr_id,
    ARRAY_AGG(billing_account_id IGNORE NULLS)[OFFSET(0)] AS billing_account_id
  FROM `keepcoding.ivr_detail`
  WHERE billing_account_id IS NOT NULL
  GROUP BY calls_ivr_id
),
module_flags AS (
  -- Ejercicio 8: Masiva flag
  SELECT 
    calls_ivr_id,
    MAX(CASE WHEN module_name = 'AVERIA_MASIVA' THEN 1 ELSE 0 END) AS masiva_lg
  FROM `keepcoding.ivr_detail`
  GROUP BY calls_ivr_id
),
step_flags AS (
  -- Ejercicio 9 y 10: Info by phone and DNI flags
  SELECT 
    calls_ivr_id,
    MAX(CASE WHEN step_name = 'CUSTOMERINFOBYPHONE.TX' AND step_result = 'OK' THEN 1 ELSE 0 END) AS info_by_phone_lg,
    MAX(CASE WHEN step_name = 'CUSTOMERINFOBYDNI.TX' AND step_result = 'OK' THEN 1 ELSE 0 END) AS info_by_dni_lg
  FROM `keepcoding.ivr_detail`
  GROUP BY calls_ivr_id
),
distinct_calls AS (
  -- Campos básicos de ivr_detail (uno por llamada)
  SELECT DISTINCT
    calls_ivr_id AS ivr_id,
    calls_phone_number AS phone_number,
    calls_ivr_result AS ivr_result,
    CASE 
      WHEN calls_vdn_label LIKE 'ATC%' THEN 'FRONT'
      WHEN calls_vdn_label LIKE 'TECH%' THEN 'TECH'
      WHEN calls_vdn_label = 'ABSORPTION' THEN 'ABSORPTION'
      ELSE 'RESTO'
    END AS vdn_aggregation,
    calls_start_date AS start_date,
    calls_end_date AS end_date,
    calls_total_duration AS total_duration,
    calls_customer_segment AS customer_segment,
    calls_ivr_language AS ivr_language,
    calls_steps_module AS steps_module,
    calls_module_aggregation AS module_aggregation
  FROM `keepcoding.ivr_detail`
)
SELECT 
  dc.ivr_id,
  dc.phone_number,
  dc.ivr_result,
  dc.vdn_aggregation,
  dc.start_date,
  dc.end_date,
  dc.total_duration,
  dc.customer_segment,
  dc.ivr_language,
  dc.steps_module,
  dc.module_aggregation,
  COALESCE(di.document_type, NULL) AS document_type,
  COALESCE(di.document_identification, NULL) AS document_identification,
  COALESCE(cpi.customer_phone, NULL) AS customer_phone,
  COALESCE(bi.billing_account_id, NULL) AS billing_account_id,
  COALESCE(mf.masiva_lg, 0) AS masiva_lg,
  COALESCE(sf.info_by_phone_lg, 0) AS info_by_phone_lg,
  COALESCE(sf.info_by_dni_lg, 0) AS info_by_dni_lg,
  COALESCE(pf.repeated_phone_24H, 0) AS repeated_phone_24H,
  COALESCE(pf.cause_recall_phone_24H, 0) AS cause_recall_phone_24H
FROM distinct_calls dc
LEFT JOIN document_info di ON dc.ivr_id = di.calls_ivr_id
LEFT JOIN customer_phone_info cpi ON dc.ivr_id = cpi.calls_ivr_id
LEFT JOIN billing_info bi ON dc.ivr_id = bi.calls_ivr_id
LEFT JOIN module_flags mf ON dc.ivr_id = mf.calls_ivr_id
LEFT JOIN step_flags sf ON dc.ivr_id = sf.calls_ivr_id
LEFT JOIN phone_flags pf ON dc.ivr_id = pf.calls_ivr_id
ORDER BY dc.ivr_id;