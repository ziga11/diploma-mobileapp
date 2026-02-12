import 'package:flutter/material.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/notification/domain/app_notification.dart';
import 'package:diplomaapp/src/notification/presentation/notification_page.dart';
import 'package:diplomaapp/src/utils/date_helper.dart';

class NotificationTile extends StatefulWidget {
  final AppNotification notification;
  final String search;

  const NotificationTile(
      {super.key, required this.notification, required this.search});

  @override
  State<NotificationTile> createState() => NotificationTileState();
}

class NotificationTileState extends State<NotificationTile> {
  @override
  Widget build(BuildContext context) {
    final n = widget.notification;

    String searchParams = "${n.title.toLowerCase()} ${n.body.toLowerCase()}";
    String shownBody = n.body.contains("\n")
        ? n.body.substring(0, n.body.indexOf("\n") - 1)
        : n.body;

    bool searchFilter = searchParams.contains(widget.search);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Visibility(
          visible: searchFilter,
          child: ListTile(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: ColorTheme.bgHighlight, width: 3),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            tileColor: n.read ? Colors.transparent : ColorTheme.bgLight,
            onTap: () async {
              await Navigator.of(context)
                  .pushNamed(NotificationPage.route, arguments: n);
              setState(() {
                n.read = true;
              });
            },
            title: Column(
              children: [
                Text(
                  n.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: ColorTheme.white),
                ),
                Text(
                  shownBody,
                  style: TextStyle(color: ColorTheme.white.withAlpha(200)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            subtitle: Text(
              formatDateTime(n.date),
              style: TextStyle(color: ColorTheme.white),
            ),
          )),
    );
  }
}
