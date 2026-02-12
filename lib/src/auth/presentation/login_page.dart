import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:diplomaapp/src/auth/application/login_controller.dart';
import 'package:diplomaapp/src/auth/data/auth_repository.dart';
import 'package:diplomaapp/src/auth/presentation/invalid_password_page.dart';
import 'package:diplomaapp/src/core/navigation/menu.dart';
import 'package:diplomaapp/src/profile/presentation/profile_preview.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';
import 'package:diplomaapp/src/constants/theme.dart';

class LoginPage extends StatefulWidget {
  static const route = '/login-page';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordNotVisible = true;
  final TextEditingController mailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final loginController = LoginController();

  @override
  Widget build(BuildContext context) {
    gap() => SizedBox(height: height(context) * 0.08);

    return Scaffold(
        appBar: DiplomaAppbar(
          showUser: false,
          showLogo: false,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: ValueListenableBuilder(
                valueListenable: getIt<LanguageService>().translations,
                builder: (context, translations, _) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        gap(),
                        SvgPicture.asset(
                          "assets/logo.svg",
                          semanticsLabel: "Logo",
                        ),
                        gap(),
                        Text(
                          translations["enterMailPW"]!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        Card(
                          color: ColorTheme.bgLight,
                          elevation: 5,
                          child: Container(
                              width: width(context) * 0.85,
                              padding: EdgeInsets.all(8),
                              child: _isLoading
                                  ? Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(top: 10),
                                      child:
                                          const AnimatedLotusLoader(size: 96),
                                    )
                                  : Column(
                                      children: [
                                        TextFormField(
                                          autofillHints: const [
                                            AutofillHints.email
                                          ],
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return translations["enterMail"];
                                            }
                                            if (!loginController
                                                .validEmail(value)) {
                                              return translations[
                                                  "invalidEmail"];
                                            }
                                            return null;
                                          },
                                          controller: mailController,
                                          decoration: InputDecoration(
                                            labelText: translations["email"],
                                            hintText: translations["enterMail"],
                                            prefixIcon: const Icon(
                                              Icons.email_outlined,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 15),
                                          child: TextFormField(
                                            autofillHints: const [
                                              AutofillHints.password
                                            ],
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty ||
                                                  value.length < 6) {
                                                return translations[
                                                    "enterPassword"];
                                              }
                                              return null;
                                            },
                                            controller: pwController,
                                            obscureText: _passwordNotVisible,
                                            decoration: InputDecoration(
                                              labelText:
                                                  translations["password"],
                                              hintText:
                                                  translations["enterPassword"],
                                              prefixIcon: const Icon(
                                                Icons.lock_outline,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _passwordNotVisible
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _passwordNotVisible =
                                                        !_passwordNotVisible;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                        ),
                        gap(),
                        SizedBox(
                          width: width(context) * 0.6,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (!(_formKey.currentState?.validate() ??
                                        false)) {
                                      return;
                                    }

                                    final navigtor = Navigator.of(context);
                                    setState(() => _isLoading = true);

                                    try {
                                      final aRepo = getIt<AuthRepository>();
                                      final response = await aRepo.attemptLogin(
                                          mailController.text,
                                          pwController.text);

                                      if (response.successful) {
                                        await loginController
                                            .successfulLogin(response);

                                        navigtor.pushAndRemoveUntil(
                                            MaterialPageRoute(
                                                builder: (ctx) =>
                                                    response.user?.group ==
                                                            "Registered"
                                                        ? ProfilePreviewPage()
                                                        : Menu()),
                                            (route) => false);
                                      } else {
                                        if (context.mounted) {
                                          await showDialog(
                                            context: context,
                                            builder: (ctx) =>
                                                InvalidPasswordPage(
                                                    email: mailController.text),
                                          );
                                        }
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  },
                            child: Text(translations["signIn"]!),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          ),
        ));
  }
}
