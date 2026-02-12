import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/presentation/widgets/document_tile.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/drawer.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/document/data/document_repository.dart';
import 'package:diplomaapp/src/utils/date_helper.dart';

class PayrollMenuPage extends StatefulWidget {
  const PayrollMenuPage({super.key});

  @override
  State<PayrollMenuPage> createState() => _PayrollMenuPageState();
}

class _PayrollMenuPageState extends State<PayrollMenuPage> {
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  String search = "";

  final dRepo = getIt<DocumentRepository>();
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
      body: ValueListenableBuilder(
          valueListenable: getIt<LanguageService>().translations,
          builder: (context, translations, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (String str) {
                      setState(() {
                        search = str.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: translations["searchMessage"],
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                      future: dRepo.fetchDocuments(user.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: AnimatedLotusLoader(
                              size: 96,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(translations["errorOccurred"]!),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(translations["noAttachments"]!),
                          );
                        }
                        final data = snapshot.data;
                        return ListView.builder(
                            itemCount: data!.length,
                            itemBuilder: (context, index) {
                              final entity = data[index];
                              if (entity.type.toLowerCase() != "payroll") {
                                return Container();
                              }

                              String searchParams =
                                  "${entity.title.toLowerCase()} ${formatDate(entity.date!)}";

                              bool searchFilter = searchParams.contains(search);

                              return DocumentTile(
                                  visible: searchFilter, document: entity);
                            });
                      }),
                )
              ],
            );
          }),
    );
  }
}
