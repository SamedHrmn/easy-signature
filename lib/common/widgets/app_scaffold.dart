import 'package:easy_signature/common/widgets/app_topbar.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.topbarTitle, super.key, this.child});
  final Widget? child;
  final String topbarTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopbar(title: topbarTitle),
      body: SafeArea(child: child ?? const SizedBox.shrink()),
    );
  }
}
