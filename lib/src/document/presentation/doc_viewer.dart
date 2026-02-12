import 'dart:io';
import 'package:docx_viewer/docx_viewer.dart';
import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/application/document_controller.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/drawer.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/document/data/document_repository.dart';
import 'package:diplomaapp/src/document/domain/document.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentViewerPage extends StatefulWidget {
  static const route = "/document-viewer";

  final Document document;
  final bool showAppBar;

  const DocumentViewerPage(
      {super.key, required this.document, this.showAppBar = true});

  @override
  DocumentViewerPageState createState() => DocumentViewerPageState();
}

class DocumentViewerPageState extends State<DocumentViewerPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  TransformationController controller = TransformationController();

  bool zoomedIn = false;

  final dRepo = getIt<DocumentRepository>();
  final docController = DocumentController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: !widget.showAppBar
          ? null
          : DiplomaAppbar(
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
      body: FutureBuilder<File>(
          future: dRepo.downloadFile(widget.document),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                  child: AnimatedLotusLoader(
                size: 96,
              ));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (widget.document.isImg()) {
              return GestureDetector(
                onDoubleTap: () {
                  docController.doubleTapZoom(zoomedIn, controller);
                },
                child: InteractiveViewer(
                  panEnabled: true,
                  onInteractionEnd: (details) {
                    final scale = controller.value.getMaxScaleOnAxis();

                    zoomedIn = scale > 1.3;
                  },
                  transformationController: controller,
                  boundaryMargin: const EdgeInsets.all(5),
                  minScale: 0.5,
                  maxScale: 2.5,
                  child: Center(
                      child: Image.file(
                    fit: BoxFit.fill,
                    snapshot.data!,
                  )),
                ),
              );
            } else if (widget.document.isDocx()) {
              snapshot.data!.readAsBytes().then((bytes) => {
                    DocxView(
                      bytes: bytes,
                    )
                  });
            } else if (widget.document.isPdf()) {
              return SfPdfViewer.file(
                snapshot.data!,
              );
            }
            return const Center(child: Text('Unsupported file format'));
          }),
    );
  }
}
