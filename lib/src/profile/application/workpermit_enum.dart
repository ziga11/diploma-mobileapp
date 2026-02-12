enum WorkPermit {
  none,
  temporary,
  permanent;

  String get translationKey {
    return switch (this) {
      WorkPermit.none => "none",
      WorkPermit.temporary => "temporary",
      WorkPermit.permanent => "permanent",
    };
  }

  String get englishValue {
    return switch (this) {
      WorkPermit.none => "None",
      WorkPermit.temporary => "Temporary",
      WorkPermit.permanent => "Permanent",
    };
  }
}
