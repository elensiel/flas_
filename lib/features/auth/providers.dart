import 'package:flas_/features/sync/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

GoTrueClient get _auth => Supabase.instance.client.auth;

final authProvider = NotifierProvider<AuthNotifier, Session?>(AuthNotifier.new);

class AuthNotifier extends Notifier<Session?> {
  @override
  Session? build() {
    final sub = _auth.onAuthStateChange.listen((e) async {
      state = e.session;
      final session = e.session;
      if (e.event == .signedIn && session != null) {
        await _adopt(session.user.id);
        ref.read(syncServiceProvider).sync();
      }
    });
    ref.onDispose(sub.cancel);
    return _auth.currentSession;
  }

  Future<void> _adopt(String userId) async {
    final store = ref.read(syncLocalStoreProvider);
    final last = await store.lastUserId();
    if (last != null && last != userId) await store.wipe();
    await store.setLastUserId(userId);
  }

  Future<void> signIn(String email, String password) =>
      _auth.signInWithPassword(email: email.trim(), password: password);

  Future<bool> register(String email, String password) async {
    final res = await _auth.signUp(email: email.trim(), password: password);
    return res.session != null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut(scope: .local);
    } catch (_) {}
  }
}
