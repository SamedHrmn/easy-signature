import 'package:easy_signature/core/widgets/global_loader_overlay.dart';
import 'package:flutter/material.dart';

class AppLoaderOverlay extends StatelessWidget {
  const AppLoaderOverlay({required this.loading, this.child, super.key});

  final bool loading;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderWidget(
      loading: loading,
      child: child,
    );
  }
}
