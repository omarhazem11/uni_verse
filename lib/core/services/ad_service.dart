import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Real AdMob unit IDs for both platforms.
/// Android app ID: ca-app-pub-2001624199855482~2888623418
/// iOS app ID:      ca-app-pub-2001624199855482~5466805433
class AdService {
  AdService._();

  static Future<void> initialize() => MobileAds.instance.initialize();

  static String get bannerAdUnitId => Platform.isIOS
      ? 'ca-app-pub-2001624199855482/6211689700'
      : 'ca-app-pub-2001624199855482/8148688959';

  static String get _interstitialAdUnitId => Platform.isIOS
      ? 'ca-app-pub-2001624199855482/7901397081'
      : 'ca-app-pub-2001624199855482/4195900458';

  static InterstitialAd? _interstitial;
  static bool _loadingInterstitial = false;
  static int _actionCount = 0;

  /// Show an interstitial roughly every Nth qualifying action instead of
  /// every single one — a "completed a task" or "closed a note" ad on
  /// literally every action would make the free tier unusable.
  static const _frequency = 4;

  static void preloadInterstitial() {
    if (_interstitial != null || _loadingInterstitial) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (_) {
          _interstitial = null;
          _loadingInterstitial = false;
        },
      ),
    );
  }

  /// Call after a qualifying free-tier action (task completed, note
  /// closed). No-ops entirely for Pro users. Skips the actual ad show on
  /// most calls, only surfacing one every [_frequency] actions.
  static void maybeShowInterstitial({required bool isPro}) {
    if (isPro) return;

    _actionCount++;
    if (_actionCount % _frequency != 0) {
      preloadInterstitial();
      return;
    }

    final ad = _interstitial;
    if (ad == null) {
      preloadInterstitial();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
    );
    _interstitial = null;
    ad.show();
  }
}
