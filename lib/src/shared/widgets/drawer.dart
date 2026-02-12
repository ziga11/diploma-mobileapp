import 'package:diplomaapp/src/shared/data/encrypted_token_repository.dart';
import 'package:diplomaapp/src/shared/data/hashed_token_repository.dart';
import 'package:diplomaapp/src/shared/domain/token.dart';
import 'package:flutter/material.dart';
import 'package:diplomaapp/src/auth/presentation/login_page.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/job/presentation/jobs_list_page.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DiplomaDrawer extends StatefulWidget {
  const DiplomaDrawer({super.key});

  @override
  State<DiplomaDrawer> createState() => _DiplomaDrawerState();
}

class _DiplomaDrawerState extends State<DiplomaDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorTheme.bgDark,
      child: Drawer(
        backgroundColor: Colors.transparent,
        shape: const BeveledRectangleBorder(side: BorderSide.none),
        width: MediaQuery.of(context).size.width * 3 / 4,
        child: ValueListenableBuilder(
            valueListenable: getIt<LanguageService>().translations,
            builder: (context, translations, _) {
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  translations["menu"]!.toUpperCase(),
                                  style: TextStyle(
                                      color: ColorTheme.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              color: ColorTheme.bgHighlight,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                  spreadRadius: -2,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              tileColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(
                                translations["jobs"]!.toUpperCase(),
                                style: TextStyle(
                                  color: ColorTheme.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => JobSearchPage()),
                                );
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: ColorTheme.bgHighlight,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                            spreadRadius: -2,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading:
                            Icon(Icons.phone_rounded, color: ColorTheme.white),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        tileColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          "070 771 719",
                          style: TextStyle(
                            color: ColorTheme.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        onTap: () async {
                          launchUrlString("tel://+38670771719");
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height(context) * 0.02,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: ColorTheme.red,
                        boxShadow: [
                          BoxShadow(
                            color: ColorTheme.red.withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                            spreadRadius: -2,
                          ),
                          // Lighter red glow
                          BoxShadow(
                            color: ColorTheme.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        tileColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(translations["logOut"]!.toUpperCase(),
                            style: TextStyle(
                                color: ColorTheme.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          await getIt<UserService>().clear();

                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                            (route) => false, // remove everything
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                ],
              );
            }),
      ),
    );
  }
}
