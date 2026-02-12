import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/data/document_repository.dart';
import 'package:diplomaapp/src/request/application/request_controller.dart';
import 'package:diplomaapp/src/request/data/request_repository.dart';
import 'package:diplomaapp/src/request/domain/request.dart';
import 'package:diplomaapp/src/request/domain/request_type_enum.dart';
import 'package:diplomaapp/src/request/domain/timeline_enum.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/data/slack_repository.dart';
import 'package:diplomaapp/src/shared/data/hashed_token_repository.dart';
import 'package:diplomaapp/src/shared/domain/message_content.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/shared/widgets/menu_button.dart';
import 'package:diplomaapp/src/utils/other.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';

class SendMessagePage extends StatefulWidget {
  const SendMessagePage({super.key});

  @override
  State<SendMessagePage> createState() => SendMessagePageState();
}

class SendMessagePageState extends State<SendMessagePage> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController msgText = TextEditingController();
  late List<RequestType> requestTypeList;

  final mRepo = getIt<MessageRepository>();
  final sRepo = getIt<SlackRepository>();
  final tRepo = getIt<HashedTokenRepository>();
  final dRepo = getIt<DocumentRepository>();
  final isLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<FilePickerResult?> fileNotiifer = ValueNotifier(null);

  RequestType? requestType;
  RequestTimeline? timeline;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: getIt<LanguageService>().translations,
        builder: (context, translations, _) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: DiplomaAppbar(),
            body: Container(
              padding: EdgeInsets.only(bottom: 15),
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width(context) * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(
                            top: 10, bottom: height(context) * 0.05),
                        child: Title(
                          color: ColorTheme.white,
                          child: Text(
                            translations["applicationSubmission"]!
                                .toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(fontSize: 20),
                          ),
                        ),
                      ),
                      ValueListenableBuilder(
                          valueListenable: fileNotiifer,
                          builder: (context, fileResult, _) {
                            return Column(children: [
                              requestTypeDropdown(translations),
                              if (requestType == RequestType.signedPayroll)
                                timelineDropdown(translations),
                              if (requestType == RequestType.creditForm)
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    translations["payrollPasswordMessage"]!,
                                  ),
                                ),
                              if (requestType == RequestType.payrollPassword)
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    translations["payrollPasswordMessage"]!,
                                  ),
                                ),
                              if (requestType == RequestType.other)
                                otherTextField(translations),
                              if (requestType?.isFileRequired ?? false) ...[
                                if (fileResult != null)
                                  ...fileResult.files.map(
                                    (file) => Padding(
                                      key: ValueKey(file.path),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.attach_file,
                                              size: 16,
                                              color: ColorTheme.secondaryColor),
                                          const SizedBox(width: 8),
                                          Text(
                                            file.name,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: ColorTheme.lightGray),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                gap(),
                                DiplomaBtn(
                                  title: capitalize(translations["upload"]!),
                                  size: Size(width(context) * 0.4, 30),
                                  fontSize: 15,
                                  bgColor: ColorTheme.secondaryColor,
                                  onPressed: () async {
                                    FilePickerResult? result = await FilePicker
                                        .platform
                                        .pickFiles(allowMultiple: true);
                                    if (result == null) return;

                                    fileNotiifer.value = result;
                                  },
                                ),
                              ]
                            ]);
                          }),
                    ],
                  ),
                ),
              ),
            ),
            bottomSheet: MediaQuery.of(context).viewInsets.bottom > 0
                ? null
                : submitRequest(translations),
          );
        });
  }

  Widget requestTypeDropdown(Map<String, String> translations) {
    return Container(
      width: width(context) * 0.8,
      padding: EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<RequestType>(
        icon: Icon(
          Icons.arrow_drop_down,
          size: 16,
        ),
        isExpanded: true,
        menuMaxHeight: height(context) * 0.6,
        initialValue: requestType,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        dropdownColor: ColorTheme.bgHighlight,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          label: Text(
            translations["requestType"]!,
            style: TextStyle(
                color: ColorTheme.lightGray, fontWeight: FontWeight.w700),
          ),
          filled: true,
          fillColor: ColorTheme.bgLight,
          hintText: translations["chooseRequest"],
        ),
        items: RequestType.values.map((RequestType type) {
          return DropdownMenuItem<RequestType>(
            value: type,
            child: AutoSizeText(
              translations[type.translationKey] ?? type.name,
              maxLines: 1,
              minFontSize: 10,
              maxFontSize: 15,
            ),
          );
        }).toList(),
        onChanged: (RequestType? e) {
          setState(() {
            requestType = e;
            if (e != RequestType.signedPayroll) {
              timeline = null;
            } else if (e != RequestType.other) {
              msgText.text = "";
            } else if (!(e?.isFileRequired ?? false)) {
              fileNotiifer.value = null;
            }
          });
        },
      ),
    );
  }

  Widget timelineDropdown(Map<String, String> translations) {
    return FractionallySizedBox(
      widthFactor: 0.7,
      child: DropdownButtonFormField<RequestTimeline>(
        icon: Icon(
          Icons.timeline,
        ),
        initialValue: timeline,
        hint: Text(
          translations["timeline"]!,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        dropdownColor: ColorTheme.bgHighlight,
        decoration: InputDecoration(
          filled: true,
          fillColor: ColorTheme.white.withValues(alpha: 0.2),
          labelText: translations["timeline"],
          hintText: translations["timeline"],
          floatingLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorTheme.white,
          ),
          floatingLabelAlignment: FloatingLabelAlignment.center,
        ),
        items: RequestTimeline.values.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e.label(translations)),
          );
        }).toList(),
        onChanged: (RequestTimeline? e) {
          setState(() {
            timeline = e;
          });
        },
      ),
    );
  }

  Widget otherTextField(Map<String, String> translations) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 5),
            alignment: Alignment.centerLeft,
            child: Text(
              translations["yourMsg"]!,
              style: TextStyle(
                  color: ColorTheme.white, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TextField(
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: ColorTheme.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
                hintText: translations["enterMsg"],
                fillColor: ColorTheme.bgLight,
                filled: true,
              ),
              cursorColor: ColorTheme.white,
              controller: msgText,
              style: TextStyle(
                color: ColorTheme.white,
              ),
              minLines: 5,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget submitRequest(Map<String, String> translations) {
    return Container(
      padding: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: ColorTheme.bgDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 12, horizontal: width(context) * 0.06),
        child: ValueListenableBuilder(
            valueListenable: isLoadingNotifier,
            builder: (context, isLoading, _) {
              return DiplomaBtn(
                isLoading: isLoading,
                title: translations["submitRequest"]!,
                size: Size(width(context) * 0.55, 40),
                fontSize: 14,
                bgColor: requestType == null
                    ? ColorTheme.primaryColor.withValues(alpha: 0.4)
                    : ColorTheme.primaryColor,
                onPressed: () async {
                  isLoadingNotifier.value = true;
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  try {
                    final title =
                        "${translations[requestType?.translationKey]} ${timeline?.label(translations) ?? ""}";
                    final text = msgText.text;

                    final userService = getIt<UserService>();
                    final langCode = getIt<LanguageService>().current.code;

                    final msg = Message(
                        sender: userService.currentUser!,
                        recipient: userService.infoUser.value!,
                        messageContent: {
                          langCode: MessageContent(title: title, text: text)
                        });

                    await RequestController().sendRequest(
                      requestType: requestType,
                      msg: msg,
                      files: fileNotiifer.value?.files,
                    );

                    navigator.pop(true);
                  } catch (e) {
                    String errorKey =
                        e.toString().replaceAll('Exception: ', '');

                    messenger.showSnackBar(
                        SnackBar(content: Text(translations[errorKey]!)));
                  } finally {
                    isLoadingNotifier.value = false;
                  }
                },
              );
            }),
      ),
    );
  }

  Widget gap() => const SizedBox(
        height: 16,
      );
}
