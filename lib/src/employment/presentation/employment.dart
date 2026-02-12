import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/employment/data/employment_repository.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/drawer.dart';
import 'package:diplomaapp/src/shared/widgets/form_field.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/employment/domain/job.dart';
import 'package:diplomaapp/src/utils/date_helper.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:logger/web.dart';

class EmploymentPage extends StatefulWidget {
  static const route = "/employment-page";

  const EmploymentPage({super.key});

  @override
  State<EmploymentPage> createState() => _EmploymentPageState();
}

class _EmploymentPageState extends State<EmploymentPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  final eRepo = getIt<EmploymentRepository>();

  final user = getIt<UserService>().currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: DiplomaAppbar(
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                _key.currentState!.openDrawer();
              },
            )
          ],
        ),
      ),
      drawer: const DiplomaDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: height(context) * 0.05,
          ),
          Expanded(
            flex: 4,
            child: ValueListenableBuilder(
                valueListenable: getIt<LanguageService>().translations,
                builder: (context, translations, _) {
                  return FutureBuilder<Job?>(
                      future: eRepo.employmentInfo(user.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: AnimatedLotusLoader(
                            size: 96,
                          ));
                        } else if (snapshot.hasError) {
                          Logger().e(snapshot.error);
                          return Center(
                            child: Text(translations["errorOccurred"]!),
                          );
                        } else if (!snapshot.hasData) {
                          return const Text(
                              "You don't have an assigned company");
                        }
                        final job = snapshot.data;
                        if (job == null) return const SizedBox.shrink();

                        return Card(
                          margin: EdgeInsets.all(20),
                          color: ColorTheme.bgLight,
                          elevation: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: width(context) * 0.05),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                DiplomaFormField(
                                    readOnly: true,
                                    label:
                                        translations["company"]!.toUpperCase(),
                                    controller: TextEditingController(
                                        text: job.companyName!)),
                                DiplomaFormField(
                                    readOnly: true,
                                    label: translations["jobPosition"]!
                                        .toUpperCase(),
                                    controller:
                                        TextEditingController(text: job.title)),
                                DiplomaFormField(
                                    readOnly: true,
                                    label: translations["employmentStatus"]!
                                        .toUpperCase(),
                                    controller: TextEditingController(
                                        text: translations[
                                            job.status ?? "errorOccurred"]!)),
                                DiplomaFormField(
                                    readOnly: true,
                                    label: translations["contractDuration"]!
                                        .toUpperCase(),
                                    controller: TextEditingController(
                                        text:
                                            "${formatDate(job.startContract!)} - ${formatDate(job.endContract!)}")),
                              ],
                            ),
                          ),
                        );
                      });
                }),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
