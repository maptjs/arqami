import '../widgets/games/scene_explore_widget.dart' show SceneType;

/// وصف عام لنشاط داخل وحدة. كل وحدة تتكون من قائمة أنشطة مرتبة،
/// الطفل يكملها بالترتيب قبل اعتبار الوحدة منتهية.
abstract class ActivityConfig {
  const ActivityConfig();
}

/// نشاط تتبّع رقم واحد (يستهلك TraceWidget)
class TraceActivityConfig extends ActivityConfig {
  final int digit; // 0-9 فقط (مرتبط بـ NumberPathData)
  const TraceActivityConfig(this.digit);
}

/// نوع محتوى عنصر المطابقة: رقم مكتوب، أو كمية مرسومة (دوائر/أيقونات)
enum MatchContentType { number, quantity }

/// وصف زوج مطابقة واحد ضمن نشاط مطابقة
class MatchPairSpec {
  final String id;
  final MatchContentType leftType;
  final int leftValue;
  final MatchContentType rightType;
  final int rightValue;

  const MatchPairSpec({
    required this.id,
    required this.leftType,
    required this.leftValue,
    required this.rightType,
    required this.rightValue,
  });
}

/// نشاط مطابقة (يستهلك MatchingWidget)
class MatchingActivityConfig extends ActivityConfig {
  final List<MatchPairSpec> pairs;
  const MatchingActivityConfig(this.pairs);
}

/// نشاط اسحب وعدّ (يستهلك DragCountWidget)
class DragCountActivityConfig extends ActivityConfig {
  final int targetCount;
  const DragCountActivityConfig(this.targetCount);
}

/// نوع السؤال فنشاط المقارنة: أكثر أم أقل
enum ComparisonQuestionType { more, fewer }

/// نشاط مقارنة بصرية بين كومتين (يستهلك ComparisonWidget)
class ComparisonActivityConfig extends ActivityConfig {
  final int leftCount;
  final int rightCount;
  final ComparisonQuestionType question;

  const ComparisonActivityConfig({
    required this.leftCount,
    required this.rightCount,
    this.question = ComparisonQuestionType.more,
  });
}

/// نشاط لم يُبنَ مكوّنه بعد — تُعرض شاشة "قيد الإنشاء" بدل تعطّل التطبيق.
/// نستعملها لوحدات تحتاج مكونات جديدة لم نبنها بعد، باش تبقى الوحدة
/// موجودة فالمنهج بدون ما تكسر باقي السلسلة.
class PendingActivityConfig extends ActivityConfig {
  final String reasonAr;
  const PendingActivityConfig(this.reasonAr);
}

/// نشاط استكشاف مشهد يومي (ساعة، هاتف، لوحة سيارة) — يستهلك
/// SceneExploreWidget. الطفل يبحث عن رقم معين وسط المشهد.
class SceneExploreActivityConfig extends ActivityConfig {
  final SceneType sceneType;
  final int targetDigit;

  const SceneExploreActivityConfig({
    required this.sceneType,
    required this.targetDigit,
  });
}

/// نموذج الوحدة الكاملة
class UnitModel {
  final String id; // مثال: 'unit_01'
  final int order; // ترتيب الظهور 1-13
  final String titleAr;
  final List<ActivityConfig> activities;

  const UnitModel({
    required this.id,
    required this.order,
    required this.titleAr,
    required this.activities,
  });

  /// false لو الوحدة فيها نشاط واحد على الأقل لم يُبنَ مكوّنه بعد
  bool get isImplemented =>
      !activities.any((a) => a is PendingActivityConfig);
}
