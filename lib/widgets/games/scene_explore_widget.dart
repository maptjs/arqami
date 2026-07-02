import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// أنواع المشاهد المتاحة لوحدة "الأرقام حولي". كل مشهد مبني بالكامل
/// برسم متجهي (CustomPainter) وأيقونات Material — بدون أي صورة خارجية.
enum SceneType { clock, phone, carPlate }

/// مكون "ابحث عن الرقم" — يعرض مشهداً يومياً (ساعة حائط، لوحة مفاتيح
/// هاتف، لوحة تسجيل سيارة) فيه عدة أرقام، ويطلب من الطفل يلمس رقماً
/// معيناً بينهم. الهدف: ربط الأرقام المجردة بسياقات واقعية.
///
/// الاستخدام:
/// ```dart
/// SceneExploreWidget(
///   sceneType: SceneType.clock,
///   targetDigit: 7,
///   onComplete: () => print('لقيت الرقم 7 فالساعة!'),
/// )
/// ```
class SceneExploreWidget extends StatefulWidget {
  final SceneType sceneType;
  final int targetDigit;
  final VoidCallback onComplete;
  final VoidCallback? onWrongAttempt;

  const SceneExploreWidget({
    super.key,
    required this.sceneType,
    required this.targetDigit,
    required this.onComplete,
    this.onWrongAttempt,
  });

  @override
  State<SceneExploreWidget> createState() => SceneExploreWidgetState();
}

class SceneExploreWidgetState extends State<SceneExploreWidget> {
  bool _completed = false;
  int? _wrongTappedDigit;

  void _handleTap(int digit) {
    if (_completed) return;
    if (digit == widget.targetDigit) {
      setState(() => _completed = true);
      widget.onComplete();
    } else {
      widget.onWrongAttempt?.call();
      setState(() => _wrongTappedDigit = digit);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _wrongTappedDigit = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.sceneType) {
      case SceneType.clock:
        return _buildClockScene();
      case SceneType.phone:
        return _buildPhoneScene();
      case SceneType.carPlate:
        return _buildCarPlateScene();
    }
  }

  Widget _buildClockScene() {
    const clockNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide;
          final radius = size * 0.38;
          final center = Offset(size / 2, size / 2);

          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _ClockFacePainter(),
              ),
              for (final number in clockNumbers)
                _positionedClockNumber(number, center, radius),
              // عقارب الساعة (زخرفة فقط، بلا وظيفة)
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.textPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _positionedClockNumber(int number, Offset center, double radius) {
    // زاوية كل رقم (12 فالأعلى، دوران باتجاه عقارب الساعة)
    final angle = (number % 12) * (2 * math.pi / 12) - (math.pi / 2);
    final dx = center.dx + radius * math.cos(angle);
    final dy = center.dy + radius * math.sin(angle);

    final isWrong = _wrongTappedDigit == number;
    final isTargetFound = _completed && number == widget.targetDigit;

    return Positioned(
      left: dx - 22,
      top: dy - 22,
      child: GestureDetector(
        onTap: () => _handleTap(number),
        child: _DigitBubble(
          value: number,
          size: 44,
          isWrong: isWrong,
          isHighlighted: isTargetFound,
        ),
      ),
    );
  }

  Widget _buildPhoneScene() {
    // لوحة مفاتيح هاتف كلاسيكية: 1-9 ثم 0 فالمنتصف
    const keypadLayout = [1, 2, 3, 4, 5, 6, 7, 8, 9, -1, 0, -1];

    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: keypadLayout.map((digit) {
              if (digit == -1) return const SizedBox.shrink();
              final isWrong = _wrongTappedDigit == digit;
              final isTargetFound = _completed && digit == widget.targetDigit;
              return GestureDetector(
                onTap: () => _handleTap(digit),
                child: _DigitBubble(
                  value: digit,
                  size: 56,
                  isWrong: isWrong,
                  isHighlighted: isTargetFound,
                  backgroundColor: Colors.white,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCarPlateScene() {
    // لوحة تسجيل مبسّطة بصيغة مغربية: أرقام - حرف - رمز جهة
    const plateDigits = [4, 7, 2, 9, 1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textPrimary, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final digit in plateDigits) ...[
            _plateDigitCell(digit),
            const SizedBox(width: 6),
          ],
          Container(
            width: 2,
            height: 40,
            color: AppColors.textPrimary,
            margin: const EdgeInsets.symmetric(horizontal: 6),
          ),
          const Icon(Icons.flag_rounded, color: AppColors.teal, size: 28),
        ],
      ),
    );
  }

  Widget _plateDigitCell(int digit) {
    final isWrong = _wrongTappedDigit == digit;
    final isTargetFound = _completed && digit == widget.targetDigit;
    return GestureDetector(
      onTap: () => _handleTap(digit),
      child: _DigitBubble(
        value: digit,
        size: 44,
        isWrong: isWrong,
        isHighlighted: isTargetFound,
        rounded: false,
      ),
    );
  }
}

/// دائرة/مربع يحتوي رقماً — العنصر التفاعلي المشترك عبر كل المشاهد
class _DigitBubble extends StatelessWidget {
  final int value;
  final double size;
  final bool isWrong;
  final bool isHighlighted;
  final bool rounded;
  final Color backgroundColor;

  const _DigitBubble({
    required this.value,
    required this.size,
    required this.isWrong,
    required this.isHighlighted,
    this.rounded = true,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isWrong
        ? AppColors.incorrect
        : (isHighlighted ? AppColors.completed : AppColors.textSecondary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.completed.withOpacity(0.15)
            : backgroundColor,
        shape: rounded ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: rounded ? null : BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 2.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// يرسم إطار الساعة الدائري وعلامات الدقائق — بلا أي صورة
class _ClockFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 4;

    final facePaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, facePaint);
    canvas.drawCircle(center, radius, borderPaint);

    final tickPaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 2;

    for (int i = 0; i < 60; i++) {
      final angle = i * (2 * math.pi / 60);
      final isHourTick = i % 5 == 0;
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - (isHourTick ? 10 : 5)) * math.cos(angle),
        center.dy + (radius - (isHourTick ? 10 : 5)) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ClockFacePainter oldDelegate) => false;
}
