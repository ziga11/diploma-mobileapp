class JobListing {
  final String company;
  final String industry;
  final String salary;
  final String location;
  final DateTime date;
  final Map<String, String> titles;
  final Map<String, String> descriptions;
  final Map<String, String> requirements;
  final Map<String, String> employmentType;

  JobListing({
    required this.company,
    required this.industry,
    required this.salary,
    required this.date,
    required this.location,
    required this.titles,
    required this.descriptions,
    required this.requirements,
    required this.employmentType,
  });

  factory JobListing.fromJson(dynamic json) {
    final en = json["en"] ?? {};
    final si = json["si"] ?? {};
    final bs = json["bs"] ?? {};

    List<String> dateArray = json["date"].split(".");
    final dateYear = int.parse(dateArray[2]);
    final dateMonth = int.parse(dateArray[1]);
    final dateDay = int.parse(dateArray[0]);

    return JobListing(
      company: json["company"] ?? "",
      location: json["location"] ?? "",
      industry: json["industry"] ?? "",
      salary: json["salary"] ?? "",
      date: DateTime.utc(dateYear, dateMonth, dateDay),
      titles: {
        "si": si["title"] ?? "",
        "bs": bs["title"] ?? en["title"] ?? si["title"] ?? "",
        "en": en["title"] ?? si["title"] ?? bs["title"] ?? "",
      },
      descriptions: {
        "si": si["description"] ?? "",
        "bs": bs["description"] ?? si["description"] ?? en["description"] ?? "",
        "en": en["description"] ?? si["description"] ?? bs["description"] ?? "",
      },
      requirements: {
        "si": si["requirements"] ?? "",
        "bs": bs["requirements"] ??
            si["requirements"] ??
            en["requirements"] ??
            "",
        "en": en["requirements"] ??
            si["requirements"] ??
            bs["requirements"] ??
            "",
      },
      employmentType: {
        "si": si["employment_type"] ?? "",
        "bs": bs["employment_type"] ??
            si["employment_type"] ??
            en["employment_type"] ??
            "",
        "en": en["employment_type"] ??
            si["employment_type"] ??
            bs["employment_type"] ??
            "",
      },
    );
  }
}
