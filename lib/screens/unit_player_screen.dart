import 'package:flutter/material.dart';

import '../core/audio/audio_service.dart';
import '../core/progress/progress_tracker.dart';
import '../core/theme/app_colors.dart';
import '../models/unit_model.dart';
import '../widgets/games/comparison_widget.dart';
import '../widgets/games/drag_count_widget.dart';
import '../widgets/games/matching_widget.dart';
import '../widgets/games/scene_explore_widget.dart';
import '../widgets/games/trace_widget.dart';
import '../widgets/shared/number_display.dart';
import '../widgets/shared/quantity_row.dart';

/// شاشة عامة تشغّل أي وحدة من الـ13، بالاعتماد فقط على بيانات
/// [UnitModel.activities]. تتنقل تلقائياً بين الأنشطة، وتسجّل التقدم
/// والأصوات، وتعرض شاشة "أحسنت" فالنهاية.
///
/// هاد التصميم كيخلينا ما نكتبوش 13 شاشة منفصلة — وحدة واحدة من الكود
/// كتخدم كل المنهج، وزيادة وحدة جديدة فالمستقبل تتطلب غير إضافة بيانات
/// فـ units_data.dart بلا ما تمس هاد الملف.
class UnitPlayerScreen extends StatefulWidget {
  final UnitModel unit;
  const UnitPlayerScreen({super.key, required this.unit});

  @override
  State<UnitPlayerScreen> createState() => _UnitPlayerScreenState();
}

class _UnitPlayerScreenState extends State<UnitPlayerScreen> {
  int _activityIndex = 0;
  int _wrongAttemptsInUnit = 0;
  bool _unitCompleted = false;
  int? _lastAnnouncedSceneIndex;

  ActivityConfig get _currentActivity =>
      widget.unit.activities[_activityIndex];

  void _onWrongAttempt() {
    _wrongAttemptsInUnit++;
    AudioService.instance.playTryAgain();
  }

  void _onActivityComplete() {
    if (!mounted) return;
    if (_activityIndex < widget.unit.activities.length - 1) {
      setState(() => _activityIndex++);
    } else {
      _completeUnit();
    }
  }

  Future<void> _completeUnit() async {
    // تقدير بسيط للنجوم حسب عدد الأخطاء خلال الوحدة كاملة
    final stars = _wrongAttemptsInUnit == 0
        ? 3
        : (_wrongAttemptsInUnit <= 2 ? 2 : 1);

    await ProgressTracker.instance.markUnitComplete(
      widget.unit.id,
      stars: stars,
    );
    AudioService.instance.playUnitComplete();

    if (mounted) setState(() => _unitCompleted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.unit.titleAr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: !widget.unit.isImplemented
              ? _buildPendingView()
              : (_unitCompleted
                  ? _buildCompletionView()
                  : _buildActivity(_currentActivity)),
        ),
      ),
    );
  }

  Widget _buildPendingView() {
    final pending = widget.unit.activities
        .whereType<PendingActivityConfig>()
        .first;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.construction_rounded, size: 56, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'هاد الوحدة قيد الإنشاء',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            pending.reasonAr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('رجوع'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionView() {
    final progress = ProgressTracker.instance.getUnitProgress(widget.unit.id);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌟 أحسنت! 🌟', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final filled = i < progress.stars;
              return Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppColors.gold,
                size: 40,
              );
            }),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('رجوع لخريطة الوحدات'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivity(ActivityConfig config) {
    if (config is TraceActivityConfig) {
      return _ActivityScaffold(
        instructionAr: 'تتبّع الرقم بإصبعك ابتداءً من النقطة الخضراء',
        child: TraceWidget(
          key: ValueKey('trace_${config.digit}_$_activityIndex'),
          number: config.digit,
          onComplete: () {
            AudioService.instance.playCorrect();
            AudioService.instance.playNumber(config.digit);
            Future.delayed(
              const Duration(milliseconds: 700),
              _onActivityComplete,
            );
          },
        ),
      );
    }

    if (config is MatchingActivityConfig) {
      final pairs = config.pairs
          .map(
            (spec) => MatchPair(
              id: spec.id,
              leftContent: _buildMatchContent(spec.leftType, spec.leftValue),
              rightContent:
                  _buildMatchContent(spec.rightType, spec.rightValue),
            ),
          )
          .toList();

      return _ActivityScaffold(
        instructionAr: 'اسحب كل عنصر لنظيره المطابق',
        child: MatchingWidget(
          key: ValueKey('matching_$_activityIndex'),
          pairs: pairs,
          onCorrectMatch: (_) => AudioService.instance.playCorrect(),
          onWrongAttempt: _onWrongAttempt,
          onAllMatched: () {
            Future.delayed(
              const Duration(milliseconds: 700),
              _onActivityComplete,
            );
          },
        ),
      );
    }

    if (config is ComparisonActivityConfig) {
      return _ActivityScaffold(
        instructionAr: 'انظر جيداً واختر الكومة الصحيحة',
        child: ComparisonWidget(
          key: ValueKey('comparison_$_activityIndex'),
          leftCount: config.leftCount,
          rightCount: config.rightCount,
          question: config.question == ComparisonQuestionType.more
              ? ComparisonQuestion.more
              : ComparisonQuestion.fewer,
          onWrongAttempt: _onWrongAttempt,
          onComplete: () {
            AudioService.instance.playCorrect();
            Future.delayed(
              const Duration(milliseconds: 700),
              _onActivityComplete,
            );
          },
        ),
      );
    }

    if (config is SceneExploreActivityConfig) {
      // ننطق الرقم المطلوب مرة واحدة فقط عند دخول النشاط (مو فكل
      // rebuild سببو setState من محاولة خاطئة مثلاً)
      if (_lastAnnouncedSceneIndex != _activityIndex) {
        _lastAnnouncedSceneIndex = _activityIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AudioService.instance.playNumber(config.targetDigit);
        });
      }
      return _ActivityScaffold(
        instructionAr: 'ابحث عن الرقم ${config.targetDigit} والمس عليه',
        child: SceneExploreWidget(
          key: ValueKey('scene_$_activityIndex'),
          sceneType: config.sceneType,
          targetDigit: config.targetDigit,
          onWrongAttempt: _onWrongAttempt,
          onComplete: () {
            AudioService.instance.playCorrect();
            Future.delayed(
              const Duration(milliseconds: 700),
              _onActivityComplete,
            );
          },
        ),
      );
    }

    if (config is DragCountActivityConfig) {
      return _ActivityScaffold(
        instructionAr: 'اسحب العناصر للسلة وعدّها',
        child: DragCountWidget(
          key: ValueKey('dragcount_$_activityIndex'),
          targetCount: config.targetCount,
          onItemDropped: (count) => AudioService.instance.playNumber(count),
          onWrongDigitSelected: _onWrongAttempt,
          onComplete: () {
            AudioService.instance.playCorrect();
            Future.delayed(
              const Duration(milliseconds: 700),
              _onActivityComplete,
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMatchContent(MatchContentType type, int value) {
    switch (type) {
      case MatchContentType.number:
        return NumberDisplay(value: value);
      case MatchContentType.quantity:
        return QuantityRow(count: value);
    }
  }
}

/// إطار موحّد لأي نشاط: تعليمة نصية أعلى + المكون التفاعلي يملأ الباقي
class _ActivityScaffold extends StatelessWidget {
  final String instructionAr;
  final Widget child;

  const _ActivityScaffold({required this.instructionAr, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          instructionAr,
          style: const TextStyle(fontSize: 17),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Expanded(child: Center(child: child)),
      ],
    );
  }
}
