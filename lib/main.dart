import 'package:flutter/material.dart';

import 'core/audio/audio_service.dart';
import 'core/progress/progress_tracker.dart';
import 'core/theme/app_colors.dart';
import 'screens/units_map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // لازم نهيّئو ProgressTracker قبل runApp باش Hive يكون جاهز
  // أي مكان فالتطبيق كيقرا/كيكتب التقدم
  await ProgressTracker.instance.init();
  await AudioService.instance.init();

  runApp(const ArqamiApp());
}

class ArqamiApp extends StatelessWidget {
  const ArqamiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أرقامي',
      debugShowCheckedModeBanner: false,
      // دعم الاتجاه من اليمين لليسار للعربية
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          primary: AppColors.teal,
          secondary: AppColors.gold,
          surface: AppColors.cardBackground,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
        ),
        fontFamily: 'Cairo', // افترضنا خط عربي شائع — عدّله حسب خط وقتي
      ),
      builder: (context, child) {
        // نفرض RTL على كامل التطبيق بغض النظر عن لغة الجهاز
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const UnitsMapScreen(),
    );
  }
}
