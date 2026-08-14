enum ContentCategory {
  lishe('Lishe', 'assets/images/lishe.jpg', 'restaurant'),
  usingizi('Usingizi', 'assets/images/usingizi.jpg', 'bedtime'),
  mazoezi('Mazoezi', 'assets/images/mazoezi.jpg', 'fitness_center'),
  usalama('Usalama', 'assets/images/usalama.jpg', 'health_and_safety'),
  uzaziWaMpango('Uzazi wa Mpango', 'assets/images/uzazi_wa_mpango.jpg', 'family_restroom'),
  jumla('Jumla', 'assets/images/jumla.jpg', 'info');

  final String label;
  final String assetPath;
  final String iconName;
  const ContentCategory(this.label, this.assetPath, this.iconName);

  /// Guesses a category from Swahili keywords in generated text, since
  /// the on-device model doesn't return structured tags on its own.
  static ContentCategory fromKeywords(String text) {
    final lower = text.toLowerCase();
    if (_matches(lower, ['tunda', 'matunda', 'lishe', 'chakula', 'kula', 'vitamini', 'madini'])) {
      return ContentCategory.lishe;
    }
    if (_matches(lower, ['usingizi', 'lala', 'kulala', 'kupumzika', 'pumzika'])) {
      return ContentCategory.usingizi;
    }
    if (_matches(lower, ['mazoezi', 'tembea', 'kutembea', 'zoezi'])) {
      return ContentCategory.mazoezi;
    }
    if (_matches(lower, ['usalama', 'hatari', 'dharura', 'dalili hatari'])) {
      return ContentCategory.usalama;
    }
    if (_matches(lower, ['uzazi wa mpango', 'mpango wa uzazi', 'uzazi'])) {
      return ContentCategory.uzaziWaMpango;
    }
    return ContentCategory.jumla;
  }

  static bool _matches(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));
}
