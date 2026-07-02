import 'package:flutter/material.dart';

import '../core/progress/progress_tracker.dart';
import '../core/progress/unit_progress.dart';
import '../core/theme/app_colors.dart';
import '../models/unit_model.dart';
import '../models/units_data.dart';
import 'unit_player_screen.dart';

/// الشاشة الرئيسية: خريطة الوحدات الـ13 بترتيب تصاعدي.
/// كل وحدة مقفلة حتى تكتمل الوحدة اللي قبلها (الوحدة الأولى دائماً مفتوحة).
/// تعرض عدد النجوم المحفوظة لكل وحدة من ProgressTracker، وتتحدّث
/// تلقائياً عند الرجوع من أي وحدة.
class UnitsMapScreen extends StatefulWidget {
  const UnitsMapScreen({super.key});

  @override
  State<UnitsMapScreen> createState() => _UnitsMapScreenState();
}

class _UnitsMapScreenState extends State<UnitsMapScreen> {
  final List<UnitModel> _units = UnitsData.units;

  bool _isUnitUnlocked(int indexInList) {
    if (indexInList == 0) return true; // الوحدة الأولى دائماً مفتوحة
    final previousUnit = _units[indexInList - 1];
    return ProgressTracker.instance
        .getUnitProgress(previousUnit.id)
        .completed;
  }

  Future<void> _openUnit(UnitModel unit) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UnitPlayerScreen(unit: unit)),
    );
    // عند الرجوع، التقدم ربما تغيّر (وحدة جديدة اكتملت) — نحدّث الواجهة
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final overallProgress =
        ProgressTracker.instance.getOverallProgress(_units.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('أرقامي'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _OverallProgressBar(progress: overallProgress),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _units.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final unit = _units[index];
                  final unlocked = _isUnitUnlocked(index);
                  final progress =
                      ProgressTracker.instance.getUnitProgress(unit.id);
                  return _UnitCard(
                    unit: unit,
                    unlocked: unlocked,
                    progress: progress,
                    onTap: unlocked ? () => _openUnit(unit) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverallProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  const _OverallProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقدّمك الكلي: ${(progress * 100).toInt()}%',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation(AppColors.completed),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final UnitModel unit;
  final bool unlocked;
  final UnitProgress progress;
  final VoidCallback? onTap;

  const _UnitCard({
    required this.unit,
    required this.unlocked,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = !unit.isImplemented;

    return Opacity(
      opacity: unlocked ? 1.0 : 0.5,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: unlocked ? 2 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _OrderBadge(
                  order: unit.order,
                  completed: progress.completed,
                  locked: !unlocked,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.titleAr,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isPending) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'قيد الإنشاء',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (unlocked && progress.completed)
                  _StarsRow(stars: progress.stars)
                else if (!unlocked)
                  const Icon(Icons.lock_rounded, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderBadge extends StatelessWidget {
  final int order;
  final bool completed;
  final bool locked;

  const _OrderBadge({
    required this.order,
    required this.completed,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = locked
        ? AppColors.locked
        : (completed ? AppColors.completed : AppColors.inProgress);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: completed
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
          : Text(
              '$order',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  final int stars;
  const _StarsRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.gold,
          size: 20,
        );
      }),
    );
  }
}
