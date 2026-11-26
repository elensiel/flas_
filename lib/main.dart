import 'package:flas_/app.dart';
import 'package:flas_/core/database/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  runApp(const ProviderScope(child: MainApp()));
}
