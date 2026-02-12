import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/shared/data/hashed_token_repository.dart';
import 'package:diplomaapp/src/shared/domain/exceptions.dart';
import 'package:diplomaapp/src/shared/domain/token.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';

class InvalidPasswordPage extends StatefulWidget {
  final String email;
  const InvalidPasswordPage({super.key, required this.email});

  @override
  State<InvalidPasswordPage> createState() => _InvalidPasswordPageState();
}

class _InvalidPasswordPageState extends State<InvalidPasswordPage> {
  final tRepo = getIt<HashedTokenRepository>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        elevation: 5,
        backgroundColor: ColorTheme.bgDark,
        content: SizedBox(
          width: MediaQuery.of(context).size.width / 4 * 3,
          height: MediaQuery.of(context).size.height / 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ValueListenableBuilder(
                  valueListenable: getIt<LanguageService>().translations,
                  builder: (context, translations, _) {
                    return Column(
                      children: [
                        Text(
                          translations["wrongCredentials"]!,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(translations["incorrectPasswordEntered"]!),
                        const Spacer(),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    tRepo
                                        .pwResetToken(Token(
                                            type: "pw_token",
                                            email: widget.email))
                                        .then((_) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                            content: Text(translations[
                                                "resetTokenSent"]!)),
                                      );
                                    }, onError: (e) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                            content: Text((e as ApiException)
                                                .responseBody!)),
                                      );
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: AutoSizeText(
                                    translations["forgottenPW"]!,
                                    maxLines: 2,
                                    minFontSize: 10,
                                    maxFontSize: 12,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width(context) * 0.05,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorTheme.secondaryColor,
                                    shadowColor: ColorTheme.secondaryColor,
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  },
                                  child: AutoSizeText(
                                    translations["retry"]!,
                                    maxLines: 1,
                                    minFontSize: 10,
                                    maxFontSize: 12,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  })
            ],
          ),
        ));
  }
}
