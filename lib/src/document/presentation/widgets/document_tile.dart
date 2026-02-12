import 'package:flutter/material.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/document/domain/document.dart';
import 'package:diplomaapp/src/document/presentation/doc_viewer.dart';
import 'package:diplomaapp/src/utils/date_helper.dart';

class DocumentTile extends StatefulWidget {
  final bool visible;
  final Document document;

  const DocumentTile(
      {super.key, required this.visible, required this.document});

  @override
  State<DocumentTile> createState() => _DocumentTileState();
}

class _DocumentTileState extends State<DocumentTile> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
              color: ColorTheme.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.all(Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                    color: ColorTheme.bgLight,
                    offset: Offset(1, 3),
                    spreadRadius: 3,
                    blurRadius: 50)
              ]),
          child: ListTile(
            tileColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DocumentViewerPage(
                    document: widget.document,
                  ),
                ),
              );
            },
            title: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.document.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: ColorTheme.white),
                ),
              ],
            ),
            subtitle: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: ColorTheme.lightGray),
                  formatDateTime(widget.document.date!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
