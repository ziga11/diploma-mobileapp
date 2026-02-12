import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/shared/domain/user.dart';
import 'package:logger/logger.dart';
import 'package:xml/xml.dart' as xml;

String defaultLogin(User user) {
  String firstnameSubstring = capitalize(user.firstName.substring(0, 2));
  String year = "${user.birthDate.year}";
  String lastnameSubString = capitalize(user.lastName.substring(0, 2));

  return "$firstnameSubstring$year$lastnameSubString";
}

Future<void> saveToSecureStorage(
    {required int aId,
    required int uId,
    required String secureToken,
    required String repeatToken}) async {
  final storage = getIt<FlutterSecureStorage>();
  await storage.write(key: "acc_id", value: "$aId");
  await storage.write(key: "user_id", value: "$uId");
  await storage.write(key: "secure_token", value: secureToken);
  await storage.write(key: "repeat_token", value: repeatToken);
}

Future<Map<String, dynamic>> loadJson(String uri) async {
  try {
    String jsonString = await rootBundle.loadString(uri);
    final Map<String, dynamic> decoded = jsonDecode(jsonString);

    return decoded;
  } catch (e) {
    Logger().e("Error loading Json file - $uri: $e");
    return {};
  }
}

String capitalize(String text) {
  return text
      .split(' ')
      .map((word) => word.isNotEmpty
          ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
          : '')
      .join(' ');
}

Map<String, String> splitSvgByPathId(String svg) {
  final doc = xml.XmlDocument.parse(svg);

  final svgEl = doc.rootElement;
  final viewBox = svgEl.getAttribute('viewBox')!;
  final defs = svgEl.getElement('defs')?.toXmlString() ?? '';

  final result = <String, String>{};

  for (final path in svgEl.findAllElements('path')) {
    final id = path.getAttribute('id');
    if (id == null) continue;

    result[id] = '''
        <svg viewBox="$viewBox" xmlns="http://www.w3.org/2000/svg">
          $defs
          ${path.toXmlString()}
        </svg>
        ''';
  }

  return result;
}

bool isEUEFTA(String country) {
  List<String> euEfta = [
    // (EU)
    "Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic",
    "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary",
    "Ireland", "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta",
    "Netherlands", "Poland", "Portugal", "Romania", "Slovakia", "Slovenia",
    "Spain", "Sweden",
    // (EFTA)
    "Iceland", "Liechtenstein", "Norway", "Switzerland"
  ];

  return euEfta.contains(capitalize(country));
}
