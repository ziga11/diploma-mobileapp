import 'package:flutter/material.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/obligation/domain/obligation.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/shared/widgets/menu_button.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';

class TextFieldPopup extends StatefulWidget {
  final Obligation obligation;
  const TextFieldPopup({super.key, required this.obligation});

  @override
  State<TextFieldPopup> createState() => TextFieldPopupState();
}

class TextFieldPopupState extends State<TextFieldPopup> {
  TextEditingController controller = TextEditingController();

  final translations = getIt<LanguageService>().translations;
  final langCode = getIt<LanguageService>().current.code;

  @override
  Widget build(BuildContext context) {
    String title = widget.obligation.translations[langCode]!.title;

    return AlertDialog(
        elevation: 3,
        backgroundColor: ColorTheme.bgDark,
        content: SizedBox(
          width: width(context) * 0.85,
          height: height(context) * 0.2,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: title,
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  hintText: title,
                ),
                controller: controller,
              ),
              Spacer(),
              ValueListenableBuilder(
                  valueListenable: getIt<LanguageService>().translations,
                  builder: (context, translations, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DiplomaBtn(
                          title: translations["cancel"]!,
                          bgColor: ColorTheme.red,
                          size: Size(
                              width(context) * 0.2, height(context) * 0.06),
                          onPressed: () {
                            Navigator.pop(context, "");
                          },
                        ),
                        DiplomaBtn(
                          title: translations["apply"]!,
                          size: Size(
                              width(context) * 0.2, height(context) * 0.06),
                          bgColor: ColorTheme.green,
                          onPressed: () {
                            Navigator.pop(context, controller.text);
                          },
                        ),
                      ],
                    );
                  }),
            ],
          ),
        ));
  }
}
