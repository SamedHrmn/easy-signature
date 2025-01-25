import 'package:easy_signature/core/constant/route_constant.dart';
import 'package:easy_signature/features/create_sign/create_sign_view.dart';
import 'package:easy_signature/features/load_files/load_file_view.dart';
import 'package:easy_signature/features/signing/sign_file_view.dart';
import 'package:easy_signature/main.dart';
import 'package:flutter/material.dart';

enum RouteEnum {
  initialView(RouteConstant.initialPath),
  loadFileView(RouteConstant.loadFileViewPath),
  signFileView(RouteConstant.signFileViewPath),
  createSignView(RouteConstant.createSignViewPath);

  static RouteEnum fromPath(String path) {
    for (final route in RouteEnum.values) {
      if (route.path == path) return route;
    }
    return RouteEnum.initialView;
  }

  MaterialPageRoute<dynamic> toMaterialRoute(RouteSettings settings) {
    switch (this) {
      case RouteEnum.initialView:
        return MaterialPageRoute(
          builder: (context) => const InitialView(),
          settings: settings,
        );
      case RouteEnum.loadFileView:
        return MaterialPageRoute(
          builder: (context) => const LoadFileView(),
          settings: settings,
        );
      case RouteEnum.signFileView:
        return MaterialPageRoute(
          builder: (context) => const SignFileView(),
          settings: settings,
        );
      case RouteEnum.createSignView:
        return MaterialPageRoute(
          builder: (context) => const CreateSignView(),
          settings: settings,
        );
    }
  }

  const RouteEnum(this.path);
  final String path;
}
