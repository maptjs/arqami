import '../widgets/games/scene_explore_widget.dart' show SceneType;
import 'unit_model.dart';

/// قاعدة بيانات الـ13 وحدة (أرقامي، 4-6 سنوات).
///
/// ⚠️ الوحدتان 11 و12 معلّمتان كـ PendingActivityConfig لأنهما تحتاجان
/// مكونات لم تُبنَ بعد:
///   - وحدة 11 (أكبر/أصغر): تحتاج ComparisonWidget جديد
///   - وحدة 12 (الأرقام حولي): تحتاج شاشة استكشاف مخصصة + أصول بصرية
/// باقي الـ11 وحدة (1-10، 13) تستعمل المكونات الثلاثة الجاهزة فقط
/// (Trace, Matching, DragCount) وهي قابلة للتشغيل الفعلي اليوم.
class UnitsData {
  static final List<UnitModel> units = [
    const UnitModel(
      id: 'unit_01',
      order: 1,
      titleAr: 'الرقم 1 و 2',
      activities: [
        TraceActivityConfig(1),
        TraceActivityConfig(2),
      ],
    ),
    const UnitModel(
      id: 'unit_02',
      order: 2,
      titleAr: 'الرقم 3 و 4',
      activities: [
        TraceActivityConfig(3),
        TraceActivityConfig(4),
      ],
    ),
    const UnitModel(
      id: 'unit_03',
      order: 3,
      titleAr: 'الرقم 5',
      activities: [
        TraceActivityConfig(5),
      ],
    ),
    const UnitModel(
      id: 'unit_04',
      order: 4,
      titleAr: 'العد من 1 إلى 5',
      activities: [
        DragCountActivityConfig(5),
      ],
    ),
    UnitModel(
      id: 'unit_05',
      order: 5,
      titleAr: 'مراجعة 1-5',
      activities: [
        MatchingActivityConfig(
          List.generate(
            5,
            (i) => MatchPairSpec(
              id: '${i + 1}',
              leftType: MatchContentType.number,
              leftValue: i + 1,
              rightType: MatchContentType.number,
              rightValue: i + 1,
            ),
          ),
        ),
      ],
    ),
    const UnitModel(
      id: 'unit_06',
      order: 6,
      titleAr: 'الرقم 6 و 7',
      activities: [
        TraceActivityConfig(6),
        TraceActivityConfig(7),
      ],
    ),
    const UnitModel(
      id: 'unit_07',
      order: 7,
      titleAr: 'الرقم 8 و 9',
      activities: [
        TraceActivityConfig(8),
        TraceActivityConfig(9),
      ],
    ),
    const UnitModel(
      id: 'unit_08',
      order: 8,
      titleAr: 'الرقم 10',
      activities: [
        // الرقم 10 مكوّن من خانتين، نتتبعهما بالترتيب: 1 ثم 0
        TraceActivityConfig(1),
        TraceActivityConfig(0),
      ],
    ),
    const UnitModel(
      id: 'unit_09',
      order: 9,
      titleAr: 'العد من 1 إلى 10',
      activities: [
        DragCountActivityConfig(10),
      ],
    ),
    UnitModel(
      id: 'unit_10',
      order: 10,
      titleAr: 'مطابقة الرقم بالكمية',
      activities: [
        MatchingActivityConfig([
          for (final value in [2, 4, 6, 8, 10])
            MatchPairSpec(
              id: '$value',
              leftType: MatchContentType.number,
              leftValue: value,
              rightType: MatchContentType.quantity,
              rightValue: value,
            ),
        ]),
      ],
    ),
    const UnitModel(
      id: 'unit_11',
      order: 11,
      titleAr: 'أكبر من، أصغر من',
      activities: [
        // ثلاث محاولات متدرجة: فرق كبير، فرق متوسط، ثم سؤال "أقل" للتنويع
        ComparisonActivityConfig(
          leftCount: 2,
          rightCount: 7,
          question: ComparisonQuestionType.more,
        ),
        ComparisonActivityConfig(
          leftCount: 6,
          rightCount: 4,
          question: ComparisonQuestionType.more,
        ),
        ComparisonActivityConfig(
          leftCount: 8,
          rightCount: 3,
          question: ComparisonQuestionType.fewer,
        ),
      ],
    ),
    const UnitModel(
      id: 'unit_12',
      order: 12,
      titleAr: 'الأرقام حولي',
      activities: [
        SceneExploreActivityConfig(
          sceneType: SceneType.clock,
          targetDigit: 7,
        ),
        SceneExploreActivityConfig(
          sceneType: SceneType.phone,
          targetDigit: 4,
        ),
        SceneExploreActivityConfig(
          sceneType: SceneType.carPlate,
          targetDigit: 9,
        ),
      ],
    ),
    UnitModel(
      id: 'unit_13',
      order: 13,
      titleAr: 'التقييم النهائي',
      activities: [
        // مزيج من الأنشطة الثلاثة كمراجعة شاملة قبل الشهادة
        const TraceActivityConfig(3),
        MatchingActivityConfig([
          for (final value in [2, 5, 9])
            MatchPairSpec(
              id: '$value',
              leftType: MatchContentType.number,
              leftValue: value,
              rightType: MatchContentType.quantity,
              rightValue: value,
            ),
        ]),
        const DragCountActivityConfig(6),
      ],
    ),
  ];

  static UnitModel byId(String id) =>
      units.firstWhere((u) => u.id == id, orElse: () => units.first);
}
