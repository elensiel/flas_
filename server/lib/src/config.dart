import 'dart:io';

class Config {
  const Config({
    required this.supabaseUrl,
    required this.supabaseKey,
    required this.port,
    required this.dbPath,
    required this.mediaPath,
  });

  final String supabaseUrl, supabaseKey, dbPath, mediaPath;
  final int port;

  factory Config.fromEnvironment() {
    final env = Platform.environment;
    final url = env['SUPABASE_URL'];
    final key = env['SUPABASE_PUBLISHABLE_KEY'];
    if (url == null || key == null) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are requried',
      );
    }

    return Config(
      supabaseUrl: url,
      supabaseKey: key,
      port: int.tryParse(env['PORT'] ?? '') ?? 8080,
      dbPath: env['DB_PATH'] ?? 'flas_server.db',
      mediaPath: env['MEDIA_DIR'] ?? 'media',
    );
  }
}
