import 'package:flas_/core/constants.dart';
import 'package:flas_/features/auth/data/auth_api.dart';
import 'package:flas_/features/auth/data/token_store.dart';
import 'package:flas_/features/sync/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenStoreProvider = Provider((_) => TokenStore());
final authApiProvider = Provider((_) => AuthApi(baseUrl: apiBaseUrl));

final initialTokenProvider = Provider<String?>(
  (_) => throw UnimplementedError(),
);

final authProvider = NotifierProvider<AuthNotifier, String?>(AuthNotifier.new);

class AuthNotifier extends Notifier<String?> {
  @override
  String? build() => ref.read(initialTokenProvider);

  Future<void> signIn(String email, String password) =>
      _start(ref.read(authApiProvider).login(email, password));

  Future<void> register(String email, String password) =>
      _start(ref.read(authApiProvider).login(email, password));

  Future<void> singOut() async {
    final token = state;
    if (token == null) return;

    await expire();
    try {
      await ref.read(authApiProvider).logout(token);
    } catch (_) {}
  }

  Future<void> expire() async {
    state = null;
    await ref.read(tokenStoreProvider).clear();
  }

  Future<void> _start(Future<String> req) async {
    final token = await req;
    await ref.read(tokenStoreProvider).write(token);
    state = token;
    ref.read(syncServiceProvider).sync();
  }
}
