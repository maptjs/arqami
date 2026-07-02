import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// خدمة موحّدة لتشغيل كل أصوات التطبيق — **بدون أي ملف صوتي خارجي**.
///
/// الاستراتيجية:
///   - نطق الأرقام والعبارات: عبر flutter_tts (TTS حي)
///   - النقرات السريعة (سحب عنصر، اختيار): عبر SystemSound المدمجة
///     فـ Flutter (بلا أي asset)
///   - التغذية الراجعة (صحيح/حاول مرة أخرى/إكمال): مزيج من SystemSound
///     فوري + عبارة TTS قصيرة بعدها مباشرة
///
/// هاد المقاربة كتخلي التطبيق قابل للتشغيل والاختبار الكامل من اليوم
/// الأول بلا انتظار أي تسجيل صوتي احترافي. إذا بغيتي تبدّل لاحقاً
/// لأصوات مسجّلة احترافية (بدل SystemSound)، يكفي تبدّل _playChime()
/// بمشغّل audioplayers بلا ما تمس باقي الملف.
class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _muted = false;
  bool get isMuted => _muted;

  /// كلمات الأرقام بالعربية الفصحى (0-12، حتى 12 لدعم أرقام الساعة)
  static const Map<int, String> _numberWords = {
    0: 'صفر',
    1: 'واحد',
    2: 'اثنان',
    3: 'ثلاثة',
    4: 'أربعة',
    5: 'خمسة',
    6: 'ستة',
    7: 'سبعة',
    8: 'ثمانية',
    9: 'تسعة',
    10: 'عشرة',
    11: 'أحد عشر',
    12: 'اثنا عشر',
  };

  /// عبارات تشجيعية متنوعة (تُختار عشوائياً باش ما يبقاش نفس الكلمة
  /// مكررة فكل مرة، وهذا يخلي التجربة أكثر حيوية للطفل)
  static const List<String> _correctPhrases = [
    'أحسنت',
    'ممتاز',
    'رائع',
    'برافو عليك',
  ];

  int _correctPhraseIndex = 0;

  Future<void> init() async {
    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(0.42); // أبطأ من الافتراضي لوضوح أكبر للطفل
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05); // نبرة أعلى قليلاً، أقرب لصوت مرح
  }

  void setMuted(bool muted) {
    _muted = muted;
    if (muted) _tts.stop();
  }

  /// ينطق رقماً معيناً (0-10) بالعربية الفصحى
  Future<void> playNumber(int digit) async {
    if (_muted) return;
    final word = _numberWords[digit];
    if (word == null) return;
    await _tts.stop();
    await _tts.speak(word);
  }

  /// ينطق أي نص عربي مخصص (تعليمات، عناوين وحدات...)
  Future<void> speak(String text) async {
    if (_muted) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  /// نقرة فورية خفيفة (سحب عنصر، لمس) — صوت نظام مدمج، بلا أي asset
  void playTick() {
    if (_muted) return;
    SystemSound.play(SystemSoundType.click);
  }

  /// إجابة صحيحة: نقرة فورية + عبارة تشجيعية منطوقة (تتناوب بين
  /// عدة عبارات باش ما تبقاش رتيبة)
  Future<void> playCorrect() async {
    if (_muted) return;
    SystemSound.play(SystemSoundType.click);
    final phrase = _correctPhrases[_correctPhraseIndex % _correctPhrases.length];
    _correctPhraseIndex++;
    await _tts.stop();
    await _tts.speak(phrase);
  }

  /// إعادة محاولة: نبرة لطيفة غير مخيفة، بلا "خطأ" صريح
  Future<void> playTryAgain() async {
    if (_muted) return;
    await _tts.stop();
    await _tts.speak('حاول مرة أخرى');
  }

  /// إكمال وحدة كاملة: عبارة احتفالية أطول
  Future<void> playUnitComplete() async {
    if (_muted) return;
    SystemSound.play(SystemSoundType.click);
    await _tts.stop();
    await _tts.speak('أحسنت! أكملت الوحدة بنجاح');
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
