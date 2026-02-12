import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/language_service.dart';

class DownloadProgressWidget extends StatelessWidget {
  final ValueNotifier<double> progressNotifier;
  final translations = getIt<LanguageService>().translations.value;

  DownloadProgressWidget({super.key, required this.progressNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: progressNotifier,
      builder: (context, progress, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(progress < 1.0
                ? translations['downloading']!
                : translations['downloadCompleted']!),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 4),
            Text('${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12)),
          ],
        );
      },
    );
  }
}
