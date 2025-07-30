import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/services/database/database_initializer.dart';
import 'package:wealth_app/core/services/supabase_service.dart';

part 'database_provider.g.dart';

@riverpod
DatabaseInitializer databaseInitializer(DatabaseInitializerRef ref) {
  return DatabaseInitializer(ref.watch(supabaseProvider));
} 