-- Create a function that allows executing arbitrary SQL
-- This should be executed in the Supabase SQL editor
-- Note: In a production environment, this function should have proper security checks

CREATE OR REPLACE FUNCTION run_sql(query text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  EXECUTE query;
END;
$$;

-- SQL function to execute SQL queries with elevated privileges
-- This function must be created with superuser privileges in the database
CREATE OR REPLACE FUNCTION run_sql_query(query text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  EXECUTE query;
END;
$$; 