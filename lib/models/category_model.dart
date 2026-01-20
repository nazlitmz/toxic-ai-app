class MessageCategory {
  final String id;
  final String emoji;
  final String nameKey;
  final String contextEn;
  final String contextTr;

  const MessageCategory({
    required this.id,
    required this.emoji,
    required this.nameKey,
    required this.contextEn,
    required this.contextTr,
  });

  String getContext(String language) {
    return language == 'tr' ? contextTr : contextEn;
  }

  static const List<MessageCategory> categories = [
    MessageCategory(
      id: 'general',
      emoji: '💬',
      nameKey: 'category_general',
      contextEn: 'a general message',
      contextTr: 'genel bir mesaj',
    ),
    MessageCategory(
      id: 'ex',
      emoji: '💔',
      nameKey: 'category_ex',
      contextEn:
          'a message to/from an ex-partner. Look for manipulation, guilt-tripping, and emotional games',
      contextTr:
          'eski sevgiliye/sevgiliden bir mesaj. Manipülasyon, suçluluk yükleme ve duygusal oyunlara bak',
    ),
    MessageCategory(
      id: 'boss',
      emoji: '👔',
      nameKey: 'category_boss',
      contextEn:
          'a message to/from a boss. Look for power dynamics, passive-aggressive professionalism, and hidden threats',
      contextTr:
          'patrona/patrondan bir mesaj. Güç dinamiklerine, pasif-agresif profesyonelliğe ve gizli tehditlere bak',
    ),
    MessageCategory(
      id: 'parent',
      emoji: '👨‍👩‍👧',
      nameKey: 'category_parent',
      contextEn:
          'a message to/from a parent. Look for guilt-tripping, emotional manipulation, and generational trauma patterns',
      contextTr:
          'anne/babaya veya anne/babadan bir mesaj. Suçluluk yükleme, duygusal manipülasyon ve kuşaklar arası travma kalıplarına bak',
    ),
    MessageCategory(
      id: 'friend',
      emoji: '👥',
      nameKey: 'category_friend',
      contextEn:
          'a message in a friend group. Look for social dynamics, exclusion tactics, and group pressure',
      contextTr:
          'arkadaş grubundaki bir mesaj. Sosyal dinamiklere, dışlama taktiklerine ve grup baskısına bak',
    ),
    MessageCategory(
      id: 'partner',
      emoji: '❤️',
      nameKey: 'category_partner',
      contextEn:
          'a message to/from a romantic partner. Look for relationship red flags, communication issues, and emotional patterns',
      contextTr:
          'sevgiliye/sevgiliden bir mesaj. İlişki kırmızı bayraklarına, iletişim sorunlarına ve duygusal kalıplara bak',
    ),
    MessageCategory(
      id: 'coworker',
      emoji: '🏢',
      nameKey: 'category_coworker',
      contextEn:
          'a message to/from a coworker. Look for office politics, passive-aggressive behavior, and professional boundaries',
      contextTr:
          'iş arkadaşına/iş arkadaşından bir mesaj. Ofis politikalarına, pasif-agresif davranışlara ve profesyonel sınırlara bak',
    ),
  ];
}
