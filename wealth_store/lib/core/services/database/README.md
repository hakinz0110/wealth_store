# Database Setup Guide

## RLS Policy Setup

The application uses Row-Level Security (RLS) policies in Supabase to protect your data. This README provides instructions for setting up the required SQL functions and policies.

## Required SQL Function

To enable the app to manage RLS policies, you need to create the following SQL function in your Supabase project:

1. Log in to your Supabase dashboard
2. Navigate to the SQL Editor
3. Create a new query and paste the following SQL:

```sql
-- SQL function to execute SQL queries with elevated privileges
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
```

4. Run the query to create the function

## How to Fix Row-Level Security (RLS) Errors

If you encounter errors like:

```
PostgrestException (message: new row violates row-level security policy for table "customers", code: 42501)
```

It means you need to set up proper RLS policies for the customers table. Follow these steps:

1. Log in to your Supabase dashboard
2. Navigate to the Database section
3. Find the "customers" table
4. Go to the "Policies" tab
5. Enable RLS if not already enabled
6. Add the following policies:

### For Sign-up/Create Customer

```sql
CREATE POLICY "Allow users to create their own customer record" 
ON customers FOR INSERT 
WITH CHECK (auth.uid() = id);
```

### For Viewing Customer Profile

```sql
CREATE POLICY "Allow users to view their own customer record" 
ON customers FOR SELECT 
USING (auth.uid() = id);
```

### For Updating Customer Profile

```sql
CREATE POLICY "Allow users to update their own customer record" 
ON customers FOR UPDATE 
USING (auth.uid() = id);
```

### For Service Role Access

```sql
CREATE POLICY "Service role has full access to customers" 
ON customers 
USING (auth.role() = 'service_role');
```

## Testing the Setup

After setting up the policies, try signing up again. The error should be resolved.

## Important Note

These policies are automatically applied when the app initializes the database, but they require the `run_sql_query` function to be created first. If you're experiencing RLS errors, it likely means this function is not yet created or doesn't have the right permissions. 