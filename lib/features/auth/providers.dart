import 'package:flas_/core/constants.dart';
import 'package:flas_/features/sync/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = NotifierProvider<AuthNotifier, Session?>(AuthNotifier.new);

class AuthNotifier extends Notifier<Session?> {
  @override
  Session? build() {
    final subscription = _auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      state = session;

      if (event.event == .signedIn && session != null) {
        await _adoptUser(session.user.id);
        ref.read(syncServiceProvider).sync();
      }
    });
    ref.onDispose(subscription.cancel);

    return _auth.currentSession;
  }

  // Returns `false` if email confirmation is required before a session starts.
  Future<bool> register(String email, String password) async {
    final res = await _auth.signUp(email: email.trim(), password: password);
    return res.session != null;
  }

  Future<void> signIn(String email, String password) =>
      _auth.signInWithPassword(email: email.trim(), password: password);

  Future<void> signOut() async {
    try {
      await _auth.signOut(scope: .local);
    } catch (_) {
      // Signing out locally must not fail, e.g. when offline.
    }
  }

  Future<void> verifyPassword(String password) async {
    final email = _auth.currentUser?.email;
    if (email == null) throw AuthException('Not signed in');
    await _auth.signInWithPassword(email: email, password: password);
  }

  // Returns `true` if the new address must be confirmed before it applies.
  Future<bool> changeEmail(String currentPassword, String newEmail) async {
    await verifyPassword(currentPassword);
    final res = await _auth.updateUser(UserAttributes(email: newEmail.trim()));
    return res.user?.newEmail != null;
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await verifyPassword(currentPassword);
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> deleteAccount() async {
    final token = _auth.currentSession?.accessToken;

    final res = await http.delete(
      Uri.parse('$apiBaseUrl/account'),
      headers: {'authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) {
      throw Exception('delete failed: ${res.statusCode}');
    }

    await signOut();
    await ref.read(syncLocalStoreProvider).wipe();
  }

  GoTrueClient get _auth => Supabase.instance.client.auth;

  // Local data belongs to one user, so it is wiped when a different user
  // signs in.
  Future<void> _adoptUser(String userId) async {
    final store = ref.read(syncLocalStoreProvider);
    final lastUserId = await store.lastUserId();
    if (lastUserId != null && lastUserId != userId) await store.wipe();
    await store.setLastUserId(userId);
  }
}
