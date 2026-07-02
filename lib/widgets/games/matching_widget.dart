import 'package:flutter/material.dart';

/// زوج عناصر يجب على الطفل مطابقتهم (نفس id يعني أنهم متطابقان)
class MatchPair {
  final String id;
  final Widget leftContent;
  final Widget rightContent;

  const MatchPair({
    required this.id,
    required this.leftContent,
    required this.rightContent,
  });
}

/// مكون المطابقة بالسحب — الطفل يسحب من عنصر باليسار لنظيره المطابق
/// باليمين (مثلاً: الرقم 5 ↔ خمس تفاحات، أو رقم↔رقم في لعبة ميموري).
///
/// الاستخدام:
/// ```dart
/// MatchingWidget(
///   pairs: [
///     MatchPair(id: '5', leftContent: NumberDisplay(5), rightContent: AppleRow(5)),
///     MatchPair(id: '3', leftContent: NumberDisplay(3), rightContent: AppleRow(3)),
///   ],
///   onAllMatched: () => print('أحسنت! كل الأزواج صحيحة'),
/// )
/// ```
class MatchingWidget extends StatefulWidget {
  final List<MatchPair> pairs;
  final VoidCallback onAllMatched;

  /// يُستدعى عند كل مطابقة صحيحة (مفيد لتشغيل صوت تشجيعي فوري)
  final void Function(String id)? onCorrectMatch;

  /// يُستدعى عند محاولة خاطئة (مفيد لصوت "حاول مرة أخرى" لطيف)
  final VoidCallback? onWrongAttempt;

  final Color lineColor;
  final Color matchedColor;

  const MatchingWidget({
    super.key,
    required this.pairs,
    required this.onAllMatched,
    this.onCorrectMatch,
    this.onWrongAttempt,
    this.lineColor = const Color(0xFF90A4AE),
    this.matchedColor = const Color(0xFF66BB6A),
  });

  @override
  State<MatchingWidget> createState() => MatchingWidgetState();
}

class MatchingWidgetState extends State<MatchingWidget> {
  final GlobalKey _stackKey = GlobalKey();
  late List<GlobalKey> _leftKeys;
  late List<GlobalKey> _rightKeys;
  late List<String> _rightOrder;

  final Set<String> _matchedIds = {};
  String? _activeDragLeftId;
  Offset? _dragPosition;
  String? _flashWrongRightId;

  @override
  void initState() {
    super.initState();
    _setupKeysAndOrder();
  }

  void _setupKeysAndOrder() {
    _leftKeys = List.generate(widget.pairs.length, (_) => GlobalKey());
    _rightKeys = List.generate(widget.pairs.length, (_) => GlobalKey());
    _rightOrder = widget.pairs.map((p) => p.id).toList()..shuffle();
  }

  @override
  void didUpdateWidget(covariant MatchingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pairs.length != widget.pairs.length ||
        !_samePairIds(oldWidget.pairs, widget.pairs)) {
      reset(reshuffleAndRebuildKeys: true);
    }
  }

  bool _samePairIds(List<MatchPair> a, List<MatchPair> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  /// يمسح كل المطابقات ويعيد الترتيب العشوائي (لزر "حاول مرة أخرى")
  void reset({bool reshuffleAndRebuildKeys = false}) {
    setState(() {
      _matchedIds.clear();
      _activeDragLeftId = null;
      _dragPosition = null;
      _flashWrongRightId = null;
      if (reshuffleAndRebuildKeys) _setupKeysAndOrder();
    });
  }

  Offset? _centerOfKey(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || stackBox == null || !renderBox.attached) {
      return null;
    }
    final globalCenter =
        renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    return stackBox.globalToLocal(globalCenter);
  }

  Offset _toLocal(Offset global) {
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return global;
    return stackBox.globalToLocal(global);
  }

  void _onPanStart(String leftId, DragStartDetails details) {
    if (_matchedIds.contains(leftId)) return;
    setState(() {
      _activeDragLeftId = leftId;
      _dragPosition = _toLocal(details.globalPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeDragLeftId == null) return;
    setState(() => _dragPosition = _toLocal(details.globalPosition));
  }

  void _onPanEnd(DragEndDetails details) {
    final leftId = _activeDragLeftId;
    final dropPosition = _dragPosition;

    setState(() {
      _activeDragLeftId = null;
      _dragPosition = null;
    });

    if (leftId == null || dropPosition == null) return;

    const hitThreshold = 55.0;
    String? hitId;
    double bestDistance = double.infinity;

    for (int i = 0; i < _rightOrder.length; i++) {
      final rightId = _rightOrder[i];
      if (_matchedIds.contains(rightId)) continue;
      final center = _centerOfKey(_rightKeys[i]);
      if (center == null) continue;
      final distance = (center - dropPosition).distance;
      if (distance < hitThreshold && distance < bestDistance) {
        bestDistance = distance;
        hitId = rightId;
      }
    }

    if (hitId == null) return;

    if (hitId == leftId) {
      setState(() => _matchedIds.add(leftId));
      widget.onCorrectMatch?.call(leftId);
      if (_matchedIds.length == widget.pairs.length) {
        widget.onAllMatched();
      }
    } else {
      widget.onWrongAttempt?.call();
      setState(() => _flashWrongRightId = hitId);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _flashWrongRightId = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _stackKey,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.pairs.length, (i) {
                final pair = widget.pairs[i];
                final isMatched = _matchedIds.contains(pair.id);
                return Padding(
                  key: _leftKeys[i],
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: GestureDetector(
                    onPanStart: isMatched
                        ? null
                        : (d) => _onPanStart(pair.id, d),
                    onPanUpdate: isMatched ? null : _onPanUpdate,
                    onPanEnd: isMatched ? null : _onPanEnd,
                    child: AnimatedOpacity(
                      opacity: isMatched ? 0.35 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: _ItemCard(
                        borderColor:
                            isMatched ? widget.matchedColor : Colors.white,
                        child: pair.leftContent,
                      ),
                    ),
                  ),
                );
              }),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_rightOrder.length, (i) {
                final id = _rightOrder[i];
                final pair = widget.pairs.firstWhere((p) => p.id == id);
                final isMatched = _matchedIds.contains(id);
                final isFlashingWrong = _flashWrongRightId == id;
                return Padding(
                  key: _rightKeys[i],
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: AnimatedOpacity(
                    opacity: isMatched ? 0.35 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: _ItemCard(
                      borderColor: isFlashingWrong
                          ? const Color(0xFFE57373)
                          : (isMatched ? widget.matchedColor : Colors.white),
                      child: pair.rightContent,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        if (_activeDragLeftId != null && _dragPosition != null)
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: _DragLinePainter(
                start: _centerOfKey(
                      _leftKeys[
                          widget.pairs.indexWhere((p) => p.id == _activeDragLeftId)],
                    ) ??
                    _dragPosition!,
                end: _dragPosition!,
                color: widget.lineColor,
              ),
            ),
          ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;

  const _ItemCard({required this.child, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

class _DragLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  _DragLinePainter({required this.start, required this.end, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
    canvas.drawCircle(start, 7, paint);
  }

  @override
  bool shouldRepaint(covariant _DragLinePainter oldDelegate) => true;
}
