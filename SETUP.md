# كيفاش تحصل على مشروع Flutter كامل (android/ + ios/ + lib/)

هاد الأرشيف فيه فقط الكود المصدري (`lib/`) وملفات الإعداد
(`pubspec.yaml`, `README.md`, `.gitignore`, `analysis_options.yaml`,
`test/`). ما فيهوش `android/` و`ios/` لأن هاد المجلدات لازم تُولَّد
بنفس نسخة Flutter SDK المثبتة عندك بالضبط — توليدها يدوياً هنا كان
غادي يعطيك ملفات Gradle/Xcode متعارضة مع بيئتك.

## الخطوات (5 دقائق)

```bash
# 1. تأكد Flutter مثبت ومحدّث
flutter doctor

# 2. أنشئ مشروع Flutter فارغ بنفس الاسم
flutter create --org com.daryne.arqami arqami
cd arqami

# 3. احذف lib/ وpubspec.yaml الافتراضيين، عوّضهم بالمرفقين فهاد الأرشيف
rm -rf lib pubspec.yaml
cp -r /path/to/extracted/arqami/lib .
cp /path/to/extracted/arqami/pubspec.yaml .
cp /path/to/extracted/arqami/README.md .
cp /path/to/extracted/arqami/.gitignore .
cp /path/to/extracted/arqami/analysis_options.yaml .
cp -r /path/to/extracted/arqami/test .

# 4. جيب الاعتماديات
flutter pub get

# 5. جرب التشغيل
flutter run
```

بهاد الطريقة، `android/` و`ios/` كيكونو مولّدين بنفس نسخة Flutter SDK
عندك بالضبط — بلا أي تعارض فـ Gradle أو Xcode.

## بعد التشغيل الناجح

```bash
git init
git add .
git commit -m "أرقامي: النسخة الأولى - 13 وحدة كاملة"
git remote add origin https://github.com/USERNAME/arqami.git
git branch -M main
git push -u origin main
```

## نقاط تحتاج ضبط بعدين

راجع قسم "ملاحظات مهمة قبل الإنتاج" فـ README.md الرئيسي
(مسارات الأرقام، typeId ديال Hive، الخط، AdMob).
