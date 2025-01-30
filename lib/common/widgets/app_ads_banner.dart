import 'package:easy_signature/common/widgets/app_text.dart';
import 'package:easy_signature/core/enums/app_localized_keys.dart';
import 'package:easy_signature/features/ads/app_ads_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppAdsBanner extends StatefulWidget {
  const AppAdsBanner({
    required this.adUnitId,
    this.adSize = AppBannerAdSize.normal,
    super.key,
  });

  final String adUnitId;
  final AppBannerAdSize adSize;

  @override
  State<AppAdsBanner> createState() => _AppAdsBannerState();
}

class _AppAdsBannerState extends State<AppAdsBanner> {
  BannerAd? bannerAd;
  bool bannerAdIsLoaded = false;
  bool hasError = false;

  Widget backgroundSizedBox(Widget child) {
    return SizedBox(
      width: double.maxFinite,
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(child: child),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    bannerAd?.dispose();

    bannerAd = BannerAd(
      size: widget.adSize.toAdSize(),
      adUnitId: widget.adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            bannerAdIsLoaded = true;
            hasError = false;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          setState(() {
            bannerAdIsLoaded = false;
            hasError = true;
          });
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return backgroundSizedBox(
        const AppText(AppLocalizedKeys.adsLoadFailed),
      );
    } else if (!bannerAdIsLoaded || bannerAd == null) {
      return backgroundSizedBox(
        const CircularProgressIndicator(),
      );
    }

    return SizedBox(
      width: bannerAd!.size.width.truncateToDouble(),
      height: bannerAd!.size.height.truncateToDouble(),
      child: AdWidget(
        ad: bannerAd!,
      ),
    );
  }
}
