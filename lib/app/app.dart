import 'package:flas_/core/theme/app_theme.dart';
import 'package:flas_/shell/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: AppTheme.build(brightness: .light),
      darkTheme: AppTheme.build(brightness: .dark),
      themeMode: .system,
      home: const MainShell(),
    );
  }
}
