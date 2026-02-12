import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/data/document_repository.dart';
import 'package:diplomaapp/src/document/presentation/widgets/document_tile.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/drawer.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/utils/date_helper.dart';
import 'package:logger/logger.dart';

class ListDocumentsPage extends StatefulWidget {
  static const route = "/list-documents";

  final List<String> type;
  final bool inclusive;

  const ListDocumentsPage(
      {super.key, required this.type, this.inclusive = true});

  @override
  State<ListDocumentsPage> createState() => _ListDocumentsPageState();
}

class _ListDocumentsPageState extends State<ListDocumentsPage> {
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  String search = "";

  Map<String, dynamic> translations =
      getIt<LanguageService>().translations.value;
  final user = getIt<UserService>().currentUser!;

  final repo = getIt<DocumentRepository>();

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
          builder: (context, t, child) {
            translations = t;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
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
                      future: repo.fetchDocuments(user.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: AnimatedLotusLoader(
                              size: 96,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          Logger().e(snapshot.error);
                          return Center(
                            child: Text(translations["errorOccurred"]),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          Logger().w("EMPTY DATA");
                          return Center(
                            child: Text(translations["noAttachments"]),
                          );
                        }
                        final data = snapshot.data;
                        return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: data!.length,
                            itemBuilder: (context, index) {
                              final entity = data[index];
                              if (widget.inclusive) {
                                if (!widget.type
                                    .contains(entity.type.toLowerCase())) {
                                  return SizedBox.shrink();
                                }
                              } else {
                                if (widget.type
                                    .contains(entity.type.toLowerCase())) {
                                  return SizedBox.shrink();
                                }
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
