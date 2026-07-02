import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// نوع السؤال: أيهما أكثر، أو أيهما أقل
enum ComparisonQuestion { more, fewer }

/// مكون المقارنة البصرية — يعرض كومتين من عناصر مختلفة العدد،
/// ويسأل الطفل "أيهما أكثر؟" أو "أيهما أقل؟" بدون أي رموز رياضية
/// (< أو >)، فقط مقارنة بصرية مباشرة بالعد والمقارنة.
///
/// الاستخدام:
/// ```dart
/// ComparisonWidget(
///   leftCount: 3,
///   rightCount: 7,
///   question: ComparisonQuestion.more,
///   onComplete: () => print('أحسنت! اختار الكومة الأكثر'),
/// )
/// ```
class ComparisonWidget extends StatefulWidget {
  final int leftCount;
  final int rightCount;
  final ComparisonQuestion question;
  final VoidCallback onComplete;
  final VoidCallback? onWrongAttempt;
  final IconData itemIcon;

  ComparisonWidget({
    super.key,
    required this.leftCount,
    required this.rightCount,
    required this.onComplete,
    this.question = ComparisonQuestion.more,
    this.onWrongAttempt,
    this.itemIcon = Icons.circle,
  }) : assert(
          leftCount != rightCount,
          'يجب أن تختلف الكوميتان لتفادي تعادل غير قابل للحل',
        );

  @override
  State<ComparisonWidget> createState() => ComparisonWidgetState();
}

class ComparisonWidgetState extends State<ComparisonWidget> {
  bool _completed = false;
  bool _wrongLeft = false;
  bool _wrongRight = false;

  bool get _leftIsCorrect {
    if (widget.question == ComparisonQuestion.more) {
      return widget.leftCount > widget.rightCount;
    }
    return widget.leftCount < widget.rightCount;
  }

  String get _questionLabel => widget.question == ComparisonQuestion.more
      ? 'أيّ كومة فيها أكثر؟'
      : 'أيّ كومة فيها أقل؟';

  void _handleTap(bool tappedLeft) {
    if (_completed) return;
    final tappedIsCorrect = tappedLeft ? _leftIsCorrect : !_leftIsCorrect;

    if (tappedIsCorrect) {
      setState(() => _completed = true);
      widget.onComplete();
    } else {
      widget.onWrongAttempt?.call();
      setState(() {
        _wrongLeft = tappedLeft;
        _wrongRight = !tappedLeft;
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _wrongLeft = false;
            _wrongRight = false;
          });
        }
      });
    }
  }

  /// يعيد المكون لحالته الأولية (مفيدة لو احتجنا "حاول من جديد" خارجياً)
  void reset() {
    setState(() {
      _completed = false;
      _wrongLeft = false;
      _wrongRight = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _questionLabel,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _GroupCard(
              count: widget.leftCount,
              icon: widget.itemIcon,
              color: AppColors.teal,
              isWrong: _wrongLeft,
              isCorrectAndCompleted: _completed && _leftIsCorrect,
              onTap: () => _handleTap(true),
            ),
            _GroupCard(
              count: widget.rightCount,
              icon: widget.itemIcon,
              color: AppColors.terracotta,
              isWrong: _wrongRight,
              isCorrectAndCompleted: _completed && !_leftIsCorrect,
              onTap: () => _handleTap(false),
            ),
          ],
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final int count;
  final IconData icon;
  final Color color;
  final bool isWrong;
  final bool isCorrectAndCompleted;
  final VoidCallback onTap;

  const _GroupCard({
    required this.count,
    required this.icon,
    required this.color,
    required this.isWrong,
    required this.isCorrectAndCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isWrong
        ? const Color(0xFFE57373)
        : (isCorrectAndCompleted ? const Color(0xFF4CAF50) : Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        constraints: const BoxConstraints(minHeight: 140),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(
            count,
            (_) => Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}
