import 'package:flutter/material.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/notification/application/notification_controller.dart';
import 'package:diplomaapp/src/notification/data/notification_repository.dart';
import 'package:diplomaapp/src/notification/domain/app_notification.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/domain/user.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/drawer.dart';
import 'package:diplomaapp/src/utils/date_helper.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';
import 'package:logger/web.dart';

class NotificationPage extends StatefulWidget {
  static const route = '/notification-page';

  final AppNotification appNotification;
  const NotificationPage({super.key, required this.appNotification});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  User user = getIt<UserService>().currentUser!;

  final nRepo = getIt<NotificationRepository>();
  final controller = NotificationController();

  late AppNotification notification;

  @override
  void initState() {
    super.initState();
    notification = widget.appNotification;
    nRepo.setRead(notification.linkId, user.id);
  }

  @override
  Widget build(BuildContext context) {
    String title = notification.title;
    String body = notification.body;

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
      body: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1200),
        curve: Curves.ease,
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          Color glowColor;
          if (notification.suitable == null) {
            glowColor = ColorTheme.bgLight;
          } else {
            glowColor =
                notification.suitable! ? ColorTheme.green : ColorTheme.red;
          }

          return Container(
              decoration: BoxDecoration(
                color: ColorTheme.bgDark,
                gradient: RadialGradient(
                  center: const Alignment(0.0, 1.6),
                  radius: 1.0 + (0.5 * value),
                  colors: [
                    glowColor.withValues(alpha: 0.2 * value),
                    ColorTheme.bgDark,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
              child: ValueListenableBuilder(
                  valueListenable: getIt<LanguageService>().translations,
                  builder: (context, translations, _) {
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: height(context) * 0.02),
                          child: Row(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    translations["notifications"]!,
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: width(context) * 0.85,
                          height: height(context) * 0.55,
                          child: Card(
                            color: ColorTheme.bgLight,
                            elevation: 3,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20.0),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    title,
                                    style:
                                        Theme.of(context).textTheme.titleLarge!,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          fillColor: ColorTheme.white
                                              .withValues(alpha: 0.05)),
                                      readOnly: true,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!,
                                      controller:
                                          TextEditingController(text: body),
                                      minLines: 7,
                                      maxLines: 8,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15.0, 0, 15, 15),
                                    child: Text(
                                      getWeekDay(notification.date),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (notification.type == 'response') ...[
                          if (notification.suitable == null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                responseButton(
                                    translations["unsuitable"]!, false),
                                responseButton(translations["suitable"]!, true),
                              ],
                            )
                          else
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                text: translations["selectedStatus"],
                              ),
                              TextSpan(
                                  text:
                                      " ${notification.suitable! ? translations["suitable"] : translations["unsuitable"]}",
                                  style: TextStyle(fontWeight: FontWeight.w600))
                            ])),
                        ],
                        const Spacer(),
                      ],
                    );
                  }));
        },
      ),
    );
  }

  Widget responseButton(String text, bool suitable) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: suitable ? ColorTheme.green : ColorTheme.red,
        shadowColor: suitable ? ColorTheme.green : ColorTheme.red,
      ),
      onPressed: () async {
        controller.notificationResponse(notification, suitable);
        setState(() {
          notification.suitable = suitable;
        });
      },
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
