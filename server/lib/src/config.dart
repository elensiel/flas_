import 'dart:io';

class Config {
  const Config({
    required this.supabaseUrl,
    required this.supabaseKey,
    required this.supabaseSecretKey,
    required this.port,
    required this.dbPath,
    required this.mediaPath,
  });

  final String supabaseUrl, supabaseKey, supabaseSecretKey, dbPath, mediaPath;
  final int port;

  factory Config.fromEnvironment() {
    final env = Platform.environment;
    final url = env['SUPABASE_URL'];
    final key = env['SUPABASE_PUBLISHABLE_KEY'];
    final secretKey = env['SUPABASE_SECRET_KEY'];

    if (url == null) throw StateError('Missing SUPABASE_URL');
    if (key == null) throw StateError('Missing SUPABASE_PUBLISHABLE_KEY');
    if (secretKey == null) throw StateError('Missing SUPABASE_SECRET_KEY');

    return Config(
      supabaseUrl: url,
      supabaseKey: key,
      supabaseSecretKey: secretKey,
      port: int.tryParse(env['PORT'] ?? '') ?? 8080,
      dbPath: env['DB_PATH'] ?? 'flas_server.db',
      mediaPath: env['MEDIA_DIR'] ?? 'media',
    );
  }
}
