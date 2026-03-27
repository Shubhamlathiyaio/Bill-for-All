class SupabaseConstants {

  // Supabase
  static const String supabaseUrl = 'https://gtynfqsgpvwyhbcljtlh.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd0eW5mcXNncHZ3eWhiY2xqdGxoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM5OTgzMTQsImV4cCI6MjA4OTU3NDMxNH0.f9gMsILnvOy63NV4mOoqKQ8o9WNStj26ip31OsazWH8';

  // Edge Functions
  static const String onSignup = 'on-signup';
  static const String checkWorkspace = 'check-workspace';
  static const String getQueue = 'get-queue';
  static const String provisionWorkspace = 'provision-workspace';
  static const String submitModules = 'submit-modules';

  // SharedPreferences Keys
  static const String tenantSupabaseUrlKey = 'tenant_supabase_url';
  static const String tenantAnonKeyKey = 'tenant_anon_key';
  static const String languageCodeKey = 'language_code';

  // RPC Functions
  static const String getMyWorkspace = 'get_my_workspace';
}
