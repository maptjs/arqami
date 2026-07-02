import 'package:hive_flutter/hive_flutter.dart';

import 'unit_progress.dart';

/// متتبع التقدم — Singleton فوق Hive Box مكتوب (typed) باستعمال
/// UnitProgressAdapter. أسرع وأكثر أماناً من النوع (type-safe) مقارنة
/// بتخزين Maps خام، ويستفيد من ميزات HiveObject مثل .save() المباشرة.
///
/// الاستخدام:
/// ```dart
/// // مرة واحدة عند إقلاع التطبيق (قبل runApp):
/// await ProgressTracker.instance.init();
///
/// // عند إكمال نشاط:
/// await ProgressTracker.instance.markUnitComplete('unit_01', stars: 3);
///
/// // للقراءة:
/// final progress = ProgressTracker.instance.getUnitProgress('unit_01');
/// ```
class ProgressTracker {
  ProgressTracker._internal();
  static final ProgressTracker instance = ProgressTracker._internal();

  static const String _boxName = 'arqami_progress';
  late Box<UnitProgress> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // نتفادى محاولة تسجيل نفس الـ adapter مرتين (مهم إذا init() اتنادات
    // أكثر من مرة بالخطأ، أو في hot restart أثناء التطوير)
    if (!Hive.isAdapterRegistered(UnitProgressAdapter().typeId)) {
      Hive.registerAdapter(UnitProgressAdapter());
    }

    _box = await Hive.openBox<UnitProgress>(_boxName);
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'ProgressTracker.init() لم يُستدعَ بعد. نادِ عليه في main() قبل runApp().',
      );
    }
  }

  /// يجلب تقدم وحدة معينة، أو قيمة افتراضية فارغة إذا لم تُلمس بعد
  UnitProgress getUnitProgress(String unitId) {
    _ensureInitialized();
    return _box.get(unitId) ?? UnitProgress(unitId: unitId);
  }

  /// يسجّل إكمال وحدة بعدد نجوم معين (يحافظ على أفضل نتيجة سابقة)
  Future<void> markUnitComplete(String unitId, {int stars = 1}) async {
    _ensureInitialized();
    final current = getUnitProgress(unitId);
    final updated = current.copyWith(
      completed: true,
      stars: stars > current.stars ? stars : current.stars,
      lastAttemptAt: DateTime.now(),
      attemptsCount: current.attemptsCount + 1,
    );
    await _box.put(unitId, updated);
  }

  /// يسجّل محاولة لم تكتمل (لإحصائيات لاحقة)
  Future<void> recordAttempt(String unitId) async {
    _ensureInitialized();
    final current = getUnitProgress(unitId);
    final updated = current.copyWith(
      lastAttemptAt: DateTime.now(),
      attemptsCount: current.attemptsCount + 1,
    );
    await _box.put(unitId, updated);
  }

  /// كل معرّفات الوحدات المكتملة (لشاشة خريطة التقدم)
  List<String> getCompletedUnitIds() {
    _ensureInitialized();
    return _box.values
        .where((progress) => progress.completed)
        .map((progress) => progress.unitId)
        .toList();
  }

  /// نسبة الإكمال الكلية عبر كل الوحدات (لشريط تقدم عام)
  double getOverallProgress(int totalUnitsCount) {
    if (totalUnitsCount == 0) return 0.0;
    final completedCount = getCompletedUnitIds().length;
    return completedCount / totalUnitsCount;
  }

  /// لإعادة تعيين كل التقدم (مفيدة لزر "إعادة البدء" في إعدادات الأهل)
  Future<void> resetAll() async {
    _ensureInitialized();
    await _box.clear();
  }
}
