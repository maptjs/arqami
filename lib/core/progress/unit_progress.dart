import 'package:hive/hive.dart';

part 'unit_progress.g.dart';

/// ⚠️ typeId: إذا كان عندك مشروع آخر (وقتي مثلاً) فيه Hive models أخرى
/// مسجّلة بنفس typeId، لازم تغيّر هاد الرقم لتفادي تعارض عند التسجيل.
/// الأفضل: خصّص نطاق أرقام لكل تطبيق (مثلاً أرقامي يبدأ من 10، وقتي من 0).
@HiveType(typeId: 10)
class UnitProgress extends HiveObject {
  @HiveField(0)
  String unitId;

  @HiveField(1)
  bool completed;

  @HiveField(2)
  int stars; // 0-3

  @HiveField(3)
  DateTime? lastAttemptAt;

  @HiveField(4)
  int attemptsCount;

  UnitProgress({
    required this.unitId,
    this.completed = false,
    this.stars = 0,
    this.lastAttemptAt,
    this.attemptsCount = 0,
  });

  UnitProgress copyWith({
    bool? completed,
    int? stars,
    DateTime? lastAttemptAt,
    int? attemptsCount,
  }) {
    return UnitProgress(
      unitId: unitId,
      completed: completed ?? this.completed,
      stars: stars ?? this.stars,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      attemptsCount: attemptsCount ?? this.attemptsCount,
    );
  }
}
