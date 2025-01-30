import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppAdsManager {
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: ['2621974BED2946AACB8002CAA7E9E9DE'],
      ),
    );
  }

  Future<void> loadBannerAd({
    required String adUnitId,
    AppBannerAdSize? adSize,
    void Function(BannerAd ad)? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) async {
    late BannerAd bannerAd;

    bannerAd = BannerAd(
      size: adSize == null ? AppBannerAdSize.normal.toAdSize() : adSize.toAdSize(),
      adUnitId: adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) async {
          onAdLoaded?.call(bannerAd);
        },
        onAdFailedToLoad: onAdFailedToLoad,
      ),
      request: const AdRequest(),
    );

    await bannerAd.load();
  }
}

enum AppBannerAdSize {
  normal,
  large;

  const AppBannerAdSize();

  AdSize toAdSize() {
    switch (this) {
      case AppBannerAdSize.normal:
        return AdSize.banner;
      case AppBannerAdSize.large:
        return AdSize.largeBanner;
    }
  }
}
