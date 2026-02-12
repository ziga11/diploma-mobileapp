enum Language {
  slovene('si', 'Slovenščina', 'assets/si_icon.png'),
  bosnian('bs', 'Bosanski', 'assets/bs_icon.png'),
  english('en', 'English', 'assets/en_icon.png');

  final String code;
  final String nativeName;
  final String iconUri;

  const Language(this.code, this.nativeName, this.iconUri);

  factory Language.from(String value) {
    return Language.values.firstWhere(
      (l) => l.code == value || l.name == value,
      orElse: () => Language.english,
    );
  }
}
