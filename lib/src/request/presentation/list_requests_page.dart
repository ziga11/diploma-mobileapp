import 'package:flutter/material.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/request/data/request_repository.dart';
import 'package:diplomaapp/src/request/domain/request.dart';
import 'package:diplomaapp/src/request/presentation/message_page.dart';
import 'package:diplomaapp/src/request/presentation/send_message_page.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/drawer.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/utils/date_helper.dart';

class ListMessagesPage extends StatefulWidget {
  const ListMessagesPage({super.key});

  @override
  State<ListMessagesPage> createState() => _ListMessagesPageState();
}

class _ListMessagesPageState extends State<ListMessagesPage> {
  int index = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController textEditingController = TextEditingController();
  String search = "";

  final user = getIt<UserService>().currentUser!;
  final mRepo = getIt<MessageRepository>();

  late Future<List<Message>?> requestList = mRepo.fetchMessages(user.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: DiplomaAppbar(
        leading: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            BackButton(
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            IconButton(
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
                icon: const Icon(Icons.menu_rounded))
          ],
        ),
      ),
      drawer: const DiplomaDrawer(),
      body: ValueListenableBuilder(
          valueListenable: getIt<LanguageService>().translations,
          builder: (context, translations, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: textEditingController,
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
                  child: RefreshIndicator(
                    onRefresh: () async {
                      requestList = mRepo.fetchMessages(user.id);
                      setState(() {});
                    },
                    child: FutureBuilder(
                        future: requestList,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: AnimatedLotusLoader(
                              size: 96,
                            ));
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text(
                                    "Error loading sent requests --> ${snapshot.error}"));
                          }
                          final messages = snapshot.data ?? [];

                          if (messages.isEmpty) {
                            return Center(
                              child: Text(translations["noRequests"]!),
                            );
                          }

                          if (messages.isEmpty) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  child: Center(
                                    child: Text(translations["noRequests"]!),
                                  ),
                                ),
                              ],
                            );
                          }

                          return ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final entity = snapshot.data![index];

                                return messageTile(entity);
                              });
                        }),
                  ),
                )
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorTheme.primaryColor,
        onPressed: () async {
          bool refresh = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SendMessagePage()));
          if (!refresh) return;

          setState(() {
            requestList = mRepo.fetchMessages(user.id);
          });
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget messageTile(Message entity) {
    String title = entity.getMessageContent().title;
    String text = entity.getMessageContent().text;

    String searchParams = "${title.toLowerCase()} ${text.toLowerCase()}";
    bool searchFilter = searchParams.contains(search);

    return Visibility(
        visible: searchFilter,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 10, right: 10),
          child: ListTile(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: ColorTheme.white.withValues(alpha: 0.1),
                width: entity.read! ? 1 : 2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            tileColor: entity.read!
                ? ColorTheme.bgLight.withValues(alpha: 0.5)
                : ColorTheme.bgHighlight,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagePage(
                    reqId: entity.id!,
                  ),
                ),
              );
              setState(() {});
            },
            title: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: ColorTheme.white),
                ),
                Opacity(
                  opacity: 0.85,
                  child: Text(
                      style: TextStyle(color: ColorTheme.white),
                      overflow: TextOverflow.ellipsis,
                      text.contains("\n")
                          ? text.substring(0, text.indexOf("\n") - 1)
                          : text),
                ),
              ],
            ),
            subtitle: Text(
              getWeekDay(entity.date!),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ));
  }
}
