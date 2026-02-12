import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/presentation/list_documents.dart';
import 'package:diplomaapp/src/document/presentation/payroll_menu.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/drawer.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/shared/widgets/menu_button.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';

class DocumentMenu extends StatefulWidget {
  const DocumentMenu({super.key});

  @override
  State<DocumentMenu> createState() => _DocumentMenuState();
}

class _DocumentMenuState extends State<DocumentMenu> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      extendBodyBehindAppBar: true,
      appBar: DiplomaAppbar(
        leading: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const BackButton(
              color: Colors.white,
            ),
            IconButton(
                onPressed: () {
                  _key.currentState!.openDrawer();
                },
                icon: const Icon(Icons.menu_rounded))
          ],
        ),
      ),
      drawer: const DiplomaDrawer(),
      body: Center(
        child: SizedBox(
          height: height(context) * 0.5,
          child: ValueListenableBuilder(
              valueListenable: getIt<LanguageService>().translations,
              builder: (context, translations, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DiplomaBtn(
                      title: translations["payroll"]!.toUpperCase(),
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PayrollMenuPage(),
                          ),
                        );
                      },
                      bgColor: ColorTheme.green,
                    ),
                    DiplomaBtn(
                      title: translations["employmentContract"]!.toUpperCase(),
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ListDocumentsPage(
                              type: ["contract"],
                              inclusive: true,
                            ),
                          ),
                        );
                      },
                      bgColor: ColorTheme.orange,
                    ),
                    DiplomaBtn(
                      title: translations["other"]!.toUpperCase(),
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ListDocumentsPage(
                              type: ["contract", "payroll"],
                              inclusive: false,
                            ),
                          ),
                        );
                      },
                      bgColor: ColorTheme.bgHighlight,
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
