-- Ejercicio 5: Generar los campos document_type y document_identification
SELECT 
  calls_ivr_id,
  ARRAY_AGG(document_type IGNORE NULLS)[OFFSET(0)] AS document_type,
  ARRAY_AGG(document_identification IGNORE NULLS)[OFFSET(0)] AS document_identification
FROM `keepcoding.ivr_detail`
WHERE document_type IS NOT NULL 
   OR document_identification IS NOT NULL
GROUP BY calls_ivr_id
ORDER BY calls_ivr_id;