import 'package:flutter/material.dart';

@immutable
class AppIcons extends ThemeExtension<AppIcons> {
  const AppIcons({
    required this.add,
    required this.arrowBack,
    required this.arrowForward,
    required this.brokenImage,
    required this.create,
    required this.delete,
    required this.dragHandle,
    required this.edit,
    required this.image,
    required this.menu,
    required this.moreVert,
    required this.photoCamera,
    required this.photoLibrary,
    required this.playArrow,
    required this.save,
    required this.search,
    required this.style,
    required this.swapHoriz,
    required this.warning,
    required this.palette,
  });

  final IconData add,
      arrowBack,
      arrowForward,
      brokenImage,
      create,
      delete,
      dragHandle,
      edit,
      image,
      menu,
      moreVert,
      palette,
      photoCamera,
      photoLibrary,
      playArrow,
      save,
      search,
      style,
      swapHoriz,
      warning;

  static const rounded = AppIcons(
    add: Icons.add_rounded,
    arrowBack: Icons.arrow_back_rounded,
    arrowForward: Icons.arrow_forward_rounded,
    brokenImage: Icons.broken_image_rounded,
    create: Icons.create_rounded,
    delete: Icons.delete_rounded,
    dragHandle: Icons.drag_handle_rounded,
    edit: Icons.edit_rounded,
    image: Icons.image_rounded,
    menu: Icons.menu_rounded,
    moreVert: Icons.more_vert_rounded,
    palette: Icons.palette_rounded,
    photoCamera: Icons.photo_camera_rounded,
    photoLibrary: Icons.photo_library_rounded,
    playArrow: Icons.play_arrow_rounded,
    save: Icons.save_rounded,
    search: Icons.search_rounded,
    style: Icons.style_rounded,
    swapHoriz: Icons.swap_horiz_rounded,
    warning: Icons.warning_rounded,
  );

  static const outlined = AppIcons(
    add: Icons.add,
    arrowBack: Icons.arrow_back_outlined,
    arrowForward: Icons.arrow_forward_outlined,
    brokenImage: Icons.broken_image_outlined,
    create: Icons.create_outlined,
    delete: Icons.delete_outline,
    dragHandle: Icons.drag_handle_outlined,
    edit: Icons.edit_outlined,
    image: Icons.image_outlined,
    menu: Icons.menu,
    moreVert: Icons.more_vert_outlined,
    palette: Icons.palette_outlined,
    photoCamera: Icons.photo_camera_outlined,
    photoLibrary: Icons.photo_library_outlined,
    playArrow: Icons.play_arrow_outlined,
    save: Icons.save_outlined,
    search: Icons.search,
    style: Icons.style_outlined,
    swapHoriz: Icons.swap_horiz_outlined,
    warning: Icons.warning_outlined,
  );

  @override
  AppIcons copyWith() => this;

  @override
  AppIcons lerp(AppIcons? other, double t) => t < 0.5 ? this : other ?? this;
}
