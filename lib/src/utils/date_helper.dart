import 'package:intl/intl.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';

Map<String, DateTime> _getDateBoundaries() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));
  final daysSinceMonday = today.weekday - 1;
  final startOfWeek = today.subtract(Duration(days: daysSinceMonday));
  final endOfWeek = startOfWeek.add(const Duration(days: 7));

  return {
    'today': today,
    'yesterday': yesterday,
    'tomorrow': tomorrow,
    'startOfWeek': startOfWeek,
    'endOfWeek': endOfWeek,
  };
}

String formatDateTime(DateTime date) {
  final bounds = _getDateBoundaries();
  final translations = getIt<LanguageService>().translations.value;

  if (date.isAfter(bounds['yesterday']!) && date.isBefore(bounds['today']!)) {
    return translations["yesterday"]!;
  }
  if (date.isAfter(bounds['today']!) && date.isBefore(bounds['tomorrow']!)) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
  if (date.isAfter(bounds['startOfWeek']!) &&
      date.isBefore(bounds['endOfWeek']!)) {
    return DateFormat('EEEE').format(date);
  }

  return formatDate(date);
}

String getWeekDay(DateTime date) {
  final bounds = _getDateBoundaries();
  final translations = getIt<LanguageService>().translations.value;

  if (date.isAfter(bounds['yesterday']!) && date.isBefore(bounds['today']!)) {
    return translations["yesterday"]!;
  }
  if (date.isAfter(bounds['today']!) && date.isBefore(bounds['tomorrow']!)) {
    return translations["today"]!;
  }
  if (date.isAfter(bounds['startOfWeek']!) &&
      date.isBefore(bounds['endOfWeek']!)) {
    return DateFormat('EEEE').format(date);
  }

  return formatDate(date);
}

String formatDate(DateTime date) {
  return "${date.day}.${date.month}.${date.year}";
}

String formatDateMonthYear(DateTime date) {
  return DateFormat('MMMM yyyy').format(date);
}
