import 'package:flas_/main_shell.dart';
import 'package:material_ui/material_ui.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainShell());
  }
}
