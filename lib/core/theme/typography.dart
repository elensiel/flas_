class FontEntry {
  const FontEntry({required this.id, required this.label, this.family});

  final String id;
  final String label;
  final String? family;
}

class AppFonts {
  const AppFonts._();

  static const fredoka = FontEntry(
    id: 'fredoka',
    label: 'Fredoka',
    family: 'Fredoka',
  );
  static const system = FontEntry(id: 'system', label: 'System');

  static const all = [fredoka, system];

  static FontEntry byid(String id) =>
      all.firstWhere((f) => f.id == id, orElse: () => fredoka);
}
