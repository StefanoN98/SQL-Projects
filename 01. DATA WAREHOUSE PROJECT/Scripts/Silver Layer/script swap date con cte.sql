WITH CTE AS (
    SELECT 
        id,
        data_inizio,
        data_fine,
        CASE WHEN data_inizio > data_fine THEN data_fine ELSE data_inizio END AS nuova_data_inizio,
        CASE WHEN data_inizio > data_fine THEN data_inizio ELSE data_fine END AS nuova_data_fine
    FROM 
        TuaTabella
    WHERE 
        data_inizio > data_fine
)
UPDATE CTE
SET 
    data_inizio = nuova_data_inizio,
    data_fine = nuova_data_fine
