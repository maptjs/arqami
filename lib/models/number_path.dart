import 'dart:ui';

/// نقطة مرجعية على مسار الرقم، بإحداثيات نسبية (0.0 - 1.0)
/// نستعمل إحداثيات نسبية بدل بكسلات مطلقة باش يتلاءم المسار
/// مع أي حجم شاشة (هاتف صغير أو تابلت)
class PathPoint {
  final double x;
  final double y;
  const PathPoint(this.x, this.y);

  Offset toOffset(Size size) => Offset(x * size.width, y * size.height);
}

/// مسار رقم واحد: مجموعة نقاط مرجعية مرتبة من البداية للنهاية
class NumberPath {
  final int digit;
  final List<PathPoint> points;

  /// مؤشرات النقاط التي تبدأ فيها "ضربة قلم" جديدة (مثلاً الرقم 4
  /// يحتاج خطين منفصلين). الفهرس 0 لا يُذكر هنا لأنه البداية الطبيعية.
  final List<int> strokeBreaks;

  const NumberPath({
    required this.digit,
    required this.points,
    this.strokeBreaks = const [],
  });

  /// يبني مسار الرسم الإرشادي (يُستخدم فقط لو احتجنا خط متصل
  /// بدل نقاط منفصلة في الرسم)
  Path buildGuidePath(Size size) {
    final path = Path();
    if (points.isEmpty) return path;

    final first = points[0].toOffset(size);
    path.moveTo(first.dx, first.dy);

    for (int i = 1; i < points.length; i++) {
      final offset = points[i].toOffset(size);
      if (strokeBreaks.contains(i)) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    return path;
  }
}

/// قاعدة بيانات مسارات الأرقام 0-9
///
/// ⚠️ ملاحظة مهمة: الإحداثيات أدناه تقريبية وتم وضعها لتوضيح البنية فقط.
/// قبل الإنتاج، يجب ضبطها بدقة عبر إحدى الطريقتين:
///   1. رسم كل رقم على شبكة 10×10 ورقياً، وتسجيل نقاط الانعطاف كنسبة (0.0-1.0)
///   2. تصدير مسار SVG لكل رقم من Figma/Illustrator، ثم استخراج نقاطه برمجياً
///
/// النقاط مرتبة بنفس ترتيب الكتابة الطبيعي للرقم (من أين يبدأ القلم).
class NumberPathData {
  static final Map<int, NumberPath> _paths = {
    0: const NumberPath(
      digit: 0,
      points: [
        PathPoint(0.50, 0.10),
        PathPoint(0.30, 0.20),
        PathPoint(0.20, 0.40),
        PathPoint(0.20, 0.60),
        PathPoint(0.30, 0.80),
        PathPoint(0.50, 0.90),
        PathPoint(0.70, 0.80),
        PathPoint(0.80, 0.60),
        PathPoint(0.80, 0.40),
        PathPoint(0.70, 0.20),
        PathPoint(0.50, 0.10),
      ],
    ),
    1: const NumberPath(
      digit: 1,
      points: [
        PathPoint(0.35, 0.22),
        PathPoint(0.50, 0.10),
        PathPoint(0.50, 0.50),
        PathPoint(0.50, 0.90),
      ],
    ),
    2: const NumberPath(
      digit: 2,
      points: [
        PathPoint(0.25, 0.25),
        PathPoint(0.40, 0.10),
        PathPoint(0.65, 0.12),
        PathPoint(0.75, 0.30),
        PathPoint(0.60, 0.50),
        PathPoint(0.35, 0.70),
        PathPoint(0.25, 0.88),
        PathPoint(0.75, 0.88),
      ],
    ),
    3: const NumberPath(
      digit: 3,
      points: [
        PathPoint(0.25, 0.20),
        PathPoint(0.50, 0.10),
        PathPoint(0.70, 0.25),
        PathPoint(0.55, 0.48),
        PathPoint(0.70, 0.65),
        PathPoint(0.55, 0.88),
        PathPoint(0.25, 0.80),
      ],
    ),
    4: const NumberPath(
      digit: 4,
      points: [
        // الضربة الأولى: الخط المائل + الأفقي
        PathPoint(0.60, 0.10),
        PathPoint(0.25, 0.55),
        PathPoint(0.75, 0.55),
        // الضربة الثانية: الخط العمودي (منفصلة)
        PathPoint(0.60, 0.10),
        PathPoint(0.60, 0.90),
      ],
      strokeBreaks: [3],
    ),
    5: const NumberPath(
      digit: 5,
      points: [
        PathPoint(0.70, 0.12),
        PathPoint(0.30, 0.12),
        PathPoint(0.25, 0.40),
        PathPoint(0.45, 0.35),
        PathPoint(0.65, 0.45),
        PathPoint(0.70, 0.65),
        PathPoint(0.55, 0.85),
        PathPoint(0.30, 0.80),
      ],
    ),
    6: const NumberPath(
      digit: 6,
      points: [
        PathPoint(0.65, 0.12),
        PathPoint(0.40, 0.25),
        PathPoint(0.28, 0.50),
        PathPoint(0.28, 0.70),
        PathPoint(0.45, 0.88),
        PathPoint(0.65, 0.80),
        PathPoint(0.65, 0.60),
        PathPoint(0.45, 0.50),
        PathPoint(0.28, 0.55),
      ],
    ),
    7: const NumberPath(
      digit: 7,
      points: [
        PathPoint(0.25, 0.12),
        PathPoint(0.75, 0.12),
        PathPoint(0.45, 0.90),
      ],
    ),
    8: const NumberPath(
      digit: 8,
      points: [
        PathPoint(0.50, 0.10),
        PathPoint(0.32, 0.20),
        PathPoint(0.32, 0.35),
        PathPoint(0.50, 0.48),
        PathPoint(0.68, 0.35),
        PathPoint(0.68, 0.20),
        PathPoint(0.50, 0.10),
        PathPoint(0.30, 0.62),
        PathPoint(0.30, 0.78),
        PathPoint(0.50, 0.90),
        PathPoint(0.70, 0.78),
        PathPoint(0.70, 0.62),
        PathPoint(0.50, 0.48),
      ],
    ),
    9: const NumberPath(
      digit: 9,
      points: [
        PathPoint(0.62, 0.45),
        PathPoint(0.45, 0.50),
        PathPoint(0.30, 0.40),
        PathPoint(0.30, 0.22),
        PathPoint(0.50, 0.10),
        PathPoint(0.68, 0.20),
        PathPoint(0.68, 0.55),
        PathPoint(0.55, 0.78),
        PathPoint(0.32, 0.88),
      ],
    ),
  };

  static NumberPath getPath(int digit) {
    final path = _paths[digit];
    if (path == null) {
      throw ArgumentError('لا يوجد مسار معرّف للرقم $digit');
    }
    return path;
  }

  static bool hasPath(int digit) => _paths.containsKey(digit);
}
