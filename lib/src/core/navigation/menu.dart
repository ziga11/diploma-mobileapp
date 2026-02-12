import 'package:diplomaapp/src/obligation/domain/user_obligation.dart';
import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/presentation/document_menu.dart';
import 'package:diplomaapp/src/employment/presentation/employment.dart';
import 'package:diplomaapp/src/notification/presentation/list_notifications_page.dart';
import 'package:diplomaapp/src/obligation/data/obligation_repository.dart';
import 'package:diplomaapp/src/obligation/presentation/obligation_list_page.dart';
import 'package:diplomaapp/src/request/presentation/list_requests_page.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/drawer.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/shared/widgets/menu_button.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';
import 'package:logger/logger.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});
  static const route = '/menu';

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final user = getIt<UserService>().currentUser!;
  final oRepo = getIt<ObligationRepository>();

  late Future<List<ObligationRecord>> fetchobligations =
      oRepo.fetchObligations(user.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DiplomaAppbar(),
        drawer: const DiplomaDrawer(),
        body: RefreshIndicator(
          onRefresh: () async => setState(() {
            fetchobligations = oRepo.fetchObligations(user.id);
          }),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: ValueListenableBuilder(
                valueListenable: getIt<LanguageService>().translations,
                builder: (context, translations, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      gap(),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: width(context) * 0.07),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${translations["hello"]},",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: ColorTheme.white,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              "${user.firstName.toUpperCase()} ${user.lastName.toUpperCase()}",
                              style: TextStyle(
                                  fontSize: 26,
                                  color: ColorTheme.white,
                                  fontWeight: FontWeight.w700),
                            )
                          ],
                        ),
                      ),
                      gap(),
                      FutureBuilder<List<ObligationRecord>>(
                          future: fetchobligations,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: AnimatedLotusLoader(
                                size: 32,
                              ));
                            } else if (snapshot.hasError) {
                              Logger().e(snapshot.error);
                              return Center(
                                child: Text(translations["errorOccurred"]!),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return DiplomaBtn(
                                title: translations["missingDocuments"]!
                                    .toUpperCase(),
                                bgColor: ColorTheme.red,
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListObligationsPage(),
                                    ),
                                  );
                                  setState(() {});
                                });
                          }),
                      gap(),
                      DiplomaBtn(
                          title: translations["myEmployment"]!.toUpperCase(),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EmploymentPage(),
                              ),
                            );
                          }),
                      gap(),
                      DiplomaBtn(
                          title: translations["myDocuments"]!.toUpperCase(),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DocumentMenu(),
                              ),
                            );
                          }),
                      gap(),
                      DiplomaBtn(
                          title: translations["applicationSubmission"]!
                              .toUpperCase(),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ListMessagesPage(),
                              ),
                            );
                          }),
                      gap(),
                      DiplomaBtn(
                          title: translations["notifications"]!.toUpperCase(),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ListNotificationsPage(),
                              ),
                            );
                          }),
                    ],
                  );
                }),
          ),
        ));
  }

  Widget gap() => const SizedBox(
        height: 16,
      );
}
