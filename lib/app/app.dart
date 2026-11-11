import 'package:flas_/core/theme/app_theme.dart';
import 'package:flas_/core/theme/motion.dart';
import 'package:flas_/core/theme/typography.dart';
import 'package:flas_/features/appearance/providers.dart';
import 'package:flas_/features/sync/providers.dart';
import 'package:flas_/shell/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    ref.read(syncServiceProvider).sync();
  }

  @override
  Widget build(BuildContext context) {
    final appearance = ref.watch(appearanceProvder);
    final fontFamily = AppFonts.byId(appearance.fontId).family;
    final icons = appearance.iconSet.icons;
    final motion = AppMotion(scale: appearance.motion.scale);

    return MaterialApp(
      theme: AppTheme.build(
        brightness: .light,
        fontFamily: fontFamily,
        icons: icons,
        motion: motion,
      ),
      darkTheme: AppTheme.build(
        brightness: .dark,
        fontFamily: fontFamily,
        icons: icons,
        motion: motion,
      ),
      themeMode: appearance.themeMode,
      themeAnimationDuration: motion.normal,
      home: const MainShell(),
    );
  }
}
