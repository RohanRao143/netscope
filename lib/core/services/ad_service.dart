// lib/core/services/ad_service.dart

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String bannerTestAdUnitId =
      'ca-app-pub-3940256099942544/9214589741';

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static String get bannerAdUnitId => bannerTestAdUnitId;
}