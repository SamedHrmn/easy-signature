import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvManager {
  Future<void> initialize() async {
    const envFile = kReleaseMode ? '.env.production' : '.env.development';
    await dotenv.load(fileName: envFile);
  }

  String getString(AppEnvKey key) {
    if (!dotenv.isInitialized) {
      throw Exception('Must initialize before');
    }

    return dotenv.get(key.envName);
  }
}

enum AppEnvKey {
  adsBannerNormal('ADS_BANNER_NORMAL'),
  adsBannerLarge('ADS_BANNER_LARGE'),
  adsInterstitial('ADS_FULLSCREEN');

  const AppEnvKey(this.envName);
  final String envName;
}
