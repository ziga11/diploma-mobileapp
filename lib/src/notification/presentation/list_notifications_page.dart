import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/notification/data/notification_repository.dart';
import 'package:diplomaapp/src/notification/domain/app_notification.dart';
import 'package:diplomaapp/src/notification/presentation/widgets/notification_tile.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/drawer.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';

class ListNotificationsPage extends StatefulWidget {
  const ListNotificationsPage({super.key});

  @override
  State<ListNotificationsPage> createState() => _ListNotificationsPageState();
}

class _ListNotificationsPageState extends State<ListNotificationsPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final TextEditingController textEditingController = TextEditingController();
  String search = "";

  final nRepo = getIt<NotificationRepository>();

  final user = getIt<UserService>().currentUser!;

  late final Future<List<AppNotification>?> notificationsFuture =
      nRepo.fetchNotifications(user.id);

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
                  child: FutureBuilder(
                      future: notificationsFuture,
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
                                "Error loading notifications --> ${snapshot.error}"),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data == null ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(translations["noNotifications"]!),
                          );
                        }
                        return SizedBox(
                          width: width(context) * 0.95,
                          child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                final entity = snapshot.data![index];

                                return NotificationTile(
                                    notification: entity, search: search);
                              }),
                        );
                      }),
                ),
              ],
            );
          }),
    );
  }
}
