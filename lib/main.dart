import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app/app.dart';
import 'core/services/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully.');
  } catch (error) {
    debugPrint('Firebase initialization error: $error');
  }

  // AdMob
  try {
    // Apply child-directed settings BEFORE initializing AdMob.
    await AdService.instance.configureForChildren();

    await MobileAds.instance.initialize();

    // Prepare a rewarded ad in advance.
    AdService.instance.loadRewarded();

    debugPrint('AdMob initialized successfully.');
  } catch (error) {
    debugPrint('AdMob initialization error: $error');
  }

  runApp(
    const ProviderScope(
      child: KiddoLearnApp(),
    ),
  );
}