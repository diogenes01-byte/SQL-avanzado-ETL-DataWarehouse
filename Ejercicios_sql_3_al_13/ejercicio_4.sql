-- Ejercicio 4: Generar el campo vdn_aggregation
SELECT 
    calls_ivr_id,
    calls_vdn_label,
    CASE 
        WHEN calls_vdn_label LIKE 'ATC%' THEN 'FRONT'
        WHEN calls_vdn_label LIKE 'TECH%' THEN 'TECH'
        WHEN calls_vdn_label = 'ABSORPTION' THEN 'ABSORPTION'
        ELSE 'RESTO'
    END AS vdn_aggregation
FROM `keepcoding.ivr_detail`;