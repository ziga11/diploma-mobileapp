import 'package:diplomaapp/src/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/domain/document.dart';
import 'package:diplomaapp/src/document/presentation/doc_viewer.dart';
import 'package:diplomaapp/src/obligation/application/obligation_controller.dart';
import 'package:diplomaapp/src/obligation/domain/obligation.dart';
import 'package:diplomaapp/src/obligation/presentation/widgets/download_snackbar.dart';
import 'package:diplomaapp/src/obligation/presentation/widgets/page_navigation.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';

class ObligationPage extends StatefulWidget {
  final Obligation obligation;
  final Document? document;
  const ObligationPage({
    super.key,
    required this.obligation,
    required this.document,
  });

  @override
  State<ObligationPage> createState() => _ObligationPageState();
}

class _ObligationPageState extends State<ObligationPage> {
  final PageController _pageController = PageController();
  int pageCount = 2;

  final langCode = getIt<LanguageService>().current.code;

  @override
  Widget build(BuildContext context) {
    if (widget.document == null) pageCount = 1;
    String title = widget.obligation.translations[langCode]!.title;
    String body = widget.obligation.translations[langCode]!.text;

    final Widget? docViewer = widget.document == null
        ? null
        : DocumentViewerPage(
            document: widget.document!,
            showAppBar: false,
          );

    return AlertDialog(
      elevation: 3,
      insetPadding: EdgeInsets.symmetric(
        horizontal: width(context) * 0.03,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.all(
          Radius.circular(8),
        ),
      ),
      content: SizedBox(
        width: width(context),
        height: height(context) * 0.85,
        child: Scaffold(
          body: ValueListenableBuilder(
              valueListenable: getIt<LanguageService>().translations,
              builder: (context, translations, _) {
                return Column(
                  children: [
                    Expanded(
                      child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  title,
                                  maxLines: null,
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (body.isNotEmpty)
                                Expanded(
                                  flex: 20,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Text(
                                          widget.obligation
                                              .translations[langCode]!.text,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                height: 1.0,
                                              ),
                                        ),
                                        SizedBox(
                                          height: height(context) * 0.05,
                                        ),
                                        Text(
                                          translations["documentsTranslated"]!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                height: 1.0,
                                              ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (widget.document != null)
                            Expanded(child: docViewer!),
                        ],
                      ),
                    ),
                    if (widget.obligation.googleFileId != null)
                      downloadWidget(translations, title),
                    if (pageCount != 1)
                      PageNavigator(
                        pageController: _pageController,
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(width(context) * 0.85, 50),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        translations["iUnderstand"]!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget downloadWidget(Map<String, String> translations, String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: height(context) * 0.03),
      decoration: BoxDecoration(
        color: ColorTheme.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorTheme.secondaryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final controller = ObligationController();
            final messenger = ScaffoldMessenger.of(context);

            messenger.showSnackBar(
              SnackBar(
                content: DownloadProgressWidget(
                  progressNotifier: controller.downloadProgress,
                ),
                duration: const Duration(hours: 1),
              ),
            );

            controller.startDownload(
              googleFileId: widget.obligation.googleFileId!,
              fileName: title,
              context: context,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_rounded,
                  color: ColorTheme.secondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  translations["downloadFile"]!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
