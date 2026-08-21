enum ContentCategory {
  lishe('Lishe', 'restaurant'),
  usingizi('Usingizi', 'bedtime'),
  mazoezi('Mazoezi', 'fitness_center'),
  usalama('Usalama', 'health_and_safety'),
  uzaziWaMpango('Uzazi wa Mpango', 'family_restroom'),
  jumla('Jumla', 'info');

  final String label;
  final String iconName;
  const ContentCategory(this.label, this.iconName);

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
