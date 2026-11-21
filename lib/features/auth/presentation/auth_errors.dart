import 'package:supabase_flutter/supabase_flutter.dart';

String authMessage(AuthException e) => switch (e.code) {
  'invalid_credentials' => 'Current password is incorrect',
  'same_password' => 'New password must be different',
  'over_request_rate_limit' ||
  'over_email_send_rate_limit' => 'Too many attempts. Try again later',
  _ => e.message,
};
