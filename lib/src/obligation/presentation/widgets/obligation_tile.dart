import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/obligation/domain/obligation.dart';
import 'package:diplomaapp/src/obligation/domain/user_obligation.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/data/document_repository.dart';
import 'package:diplomaapp/src/document/domain/document.dart';
import 'package:diplomaapp/src/obligation/application/obligation_controller.dart';
import 'package:diplomaapp/src/obligation/presentation/obligation_page.dart';
import 'package:diplomaapp/src/obligation/presentation/widgets/textfield.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';

class ObligationTile extends StatefulWidget {
  final ObligationRecord entity;
  final Map<String, String> translations;
  final bool highlighted;
  const ObligationTile(
      {super.key,
      required this.entity,
      required this.translations,
      this.highlighted = false});

  @override
  State<ObligationTile> createState() => ObligationTileState();
}

class ObligationTileState extends State<ObligationTile> {
  final user = getIt<UserService>().currentUser!;
  final langCode = getIt<LanguageService>().current.code;

  final controller = ObligationController();

  final dRepo = getIt<DocumentRepository>();

  bool infoPressed = false;
  late final Obligation definition;
  late final ValueNotifier<ObligationRecord> obligationRecord;

  @override
  void initState() {
    super.initState();

    obligationRecord = ValueNotifier(widget.entity);
    definition = obligationRecord.value.definition;
  }

  @override
  Widget build(BuildContext context) {
    final langCode = getIt<LanguageService>().current.code;

    final translations = widget.translations;
    String title = definition.translations[langCode]!.title;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width(context) * 0.04, vertical: height(context) * 0.02),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 96),
        child: ValueListenableBuilder(
            valueListenable: obligationRecord,
            builder: (context, values, _) {
              Color bgColor =
                  controller.getTileColor(obligationRecord.value.status);

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: widget.highlighted
                      ? Border.all(color: ColorTheme.bgHighlight, width: 2)
                      : null,
                  boxShadow: widget.highlighted
                      ? [
                          BoxShadow(
                            color: ColorTheme.bgHighlight,
                            blurRadius: 6,
                            spreadRadius: 3,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: RichText(
                          text: TextSpan(
                              text: title,
                              style: Theme.of(context).textTheme.titleMedium!),
                          overflow: TextOverflow.visible,
                          maxLines: null,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (obligationRecord.value.docIds.isNotEmpty &&
                            obligationRecord.value.status == "Pending")
                          TextButton(
                            onPressed: () async => controller.deleteDocuments(
                              on: obligationRecord,
                            ),
                            child: Text(
                              translations["remove"]!,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (obligationRecord.value.status == "Incomplete" &&
                            definition.isUploadble &&
                            user.group.toLowerCase() != "tujina")
                          TextButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);

                              FilePickerResult? result = await FilePicker
                                  .platform
                                  .pickFiles(allowMultiple: true);
                              if (result == null) return;

                              try {
                                controller.uploadDocuments(
                                  obNotifier: obligationRecord,
                                  title: title,
                                  files: result.files,
                                );
                              } catch (e) {
                                messenger.showSnackBar(
                                    SnackBar(content: Text(e.toString())));
                              }
                            },
                            child: Text(
                              translations["upload"]!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        if (obligationRecord.value.status == "Incomplete" &&
                            definition.hasTextField)
                          TextButton(
                            onPressed: () async {
                              String? textFieldVal = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return TextFieldPopup(
                                      obligation: definition,
                                    );
                                  });
                              if (textFieldVal?.isEmpty ?? false) return;
                              controller.setTextValue(
                                textValue: textFieldVal!,
                                on: obligationRecord,
                                title: title,
                              );
                            },
                            child: Text(
                              translations["fill"]!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        TextButton(
                          onPressed: () async {
                            if (infoPressed) return;
                            infoPressed = true;
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              Document? document = await dRepo.fetchDocById(
                                definition.exampleDocId,
                              );
                              if (context.mounted) {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      ObligationPage(
                                    obligation: definition,
                                    document: document,
                                  ),
                                );
                              }
                            } catch (e) {
                              messenger.showSnackBar(
                                  SnackBar(content: Text(e.toString())));
                            } finally {
                              infoPressed = false;
                            }
                          },
                          child: const Text(
                            "info",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
