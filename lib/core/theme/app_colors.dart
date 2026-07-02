import 'package:flutter/material.dart';

/// لوحة ألوان مغربية موحّدة — نفس روح Tadbir.ma (teal/gold) مع
/// لمسة زليج. تُستعمل عبر كل شاشات ومكونات أرقامي بدل الألوان
/// المتفرقة، باش يبقى الشكل العام متماسك بصرياً.
class AppColors {
  AppColors._();

  // الألوان الأساسية
  static const Color teal = Color(0xFF00695C); // أخضر مغربي عميق (زليج)
  static const Color tealLight = Color(0xFF4DB6AC);
  static const Color gold = Color(0xFFD4A017); // ذهبي مغربي
  static const Color goldLight = Color(0xFFFFD54F);
  static const Color terracotta = Color(0xFFD2691E); // طين/فخار

  // خلفيات
  static const Color background = Color(0xFFFFF8E1); // كريمي دافئ
  static const Color cardBackground = Color(0xFFFFFFFF);

  // حالات الوحدات (خريطة الوحدات)
  static const Color locked = Color(0xFFBDBDBD);
  static const Color inProgress = gold;
  static const Color completed = teal;

  // تغذية راجعة
  static const Color correct = Color(0xFF2E7D32);
  static const Color incorrect = Color(0xFFD32F2F);

  // نصوص
  static const Color textPrimary = Color(0xFF3E2723); // بني داكن دافئ
  static const Color textSecondary = Color(0xFF6D4C41);

  /// مجموعة ألوان للعناصر القابلة للعد/المقارنة (تفاح، نجوم...) —
  /// نلوّنها بتدرج مغربي بدل الأحمر/الأزرق القياسي
  static const List<Color> itemPalette = [
    gold,
    teal,
    terracotta,
    tealLight,
    goldLight,
  ];

  static Color itemColorFor(int index) =>
      itemPalette[index % itemPalette.length];
}
