import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// عرض رقم بخط كبير وموحّد عبر كل التطبيق (يُستخدم كعنصر مطابقة
/// أو لعرض رقم في أي مكان). بدون أي صورة — نص فقط.
class NumberDisplay extends StatelessWidget {
  final int value;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  const NumberDisplay({
    super.key,
    required this.value,
    this.fontSize = 40,
    this.color = AppColors.textPrimary,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$value',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
