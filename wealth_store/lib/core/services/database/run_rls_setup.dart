import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Helper class to run RLS policy setup for tables
/// This should be run with admin privileges (service role)
class RLSSetup {
  final SupabaseClient _supabase;

  RLSSetup(this._supabase);

  Future<void> setupRLSPolicies() async {
    try {
      debugPrint('Setting up RLS policies...');
      
      // Load SQL from the file
      final String sqlScript = await rootBundle.loadString('lib/core/services/database/database_setup.sql');
      
      // Execute the SQL script
      // This needs to be run with admin/service role privileges
      await _supabase.rpc('run_sql_query', params: {
        'query': sqlScript
      });
      
      debugPrint('RLS policies set up successfully');
    } catch (e) {
      debugPrint('Error setting up RLS policies: $e');
      rethrow;
    }
  }

  /// Utility method to set up just the customers table RLS policies
  Future<void> setupCustomersRLS() async {
    try {
      debugPrint('Setting up customers RLS policies...');
      
      // SQL script for just the customers table
      final String sql = '''
      -- Enable Row Level Security
      ALTER TABLE IF EXISTS customers ENABLE ROW LEVEL SECURITY;

      -- Drop existing policies if any
      DROP POLICY IF EXISTS "Allow users to create their own customer record" ON customers;
      DROP POLICY IF EXISTS "Allow users to view their own customer record" ON customers;
      DROP POLICY IF EXISTS "Allow users to update their own customer record" ON customers;
      DROP POLICY IF EXISTS "Service role has full access to customers" ON customers;

      -- Create policy for inserting customer records during signup
      CREATE POLICY "Allow users to create their own customer record" 
      ON customers FOR INSERT 
      WITH CHECK (auth.uid() = id);

      -- Create policy for users to view their own record
      CREATE POLICY "Allow users to view their own customer record" 
      ON customers FOR SELECT 
      USING (auth.uid() = id);

      -- Create policy for users to update their own record
      CREATE POLICY "Allow users to update their own customer record" 
      ON customers FOR UPDATE 
      USING (auth.uid() = id);

      -- Allow service role full access
      CREATE POLICY "Service role has full access to customers" 
      ON customers 
      USING (auth.role() = 'service_role');
      ''';
      
      // Execute the SQL script
      await _supabase.rpc('run_sql_query', params: {
        'query': sql
      });
      
      debugPrint('Customers RLS policies set up successfully');
    } catch (e) {
      debugPrint('Error setting up customers RLS policies: $e');
      rethrow;
    }
  }
} 