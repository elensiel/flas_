import 'package:flas_/core/theme/typography.dart';
import 'package:flas_/features/appearance/domain/appearance_settings.dart';
import 'package:flas_/features/appearance/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appearanceProvder);
    final notifier = ref.read(appearanceProvder.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const .all(16),
        children: [
          _section(
            context,
            'Theme',
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: .system, label: Text('System')),
                ButtonSegment(value: .light, label: Text('Light')),
                ButtonSegment(value: .dark, label: Text('Dark')),
              ],
              selected: {current.themeMode},
              onSelectionChanged: (selected) => notifier.update(
                (settings) => settings.copyWith(themeMode: selected.first),
              ),
            ),
          ),
          _section(
            context,
            'Icons',
            SegmentedButton<AppIconSet>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: .rounded, label: Text('Rounded')),
                ButtonSegment(value: .outlined, label: Text('Outlined')),
              ],
              selected: {current.iconSet},
              onSelectionChanged: (selected) => notifier.update(
                (settings) => settings.copyWith(iconSet: selected.first),
              ),
            ),
          ),
          _section(
            context,
            'Font',
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                for (final f in AppFonts.all)
                  ButtonSegment(
                    value: f.id,
                    label: Text(
                      f.label,
                      style: TextStyle(
                        fontFamily:
                            f.family ??
                            (defaultTargetPlatform == .android
                                ? 'Roboto'
                                : '.SF Pro Text'),
                      ),
                    ),
                  ),
              ],
              selected: {current.fontId},
              onSelectionChanged: (selected) => notifier.update(
                (settings) => settings.copyWith(fontId: selected.first),
              ),
            ),
          ),
          _section(
            context,
            'Animation speed',
            SegmentedButton<MotionSpeed>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: .off, label: Text('Off')),
                ButtonSegment(value: .slow, label: Text('Slow')),
                ButtonSegment(value: .normal, label: Text('Normal')),
                ButtonSegment(value: .fast, label: Text('Fast')),
              ],
              selected: {current.motion},
              onSelectionChanged: (selected) => notifier.update(
                (settings) => settings.copyWith(motion: selected.first),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) => Padding(
    padding: const .only(bottom: 24),
    child: Column(
      crossAxisAlignment: .start,
      spacing: 8,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(width: .infinity, child: child),
      ],
    ),
  );
}
