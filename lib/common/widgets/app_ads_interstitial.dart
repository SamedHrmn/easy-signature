import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppAdsInterstitial extends StatefulWidget {
  const AppAdsInterstitial({required this.adUnitId, super.key});

  final String adUnitId;

  @override
  State<AppAdsInterstitial> createState() => AppAdsInterstitialState();
}

class AppAdsInterstitialState extends State<AppAdsInterstitial> {
  InterstitialAd? interstitialAd;
  bool adLoaded = false;
  bool hasError = false;
  int numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  @override
  void initState() {
    super.initState();
    createInterstitialAd();
  }

  void showInterstitialAd() {
    if (interstitialAd == null) {
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        createInterstitialAd();
      },
    );
    interstitialAd!.show();
    interstitialAd = null;
  }

  void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          interstitialAd = ad;
          numInterstitialLoadAttempts = 0;
          interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          numInterstitialLoadAttempts += 1;
          interstitialAd = null;
          if (numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            createInterstitialAd();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
