class User {
  int id;
  String firstName;
  String lastName;
  String group;
  String country;
  String mobile;
  String workPermit;
  String address;
  DateTime birthDate;

  User(
      {required this.id,
      required this.mobile,
      required this.firstName,
      required this.group,
      required this.lastName,
      required this.country,
      required this.workPermit,
      required this.address,
      required this.birthDate});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] as int,
      birthDate: DateTime.parse(json['birthdate'] as String),
      mobile: json['mobile'] as String,
      group: json["group"] as String,
      firstName: json['firstname'] as String,
      lastName: json['lastname'] as String,
      workPermit: json['work_permit'] as String,
      address: json['address'] as String,
      country: json['country_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'firstname': firstName,
      'lastname': lastName,
      'country_name': country,
      'address': address,
      "mobile": mobile,
      'work_permit': workPermit,
      'group': group,
      'birthdate': birthDate.toUtc().toIso8601String()
    };
  }

  bool equal(User other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          id == other.id &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          group == other.group &&
          country == other.country &&
          mobile == other.mobile &&
          workPermit == other.workPermit &&
          address == other.address &&
          birthDate == other.birthDate;

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? mobile,
    String? address,
    String? workPermit,
    String? country,
    String? group,
  }) {
    return User(
        id: id ?? this.id,
        mobile: mobile ?? this.mobile,
        firstName: firstName ?? this.firstName,
        group: group ?? this.group,
        lastName: lastName ?? this.lastName,
        country: country ?? this.country,
        workPermit: workPermit ?? this.workPermit,
        address: address ?? this.address,
        birthDate: birthDate ?? this.birthDate);
  }

  @override
  String toString() {
    return "$firstName $lastName";
  }
}
