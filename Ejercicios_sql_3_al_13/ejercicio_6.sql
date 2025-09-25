-- Ejercicio 6: Generar el campo customer_phone
SELECT 
  calls_ivr_id,
  ARRAY_AGG(customer_phone IGNORE NULLS)[OFFSET(0)] AS customer_phone
FROM `keepcoding.ivr_detail`
WHERE customer_phone IS NOT NULL
GROUP BY calls_ivr_id
ORDER BY calls_ivr_id;