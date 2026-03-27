class ModuleModel {
  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final String gradientStart;
  final String gradientEnd;
  final int displayOrder;
  final String? supabaseUrl;
  final String? anonKey;

  const ModuleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.gradientStart,
    required this.gradientEnd,
    required this.displayOrder,
    this.supabaseUrl,
    this.anonKey,
  });

  /// Returns true when this module has its own tenant Supabase project.
  bool get hasTenantCredentials =>
      supabaseUrl != null &&
      supabaseUrl!.isNotEmpty &&
      anonKey != null &&
      anonKey!.isNotEmpty;

  factory ModuleModel.fromJson(Map<String, dynamic> json) => ModuleModel(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        iconName: json['icon_name'] as String? ?? 'widgets_outlined',
        gradientStart: json['gradient_start'] as String? ?? '#6C63FF',
        gradientEnd: json['gradient_end'] as String? ?? '#9B59B6',
        displayOrder: json['display_order'] as int? ?? 0,
        supabaseUrl: json['supabase_url'] as String?,
        anonKey: json['anon_key'] as String?,
      );
}
