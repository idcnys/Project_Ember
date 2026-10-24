enum ClueRarity { normal, hidden, master }

class ClueData {
  final String id;
  final String code;
  final String type;
  final ClueRarity rarity;
  final String title;
  final String desc;
  bool unlocked;

  ClueData({
    required this.id,
    required this.code,
    required this.type,
    required this.rarity,
    required this.title,
    required this.desc,
    this.unlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'unlocked': unlocked,
      };
}
