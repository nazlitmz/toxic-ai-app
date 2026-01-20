import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';
import 'language_service.dart';

class AIService {
  static const String _apiKey =
      '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';
  static const String _apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static final Map<String, List<String>> _savageComments = {
    'en': [
      "You're not toxic, you're just emotionally confusing.",
      "This message has passive-aggressive energy written all over it.",
      "Congratulations, you've mastered the art of sounding nice while being mean.",
      "Your words say one thing, but your vibe says 'block me'.",
      "This text could start a war in a group chat.",
      "Even AI needs therapy after reading this.",
      "You're giving manipulative main character vibes.",
      "This is why people leave you on read.",
      "Your message radiates 'I'm fine' energy but screams chaos.",
      "This could be a case study in emotional manipulation.",
      "Even autocorrect is judging you right now.",
      "This message has 'we need to talk' vibes written all over it.",
    ],
    'tr': [
      "Toksik değilsin, sadece duygusal olarak kafa karıştırıcısın.",
      "Bu mesaj pasif-agresif enerjiyle dolu.",
      "Tebrikler, kibar görünüp kötü olmayı mükemmel öğrenmişsin.",
      "Sözlerin bir şey söylüyor ama vibe'ın 'beni engelle' diyor.",
      "Bu mesaj grup sohbetinde savaş çıkarabilir.",
      "Bu mesajdan sonra AI bile terapiye ihtiyaç duydu.",
      "Manipülatif ana karakter enerjisi veriyorsun.",
      "İnsanlar bu yüzden seni görüldü'de bırakıyor.",
      "Bu mesaj 'tamam' demek ile 'tamam.' demek arasındaki fark.",
      "Duygusal hasar bölümünde yeni rekor kırdın.",
      "Bu mesaj 'konuşmamız lazım' vibı veriyor.",
      "Oto düzeltme bile seni yargılıyor şu an.",
      "Bu mesaj WhatsApp grup dramalarında başrol oynar.",
      "Kelimeler masum ama enerji 'savaş ilan ediyorum' diyor.",
      "Bu mesajla psikoloji ders kitaplarına girebilirsin.",
    ],
  };

  static final Map<String, Map<String, List<String>>> _keywords = {
    'tr': {
      'toxic': [
        'aptal',
        'salak',
        'ahmak',
        'gerizekalı',
        'mal',
        'budala',
        'geri zekalı',
        'nefret',
        'tiksiniyorum',
        'iğrenç',
        'pis',
        'berbat',
        'kötü',
        'rezil',
        'zavallı',
        'sefil',
        'beceriksiz',
        'yetersiz',
        'başarısız',
        'ezik',
        'sinir',
        'deli',
        'kafayı yemiş',
        'manyak',
        'psikopat',
        'lanet',
        'kahrolası',
        'cehennem',
        'şeytan',
        'hiçbir şey bilmiyor',
        'anlama yok',
        'boş',
        'saçma',
        'saçmalık',
        'utanmaz',
        'arsız',
        'yüzsüz',
        'terbiyesiz',
        'saygısız',
      ],
      'passive_aggressive': [
        'tamam',
        'peki',
        'her neyse',
        'sen bilirsin',
        'istersen',
        'nasıl istersen',
        'sorun değil',
        'önemli değil',
        'canın sağ olsun',
        'sağlık olsun',
        'çok ilginç',
        'fena değil',
        'idare eder',
        'olabilir',
        'belki',
        'senin için güzel',
        'süper',
        'harika',
        'mükemmel',
        'ciddi misin',
        'şaka mı yapıyorsun',
        'gerçekten mi',
        'öyle mi',
        'sen ne anlamda',
        'nasıl yani',
        'yani',
        'hmmm',
        'gerek yok',
        'uğraşma',
        'boşver',
        'neyse',
        'neyse ki',
        'ben demedim',
        'ben mi dedim',
        'benden duymuş olmayın',
        'yanlış anlaşılmış',
        'öyle demek istemedim',
      ],
      'gaslighting': [
        'demedim',
        'öyle bir şey demedim',
        'sen yanlış anlamışsın',
        'yanlış hatırlıyorsun',
        'hayal ediyorsun',
        'kafayı yemiş',
        'sen mi biliyorsun',
        'çok hassas',
        'abartıyorsun',
        'aşırı tepki',
        'saçmalıyorsun',
        'delirmişsin',
        'öyle bir şey olmadı',
        'olmadı öyle bir şey',
        'uyduruyor',
        'kafanda kurgulamışsın',
        'paranoyak',
        'takıntılı',
        'sen hep böylesin',
        'hep aynı',
        'yine başladın',
        'gene mi',
        'problem sende',
        'sorun sende',
        'sen hep böyle yaparsın',
        'herkesle kavga ediyorsun',
        'kimse seni anlamıyor değil mi',
        'beni üzüyorsun',
        'hep beni suçluyorsun',
        'ben senin için',
        'senin yüzünden',
        'sen yaptın bunu bana',
        'ben kurbandım',
      ],
    },
    'en': {
      'toxic': [
        'hate',
        'stupid',
        'idiot',
        'dumb',
        'moron',
        'fool',
        'loser',
        'disgusting',
        'terrible',
        'awful',
        'horrible',
        'pathetic',
        'worthless',
        'useless',
        'incompetent',
        'failure',
        'annoying',
        'irritating',
        'shut up',
        'fuck',
        'damn',
        'hell',
        'crap',
        'bullshit',
        'ridiculous',
        'absurd',
        'nonsense',
        'waste',
        'trash',
      ],
      'passive_aggressive': [
        'fine',
        'whatever',
        'sure',
        'okay',
        'if you say so',
        'as you wish',
        'no worries',
        "it's fine",
        "don't worry about it",
        'forget it',
        'interesting',
        'good for you',
        'cool',
        'great',
        'awesome',
        'perfect',
        'are you serious',
        'really',
        'oh well',
        'i see',
        'right',
        'you do you',
        'suit yourself',
        'your choice',
        'up to you',
      ],
      'gaslighting': [
        'never said',
        "didn't say that",
        "you're crazy",
        "you're insane",
        'imagining things',
        'making things up',
        'overreacting',
        'too sensitive',
        'dramatic',
        'paranoid',
        "didn't happen",
        'that never happened',
        'you always do this',
        "you're always like this",
        'everyone thinks',
        "it's your fault",
        'you made me',
        'because of you',
        "you're the problem",
      ],
    },
  };

  // Helper: Herhangi bir değeri güvenli şekilde int'e çevir
  static int _toInt(dynamic value, [int defaultValue = 50]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // Helper: Herhangi bir değeri güvenli şekilde String'e çevir
  static String _toStr(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  // Kullanıcının seçtiği dili al, yoksa metinden algıla
  static Future<String> _getLanguage(String text) async {
    final savedLanguage = await LanguageService.getLanguage();
    if (savedLanguage != null) {
      return savedLanguage;
    }
    return _detectLanguageFromText(text);
  }

  // Metinden dil algıla (fallback)
  static String _detectLanguageFromText(String text) {
    final turkishChars = RegExp(r'[çğıöşüÇĞİÖŞÜ]');
    if (turkishChars.hasMatch(text)) return 'tr';

    final turkishIndicators = [
      'bir',
      've',
      'bu',
      'ne',
      'mi',
      'mı',
      'için',
      'ile',
      'var',
      'yok',
      'ben',
      'sen'
    ];
    final englishIndicators = [
      'the',
      'is',
      'are',
      'you',
      'and',
      'to',
      'a',
      'in',
      'that',
      'it'
    ];

    final words = text.toLowerCase().split(RegExp(r'\s+'));
    int trScore = 0;
    int enScore = 0;

    for (var word in words) {
      if (turkishIndicators.contains(word)) trScore++;
      if (englishIndicators.contains(word)) enScore++;
    }

    return trScore > enScore ? 'tr' : 'en';
  }

  static String _getRandomComment(String language) {
    final comments = _savageComments[language] ?? _savageComments['en']!;
    final random = DateTime.now().millisecondsSinceEpoch % comments.length;
    return comments[random];
  }

  static String _normalizePassiveAggressive(dynamic value) {
    if (value == null) return 'MEDIUM';
    final str = value.toString().toUpperCase();
    if (str.contains('DÜŞÜK') || str.contains('LOW')) return 'LOW';
    if (str.contains('ORTA') || str.contains('MEDIUM') || str.contains('MED')) {
      return 'MEDIUM';
    }
    if (str.contains('YÜKSEK') || str.contains('HIGH')) return 'HIGH';
    return 'MEDIUM';
  }

  static String _normalizeGaslighting(dynamic value) {
    if (value == null) return 'NOT DETECTED';
    final str = value.toString().toUpperCase();
    if (str.contains('TESPİT') || str.contains('DETECT')) return 'DETECTED';
    return 'NOT DETECTED';
  }

  static Future<AnalysisResult> analyzeText(String text) async {
    final language = await _getLanguage(text);

    try {
      final systemPrompt = language == 'tr'
          ? '''Sen keskin ama adil bir AI toksisite analizcisisin. TÜRKÇE cevap ver.

Verilen metni analiz et ve belirle:
1. Toksisite skoru (0-100): Bu mesaj ne kadar toksik/zararlı?
2. Pasif-agresif seviye (DÜŞÜK/ORTA/YÜKSEK): Gizli düşmanlık var mı?
3. Gaslighting tespiti (TESPİT EDİLDİ/TESPİT EDİLMEDİ): Manipülatif mi?
4. Kısa, keskin ama komik bir yorum (1 cümle, Twitter tarzı, TÜRKÇE)

SADECE bu formatta geçerli JSON döndür:
{
  "toxicity": 45,
  "passive_aggressive": "ORTA",
  "gaslighting": "TESPİT EDİLMEDİ",
  "comment": "Türkçe keskin yorumun buraya"
}'''
          : '''You are a sarcastic but fair AI toxicity analyzer.

Analyze the given text and determine:
1. Toxicity score (0-100): How toxic/harmful is this message?
2. Passive-aggressive level (LOW/MEDIUM/HIGH): Is there hidden hostility?
3. Gaslighting detection (DETECTED/NOT DETECTED): Is this manipulative?
4. A short, savage but funny comment (1 sentence, Twitter-style)

Respond ONLY with valid JSON:
{
  "toxicity": 45,
  "passive_aggressive": "MEDIUM",
  "gaslighting": "NOT DETECTED",
  "comment": "Your savage comment here"
}''';

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'llama-3.3-70b-versatile',
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': 'Analyze: "$text"'}
              ],
              'temperature': 0.8,
              'max_tokens': 200,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];

        if (content != null) {
          try {
            final analysisJson = jsonDecode(content.trim());
            return AnalysisResult(
              toxicity: _toInt(analysisJson['toxicity'], 50),
              passiveAggressive: _normalizePassiveAggressive(
                  analysisJson['passive_aggressive']),
              gaslighting: _normalizeGaslighting(analysisJson['gaslighting']),
              comment:
                  _toStr(analysisJson['comment'], _getRandomComment(language)),
            );
          } catch (e) {
            return _getMockAnalysis(text, language);
          }
        }
      }
      return _getMockAnalysis(text, language);
    } catch (e) {
      return _getMockAnalysis(text, language);
    }
  }

  static Future<Map<String, dynamic>> compareTexts(
      String text1, String text2) async {
    final language = await _getLanguage(text1 + text2);

    try {
      final systemPrompt = language == 'tr'
          ? '''Sen iki mesajı karşılaştıran bir AI analizcisisin. TÜRKÇE cevap ver.

İki mesajı karşılaştır ve şunu belirle:
- Hangisi daha toksik?
- Hangisi daha pasif-agresif?
- Hangisi daha manipülatif?
- Kısa bir karşılaştırma yorumu

SADECE bu JSON formatında cevap ver:
{
  "message1": {
    "toxicity": 45,
    "passive_aggressive": "ORTA",
    "gaslighting": "TESPİT EDİLMEDİ",
    "comment": "Mesaj 1 için yorum"
  },
  "message2": {
    "toxicity": 65,
    "passive_aggressive": "YÜKSEK",
    "gaslighting": "TESPİT EDİLDİ",
    "comment": "Mesaj 2 için yorum"
  },
  "winner": "message2",
  "comparison": "Kısa karşılaştırma yorumu"
}'''
          : '''You are an AI that compares two messages for toxicity.

Compare both messages and determine:
- Which is more toxic?
- Which is more passive-aggressive?
- Which is more manipulative?
- A brief comparison comment

Respond ONLY with this JSON:
{
  "message1": {
    "toxicity": 45,
    "passive_aggressive": "MEDIUM",
    "gaslighting": "NOT DETECTED",
    "comment": "Comment for message 1"
  },
  "message2": {
    "toxicity": 65,
    "passive_aggressive": "HIGH",
    "gaslighting": "DETECTED",
    "comment": "Comment for message 2"
  },
  "winner": "message2",
  "comparison": "Brief comparison"
}''';

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'llama-3.3-70b-versatile',
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {
                  'role': 'user',
                  'content': 'Message 1: "$text1"\n\nMessage 2: "$text2"'
                }
              ],
              'temperature': 0.8,
              'max_tokens': 400,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];

        if (content != null) {
          try {
            final parsed = jsonDecode(content.trim());
            return _sanitizeComparisonResult(parsed, language);
          } catch (e) {
            return _getMockComparison(text1, text2, language);
          }
        }
      }
      return _getMockComparison(text1, text2, language);
    } catch (e) {
      return _getMockComparison(text1, text2, language);
    }
  }

  static Map<String, dynamic> _sanitizeComparisonResult(
      Map<String, dynamic> raw, String language) {
    return {
      'message1': _sanitizeMessageResult(raw['message1'], language),
      'message2': _sanitizeMessageResult(raw['message2'], language),
      'winner': _toStr(raw['winner'], 'message1'),
      'comparison': _toStr(raw['comparison'], 'Both messages analyzed.'),
    };
  }

  static Map<String, dynamic> _sanitizeMessageResult(
      dynamic raw, String language) {
    if (raw == null || raw is! Map<String, dynamic>) {
      return {
        'toxicity': 50,
        'passive_aggressive': 'MEDIUM',
        'gaslighting': 'NOT DETECTED',
        'comment': _getRandomComment(language),
      };
    }
    return {
      'toxicity': _toInt(raw['toxicity'], 50),
      'passive_aggressive':
          _normalizePassiveAggressive(raw['passive_aggressive']),
      'gaslighting': _normalizeGaslighting(raw['gaslighting']),
      'comment': _toStr(raw['comment'], _getRandomComment(language)),
    };
  }

  static AnalysisResult _getMockAnalysis(String text, String language) {
    final textLower = text.toLowerCase();
    final keywords = _keywords[language] ?? _keywords['en']!;

    int toxicity = 20;
    String passive = 'LOW';
    String gaslighting = 'NOT DETECTED';

    int toxicCount = 0;
    for (var word in keywords['toxic']!) {
      if (textLower.contains(word)) {
        toxicCount++;
        toxicity += 15;
      }
    }

    int passiveCount = 0;
    for (var phrase in keywords['passive_aggressive']!) {
      if (textLower.contains(phrase)) {
        passiveCount++;
        toxicity += 8;
      }
    }

    if (passiveCount >= 3) {
      passive = 'HIGH';
    } else if (passiveCount >= 1) {
      passive = 'MEDIUM';
    }

    for (var phrase in keywords['gaslighting']!) {
      if (textLower.contains(phrase)) {
        gaslighting = 'DETECTED';
        toxicity += 20;
        break;
      }
    }

    final exclamationCount = text.split('!').length - 1;
    if (exclamationCount > 2) toxicity += 10;
    if (exclamationCount > 4) toxicity += 10;

    final questionCount = text.split('?').length - 1;
    if (questionCount > 3) {
      passive = 'HIGH';
      toxicity += 12;
    }

    final textLen = text.isNotEmpty ? text.length : 1;
    final upperCaseRatio =
        text.replaceAll(RegExp(r'[^A-ZÇĞİÖŞÜ]'), '').length / textLen;
    if (upperCaseRatio > 0.5 && text.length > 10) {
      toxicity += 15;
    }

    if (text.contains('...') || text.contains('???') || text.contains('!!!')) {
      toxicity += 8;
      if (passive == 'LOW') {
        passive = 'MEDIUM';
      }
    }

    final sarcasticPatterns = language == 'tr'
        ? ['evet evet', 'tabii tabii', 'harika harika', 'süper süper']
        : ['yeah yeah', 'sure sure', 'great great', 'right right'];

    for (var pattern in sarcasticPatterns) {
      if (textLower.contains(pattern)) {
        passive = 'HIGH';
        toxicity += 12;
        break;
      }
    }

    if (text.length < 10 && toxicCount > 0) {
      toxicity += 10;
    }

    toxicity = toxicity.clamp(0, 100);

    return AnalysisResult(
      toxicity: toxicity,
      passiveAggressive: passive,
      gaslighting: gaslighting,
      comment: _getRandomComment(language),
    );
  }

  static Map<String, dynamic> _getMockComparison(
      String text1, String text2, String language) {
    final result1 = _getMockAnalysis(text1, language);
    final result2 = _getMockAnalysis(text2, language);

    final winner =
        result1.toxicity > result2.toxicity ? 'message1' : 'message2';
    final diff = (result1.toxicity - result2.toxicity).abs();

    String comparison;
    if (language == 'tr') {
      if (diff < 10) {
        comparison = 'İki mesaj da eşit derecede toksik. Bu bir beraberlik!';
      } else if (diff < 30) {
        comparison =
            'Mesaj ${winner == 'message1' ? '1' : '2'} hafif önde ama ikisi de problemli.';
      } else {
        comparison =
            'Mesaj ${winner == 'message1' ? '1' : '2'} açık ara kazandı. Diğeri yanında masum kalıyor.';
      }
    } else {
      if (diff < 10) {
        comparison = "Both messages are equally toxic. It's a tie!";
      } else if (diff < 30) {
        comparison =
            'Message ${winner == 'message1' ? '1' : '2'} is slightly worse, but both are problematic.';
      } else {
        comparison =
            'Message ${winner == 'message1' ? '1' : '2'} wins by a landslide. The other seems innocent in comparison.';
      }
    }

    return {
      'message1': {
        'toxicity': result1.toxicity,
        'passive_aggressive': result1.passiveAggressive,
        'gaslighting': result1.gaslighting,
        'comment': result1.comment,
      },
      'message2': {
        'toxicity': result2.toxicity,
        'passive_aggressive': result2.passiveAggressive,
        'gaslighting': result2.gaslighting,
        'comment': result2.comment,
      },
      'winner': winner,
      'comparison': comparison,
    };
  }

  // Kategori ile analiz
  static Future<AnalysisResult> analyzeWithCategory(
      String text, String categoryContext, String language) async {
    try {
      final systemPrompt = language == 'tr'
          ? '''Sen keskin ama adil bir AI toksisite analizcisisin. TÜRKÇE cevap ver.

Bu mesaj $categoryContext. Bu bağlamı göz önünde bulundurarak analiz et.

Verilen metni analiz et ve belirle:
1. Toksisite skoru (0-100): Bu mesaj ne kadar toksik/zararlı?
2. Pasif-agresif seviye (DÜŞÜK/ORTA/YÜKSEK): Gizli düşmanlık var mı?
3. Gaslighting tespiti (TESPİT EDİLDİ/TESPİT EDİLMEDİ): Manipülatif mi?
4. Bu kategoriye özel keskin ama komik bir yorum (1 cümle, Twitter tarzı, TÜRKÇE)

SADECE bu formatta geçerli JSON döndür:
{
  "toxicity": 45,
  "passive_aggressive": "ORTA",
  "gaslighting": "TESPİT EDİLMEDİ",
  "comment": "Türkçe keskin yorumun buraya"
}'''
          : '''You are a sarcastic but fair AI toxicity analyzer.

This is $categoryContext. Analyze with this context in mind.

Analyze the given text and determine:
1. Toxicity score (0-100): How toxic/harmful is this message?
2. Passive-aggressive level (LOW/MEDIUM/HIGH): Is there hidden hostility?
3. Gaslighting detection (DETECTED/NOT DETECTED): Is this manipulative?
4. A category-specific savage but funny comment (1 sentence, Twitter-style)

Respond ONLY with valid JSON:
{
  "toxicity": 45,
  "passive_aggressive": "MEDIUM",
  "gaslighting": "NOT DETECTED",
  "comment": "Your savage comment here"
}''';

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'llama-3.3-70b-versatile',
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': 'Analyze: "$text"'}
              ],
              'temperature': 0.8,
              'max_tokens': 250,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];

        if (content != null) {
          try {
            final analysisJson = jsonDecode(content.trim());
            return AnalysisResult(
              toxicity: _toInt(analysisJson['toxicity'], 50),
              passiveAggressive: _normalizePassiveAggressive(
                  analysisJson['passive_aggressive']),
              gaslighting: _normalizeGaslighting(analysisJson['gaslighting']),
              comment:
                  _toStr(analysisJson['comment'], _getRandomComment(language)),
            );
          } catch (e) {
            return _getMockAnalysis(text, language);
          }
        }
      }
      return _getMockAnalysis(text, language);
    } catch (e) {
      return _getMockAnalysis(text, language);
    }
  }

  // Mesaj dönüştürücü
  static Future<String> transformMessage(
      String text, String transformType, String language) async {
    try {
      String instruction;

      if (language == 'tr') {
        switch (transformType) {
          case 'less_toxic':
            instruction =
                'Bu mesajı daha nazik, anlayışlı ve yapıcı bir şekilde yeniden yaz. Aynı mesajı ilet ama toksik olmadan.';
            break;
          case 'more_toxic':
            instruction =
                'Bu mesajı daha dramatik, pasif-agresif ve sassy bir şekilde yeniden yaz. Eğlenceli ama fazla ileri gitme.';
            break;
          case 'professional':
            instruction =
                'Bu mesajı profesyonel iş ortamına uygun şekilde yeniden yaz. Resmi ama soğuk değil.';
            break;
          case 'friendly':
            instruction =
                'Bu mesajı samimi, sıcak ve arkadaşça bir şekilde yeniden yaz.';
            break;
          default:
            instruction = 'Bu mesajı daha iyi bir şekilde yeniden yaz.';
        }
      } else {
        switch (transformType) {
          case 'less_toxic':
            instruction =
                'Rewrite this message in a kinder, more understanding and constructive way. Convey the same message but without being toxic.';
            break;
          case 'more_toxic':
            instruction =
                'Rewrite this message in a more dramatic, passive-aggressive and sassy way. Make it fun but don\'t go too far.';
            break;
          case 'professional':
            instruction =
                'Rewrite this message appropriately for a professional work environment. Formal but not cold.';
            break;
          case 'friendly':
            instruction =
                'Rewrite this message in a warm, friendly and approachable way.';
            break;
          default:
            instruction = 'Rewrite this message in a better way.';
        }
      }

      final systemPrompt = language == 'tr'
          ? '''Sen bir mesaj dönüştürme uzmanısın. $instruction

SADECE dönüştürülmüş mesajı döndür, başka açıklama yapma.'''
          : '''You are a message transformation expert. $instruction

Return ONLY the transformed message, no other explanation.''';

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'llama-3.3-70b-versatile',
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': text}
              ],
              'temperature': 0.9,
              'max_tokens': 300,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content != null) {
          return content.trim();
        }
      }
      return language == 'tr'
          ? 'Dönüştürme başarısız oldu.'
          : 'Transformation failed.';
    } catch (e) {
      return language == 'tr'
          ? 'Dönüştürme başarısız oldu.'
          : 'Transformation failed.';
    }
  }
}
