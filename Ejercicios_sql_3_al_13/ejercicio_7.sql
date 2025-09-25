-- Ejercicio 7: Generar el campo billing_account_id
SELECT 
  calls_ivr_id,
  ARRAY_AGG(billing_account_id IGNORE NULLS)[OFFSET(0)] AS billing_account_id
FROM `keepcoding.ivr_detail`
WHERE billing_account_id IS NOT NULL
GROUP BY calls_ivr_id
ORDER BY calls_ivr_id;