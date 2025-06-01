-- Utility: SQL Text Optimization Function
-- Filename: sql-text-optimizer.sql
-- Developer: Miguel Nischor <miguel@nischor.com.br>
-- Version 1.0

DELIMITER //

CREATE OR REPLACE FUNCTION optimize_sql_text(input_sql TEXT) 
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    optimized_sql TEXT;
BEGIN
    -- Start with the input SQL
    optimized_sql := TRIM(input_sql);
    
    -- Remove extra whitespace and normalize spacing
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\s+', ' ', 'g');
    
    -- Convert keywords to uppercase for normalization
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mselect\M', 'SELECT', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mfrom\M', 'FROM', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mwhere\M', 'WHERE', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\morder\s+by\M', 'ORDER BY', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mgroup\s+by\M', 'GROUP BY', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mhaving\M', 'HAVING', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mjoin\M', 'JOIN', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\minner\s+join\M', 'INNER JOIN', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mleft\s+join\M', 'LEFT JOIN', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mright\s+join\M', 'RIGHT JOIN', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mfull\s+join\M', 'FULL JOIN', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mand\M', 'AND', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mor\M', 'OR', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\min\M', 'IN', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mlike\M', 'LIKE', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\milike\M', 'ILIKE', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mlimit\M', 'LIMIT', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\moffset\M', 'OFFSET', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mdistinct\M', 'DISTINCT', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\munion\M', 'UNION', 'gi');
    optimized_sql := REGEXP_REPLACE(optimized_sql, '\mexists\M', 'EXISTS', 'gi');
    
    -- Add warning for SELECT *
    IF optimized_sql ~* '\mSELECT\s+\*\s+FROM\M' THEN
        optimized_sql := '/* WARNING: Consider replacing SELECT * with specific columns */' || E'\n' || optimized_sql;
    END IF;
    
    -- Add hint for WHERE clauses without potential index usage
    IF optimized_sql ~* '\mWHERE\M' AND NOT optimized_sql ~* '\mUSING\M' THEN
        optimized_sql := optimized_sql || E'\n/* HINT: Consider adding indexes on WHERE clause columns */';
    END IF;
    
    -- Suggest LIMIT for potentially large result sets
    IF optimized_sql ~* '\mSELECT\M' AND NOT optimized_sql ~* '\mLIMIT\M' AND NOT optimized_sql ~* '\mCOUNT\s*\(' THEN
        optimized_sql := optimized_sql || E'\n/* SUGGESTION: Consider adding LIMIT clause for large datasets */';
    END IF;
    
    -- Suggest using EXISTS instead of IN with subqueries
    IF optimized_sql ~* '\mIN\s*\(\s*SELECT\M' THEN
        optimized_sql := optimized_sql || E'\n/* OPTIMIZATION: Consider using EXISTS instead of IN with subqueries */';
    END IF;
    
    -- Warn about LIKE with leading wildcards
    IF optimized_sql ~* '\mLIKE\s+[''"]%' THEN
        optimized_sql := optimized_sql || E'\n/* WARNING: Leading wildcards in LIKE prevent index usage */';
    END IF;
    
    -- Suggest using ILIKE for case-insensitive searches in PostgreSQL
    IF optimized_sql ~* '\mLOWER\s*\([^)]+\)\s*LIKE\s*LOWER\s*\(' THEN
        optimized_sql := optimized_sql || E'\n/* POSTGRESQL TIP: Use ILIKE for case-insensitive searches */';
    END IF;
    
    -- Format with proper line breaks for readability
    optimized_sql := REPLACE(optimized_sql, ' FROM ', E'\nFROM ');
    optimized_sql := REPLACE(optimized_sql, ' WHERE ', E'\nWHERE ');
    optimized_sql := REPLACE(optimized_sql, ' ORDER BY ', E'\nORDER BY ');
    optimized_sql := REPLACE(optimized_sql, ' GROUP BY ', E'\nGROUP BY ');
    optimized_sql := REPLACE(optimized_sql, ' HAVING ', E'\nHAVING ');
    optimized_sql := REPLACE(optimized_sql, ' JOIN ', E'\nJOIN ');
    optimized_sql := REPLACE(optimized_sql, ' INNER JOIN ', E'\nINNER JOIN ');
    optimized_sql := REPLACE(optimized_sql, ' LEFT JOIN ', E'\nLEFT JOIN ');
    optimized_sql := REPLACE(optimized_sql, ' RIGHT JOIN ', E'\nRIGHT JOIN ');
    optimized_sql := REPLACE(optimized_sql, ' FULL JOIN ', E'\nFULL JOIN ');
    optimized_sql := REPLACE(optimized_sql, ' UNION ', E'\nUNION ');
    optimized_sql := REPLACE(optimized_sql, ' LIMIT ', E'\nLIMIT ');
    optimized_sql := REPLACE(optimized_sql, ' OFFSET ', E'\nOFFSET ');
    
    RETURN optimized_sql;
END;
$$;

-- Create a more advanced version with additional PostgreSQL-specific optimizations
CREATE OR REPLACE FUNCTION optimize_sql_text_advanced(input_sql TEXT) 
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    optimized_sql TEXT;
    suggestion_count INTEGER := 0;
BEGIN
    -- Start with basic optimization
    optimized_sql := optimize_sql_text(input_sql);
    
    -- PostgreSQL-specific optimizations
    
    -- Suggest using EXPLAIN ANALYZE
    optimized_sql := '/* Use EXPLAIN ANALYZE to check execution plan */' || E'\n' || optimized_sql;
    
    -- Check for potential improvements with CTEs
    IF optimized_sql ~* '\mSELECT.*FROM\s*\(\s*SELECT\M' THEN
        optimized_sql := optimized_sql || E'\n/* SUGGESTION: Consider using WITH (CTE) for better readability */';
        suggestion_count := suggestion_count + 1;
    END IF;
    
    -- Suggest using JSONB instead of JSON
    IF optimized_sql ~* '\mjson\M' AND NOT optimized_sql ~* '\mjsonb\M' THEN
        optimized_sql := optimized_sql || E'\n/* POSTGRESQL TIP: Consider using JSONB instead of JSON for better performance */';
        suggestion_count := suggestion_count + 1;
    END IF;
    
    -- Suggest using array operations
    IF optimized_sql ~* '\mIN\s*\([^)]*,[^)]*\)' THEN
        optimized_sql := optimized_sql || E'\n/* POSTGRESQL TIP: Consider using ANY(ARRAY[...]) for better performance with large IN lists */';
        suggestion_count := suggestion_count + 1;
    END IF;
    
    -- Suggest using window functions instead of subqueries
    IF optimized_sql ~* '\mSELECT.*\(\s*SELECT.*FROM.*WHERE.*=.*\)' THEN
        optimized_sql := optimized_sql || E'\n/* OPTIMIZATION: Consider using window functions instead of correlated subqueries */';
        suggestion_count := suggestion_count + 1;
    END IF;
    
    -- Add summary of suggestions
    IF suggestion_count > 0 THEN
        optimized_sql := optimized_sql || E'\n/* SUMMARY: ' || suggestion_count || ' optimization suggestions provided */';
    END IF;
    
    RETURN optimized_sql;
END;
$$;

-- Usage examples:
/*
SELECT optimize_sql_text('select * from users where name like "%john%"');

SELECT optimize_sql_text_advanced('
    select u.id, u.name, (select count(*) from orders o where o.user_id = u.id) as order_count 
    from users u 
    where u.status in (1,2,3,4,5,6,7,8,9,10)
');

-- Test with a complex query
SELECT optimize_sql_text_advanced('
    select * from users u 
    where u.email like "%@gmail.com" 
    and u.id in (select user_id from orders where total > 100)
    and lower(u.name) like lower("%john%")
');
*/
