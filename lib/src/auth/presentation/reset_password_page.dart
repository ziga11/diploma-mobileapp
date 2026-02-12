import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:diplomaapp/src/auth/application/login_controller.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/shared/data/hashed_token_repository.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/shared/widgets/toggle_form_field.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String token;

  static const route = '/reset-password';
  const ResetPasswordPage(
      {super.key, required this.email, required this.token});

  @override
  State<ResetPasswordPage> createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confPWController = TextEditingController();

  final tRepo = getIt<HashedTokenRepository>();

  final isLoadingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: DiplomaAppbar(
          leading: SizedBox.shrink(),
          showUser: false,
        ),
        body: ValueListenableBuilder(
            valueListenable: getIt<LanguageService>().translations,
            builder: (context, translations, _) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width(context) * 1 / 7,
                    vertical: height(context) * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      translations["resetPassword"]!,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ToggleFormField(
                      label: translations["password"]!,
                      controller: pwController,
                      initialVisibleText: false,
                    ),
                    ToggleFormField(
                      label: translations["repeatPassword"]!,
                      controller: confPWController,
                      initialVisibleText: false,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.red,
                            shadowColor: ColorTheme.red,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            translations["cancel"]!,
                            style: TextStyle(color: ColorTheme.white),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.green,
                            shadowColor: ColorTheme.green,
                          ),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            final loginController = LoginController();

                            try {
                              await loginController.resetPassword(
                                token: widget.token,
                                email: widget.email,
                                pw: pwController.text,
                                confPw: confPWController.text,
                              );

                              navigator.pop();
                              messenger.showSnackBar(SnackBar(
                                  content: Text(translations["changedPW"]!)));
                            } catch (e) {
                              String errorKey =
                                  e.toString().replaceAll('Exception: ', '');

                              messenger.showSnackBar(SnackBar(
                                  content: Text(translations[errorKey]!)));
                            } finally {
                              isLoadingNotifier.value = false;
                            }
                          },
                          child: ValueListenableBuilder(
                              valueListenable: isLoadingNotifier,
                              builder: (context, isLoading, _) {
                                return isLoading
                                    ? AnimatedLotusLoader()
                                    : Text(
                                        translations["apply"]!,
                                        style:
                                            TextStyle(color: ColorTheme.white),
                                      );
                              }),
                        ),
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
