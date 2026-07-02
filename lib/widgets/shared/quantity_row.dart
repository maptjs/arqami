import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// عرض كمية كصف/شبكة من أيقونات متكررة (دوائر افتراضياً) — بديل بصري
/// للأرقام بدون الحاجة لأي صورة خارجية. تُستخدم فنشاط "مطابقة رقم↔كمية"
/// ووحدة "العد".
class QuantityRow extends StatelessWidget {
  final int count;
  final IconData icon;
  final Color color;
  final double iconSize;

  const QuantityRow({
    super.key,
    required this.count,
    this.icon = Icons.circle,
    this.color = AppColors.gold,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 3,
      runSpacing: 3,
      alignment: WrapAlignment.center,
      children: List.generate(
        count,
        (_) => Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}
