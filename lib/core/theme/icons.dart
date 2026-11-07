import 'package:flutter/material.dart';

@immutable
class AppIcons extends ThemeExtension<AppIcons> {
  const AppIcons({
    required this.style,
    required this.menu,
    required this.search,
    required this.create,
    required this.add,
    required this.playArrow,
    required this.edit,
    required this.delete,
    required this.save,
    required this.image,
    required this.photoCamera,
    required this.photoLibrary,
  });

  final IconData style,
      menu,
      search,
      create,
      add,
      playArrow,
      edit,
      delete,
      save,
      image,
      photoCamera,
      photoLibrary;

  static const rounded = AppIcons(
    style: Icons.style_rounded,
    menu: Icons.menu_rounded,
    search: Icons.search_rounded,
    create: Icons.create_rounded,
    add: Icons.add_rounded,
    playArrow: Icons.play_arrow_rounded,
    edit: Icons.edit_rounded,
    delete: Icons.delete_rounded,
    save: Icons.save_rounded,
    image: Icons.image_rounded,
    photoCamera: Icons.photo_camera_rounded,
    photoLibrary: Icons.photo_library_rounded,
  );

  static const outlined = AppIcons(
    style: Icons.style_outlined,
    menu: Icons.menu,
    search: Icons.search,
    create: Icons.create_outlined,
    add: Icons.add,
    playArrow: Icons.play_arrow_outlined,
    edit: Icons.edit_outlined,
    delete: Icons.delete_outline,
    save: Icons.save_outlined,
    image: Icons.image_outlined,
    photoCamera: Icons.photo_camera_outlined,
    photoLibrary: Icons.photo_library_outlined,
  );

  @override
  AppIcons copyWith() => this;

  @override
  AppIcons lerp(AppIcons? other, double t) => t < 0.5 ? this : other ?? this;
}
