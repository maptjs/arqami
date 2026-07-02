import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/main.dart';

/// ⚠️ ملاحظة: هذا اختبار أساسي (smoke test) كنقطة انطلاق فقط.
/// لتشغيله فعلياً، خاصك تهيّئ Hive (عبر hive_test أو path_provider mock)
/// وتموّه (mock) قنوات flutter_tts، لأن main() الحقيقي كيهيّئهم قبل
/// runApp() وواجهة الاختبار (WidgetTester) ما عندهاش وصول لقنوات
/// المنصة الحقيقية بشكل افتراضي.
void main() {
  testWidgets('التطبيق يقلع ويعرض خريطة الوحدات', (WidgetTester tester) async {
    await tester.pumpWidget(const ArqamiApp());
    await tester.pumpAndSettle();
    expect(find.text('أرقامي'), findsOneWidget);
  });
}
