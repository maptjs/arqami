# أرقامي (Arqami)

تطبيق تعليمي بـ Flutter لتعلم الأرقام العربية للأطفال (4-6 سنوات) — الجزء الثاني من سلسلة تطبيقات تعليمية بعد **وقتي (Waqti)**.

## المميزات

- 13 وحدة تعليمية متدرجة: تتبّع الأرقام، العد، المطابقة، المقارنة البصرية، واستكشاف الأرقام في الحياة اليومية (ساعة، هاتف، لوحة سيارة)
- بدون أي صورة أو ملف صوتي خارجي: كل الرسومات مبنية بـ `CustomPainter`/أيقونات Material، وكل الأصوات عبر Text-to-Speech حي (`flutter_tts`)
- حفظ تقدم الطفل محلياً عبر Hive (بدون إنترنت)
- واجهة كاملة RTL بالعربية الفصحى

## البنية

```
lib/
├── core/
│   ├── audio/        # AudioService — نطق الأرقام + تغذية راجعة (TTS + SystemSound)
│   ├── progress/      # ProgressTracker — حفظ التقدم عبر Hive
│   └── theme/         # لوحة ألوان مغربية موحّدة
├── models/
│   ├── number_path.dart   # مسارات تتبّع الأرقام 0-9
│   ├── unit_model.dart    # نموذج الوحدة والأنشطة
│   └── units_data.dart    # محتوى الـ13 وحدة
├── screens/
│   ├── units_map_screen.dart   # خريطة الوحدات الرئيسية
│   └── unit_player_screen.dart # محرك تشغيل أي وحدة
├── widgets/
│   ├── games/    # TraceWidget, MatchingWidget, DragCountWidget,
│   │              # ComparisonWidget, SceneExploreWidget
│   └── shared/   # NumberDisplay, QuantityRow
└── main.dart
```

## التشغيل

```bash
flutter pub get
flutter run
```

## ⚠️ ملاحظات مهمة قبل الإنتاج

1. **مسارات الأرقام** (`lib/models/number_path.dart`): إحداثيات تقريبية، تحتاج ضبط بصري دقيق (افتح كل رقم على الشاشة وعدّل النقاط حتى يطابق الشكل الفعلي).
2. **TypeId في Hive** (`lib/core/progress/unit_progress.dart`): معرّف كـ `10` لتفادي التعارض مع مشاريع أخرى فنفس الجهاز (مثل وقتي). تأكد من عدم التعارض قبل الدمج.
3. **flutter_tts**: يعتمد على محرك TTS العربي المثبت على الجهاز. جرّب على أجهزة Android متوسطة الفئة شائعة فالمغرب للتأكد من وضوح النطق.
4. **الخط**: `main.dart` يفترض خط `Cairo` — بدّله إذا كنت تستعمل خطاً آخر (زد الملفات فـ `pubspec.yaml` تحت `fonts`).
5. **AdMob**: غير مدمج بعد (معلّق كـ comment فـ `pubspec.yaml`).

## الحالة

13/13 وحدة قابلة للعب فعلياً. المشروع الثاني من سلسلة "أطفالي" التعليمية بعد وقتي.
