import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_signature/common/helpers/app_asset_manager.dart';
import 'package:easy_signature/common/helpers/app_file_manager.dart';
import 'package:easy_signature/common/helpers/app_permission_manager.dart';
import 'package:easy_signature/core/enums/route_enum.dart';
import 'package:easy_signature/core/navigation/app_navigator.dart';
import 'package:easy_signature/core/util/app_sizer.dart';
import 'package:easy_signature/core/widgets/base_statefull_widget.dart';
import 'package:easy_signature/features/load_files/load_file_view_model.dart';
import 'package:easy_signature/features/signing/sign_file_view_model.dart';
import 'package:easy_signature/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();

  await EasyLocalization.ensureInitialized();

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => EasyLocalization(
        path: AppAssetManager.translationsPath,
        supportedLocales: const [
          Locale('en'),
          Locale('tr'),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoadFileViewModel(
            appPermissionManager: getIt<AppPermissionManager>(),
            appFileManager: getIt<AppFileManager>(),
          ),
        ),
        BlocProvider(
          create: (context) => SignFileViewModel(
            appFileManager: getIt<AppFileManager>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (settings) {
          switch (RouteEnum.fromPath(settings.name!)) {
            case RouteEnum.initialView:
              return RouteEnum.initialView.toMaterialRoute(settings);
            case RouteEnum.loadFileView:
              return RouteEnum.loadFileView.toMaterialRoute(settings);
            case RouteEnum.signFileView:
              return RouteEnum.signFileView.toMaterialRoute(settings);
            case RouteEnum.createSignView:
              return RouteEnum.createSignView.toMaterialRoute(settings);
          }
        },
        navigatorKey: getIt<AppNavigator>().navigatorKey,
        locale: context.locale,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        builder: DevicePreview.appBuilder,
        home: const InitialView(),
      ),
    );
  }
}

class InitialView extends StatefulWidget {
  const InitialView({super.key});

  @override
  State<InitialView> createState() => _InitialViewState();
}

class _InitialViewState extends BaseStatefullWidget<InitialView> {
  @override
  Future<void> onInitAsync() async {
    AppSizer.init(context, figmaWidth: 390, figmaHeight: 844);
    getIt<AppNavigator>().navigateTo(RouteEnum.loadFileView);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
