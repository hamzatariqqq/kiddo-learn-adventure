import 'package:flutter/material.dart';

import '../features/splash/splash_screen.dart';
import 'theme/app_theme.dart';

class KiddoLearnApp extends StatelessWidget {
  const KiddoLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiddo Learn Adventure',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
