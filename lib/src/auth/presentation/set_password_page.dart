import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:diplomaapp/src/auth/application/login_controller.dart';
import 'package:diplomaapp/src/auth/data/auth_repository.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/profile/presentation/profile_preview.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/widgets/menu_button.dart';
import 'package:diplomaapp/src/shared/widgets/toggle_form_field.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';

class SetPasswordPage extends StatefulWidget {
  final String token;

  const SetPasswordPage({super.key, required this.token});
  static const route = '/pwset-page';

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController confPwController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  final aRepo = getIt<AuthRepository>();

  final userService = getIt<UserService>();

  final ValueNotifier isLoadingNotifier = ValueNotifier(false);

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
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: height(context) * 0.15,
                  ),
                  Expanded(
                    child: Text(
                      translations["setPassword"]!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                        widthFactor: 0.85,
                        child: Column(
                          children: [
                            ToggleFormField(
                              label: translations["password"]!,
                              controller: pwController,
                              initialVisibleText: false,
                            ),
                            SizedBox(
                              height: height(context) * 0.05,
                            ),
                            ToggleFormField(
                              label: translations["confPassword"]!,
                              controller: confPwController,
                              initialVisibleText: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).viewInsets.bottom == 0) ...[
                    ValueListenableBuilder(
                        valueListenable: isLoadingNotifier,
                        builder: (context, value, child) {
                          return DiplomaBtn(
                            title: translations["apply"]!,
                            size: Size(width(context) * 0.65, 40),
                            fontSize: 15,
                            isLoading: value,
                            onPressed: () async {
                              isLoadingNotifier.value = true;
                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
                              final controller = LoginController();

                              try {
                                await controller.applySetPassword(
                                  token: widget.token,
                                  pw: pwController.text,
                                  confPw: confPwController.text,
                                );

                                navigator.pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ProfilePreviewPage()),
                                  (_) => false,
                                );
                              } catch (e) {
                                String errorKey =
                                    e.toString().replaceAll('Exception: ', '');

                                messenger.showSnackBar(SnackBar(
                                    content: Text(translations[errorKey]!)));
                              } finally {
                                isLoadingNotifier.value = false;
                              }
                            },
                          );
                        }),
                    SizedBox(
                      height: height(context) * 0.15,
                    ),
                  ]
                ],
              );
            }),
      ),
    );
  }
}
