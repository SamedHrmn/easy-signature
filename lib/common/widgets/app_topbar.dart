import 'package:flutter/material.dart';

class AppTopbar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopbar({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
