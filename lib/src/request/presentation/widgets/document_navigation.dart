import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/data/document_repository.dart';
import 'package:diplomaapp/src/document/domain/document.dart';
import 'package:diplomaapp/src/document/presentation/doc_viewer.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';
import 'dart:async';

import 'package:logger/logger.dart';

class DocumentNavgiation extends StatefulWidget {
  final List<int> documentIDs;
  final bool leftFileAlignment;

  const DocumentNavgiation(
      {super.key, required this.documentIDs, this.leftFileAlignment = true});

  @override
  DocumentNavgiationState createState() => DocumentNavgiationState();
}

class DocumentNavgiationState extends State<DocumentNavgiation> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  late final futureDocs = getDocsByIds(widget.documentIDs);

  final dRepo = getIt<DocumentRepository>();

  Future<List<Document>> getDocsByIds(List<int> docIds) async {
    List<Document> docs = [];
    for (var docId in docIds) {
      Document? doc = await dRepo.fetchDocById(docId);
      if (doc != null) {
        docs.add(doc);
      }
    }
    return docs;
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  void _previousPage() {
    if (_currentPage == 0) return;
    setState(() {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  int _itemsPerPage(BuildContext context) {
    double size = width(context) * 0.2;
    return (width(context) / size).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          if (_currentPage > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              ),
            ),
          SizedBox(
            height: height(context) * 0.11,
            width: widget.documentIDs.length * width(context) * 0.25,
            child: FutureBuilder<List<Document>>(
              future: futureDocs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: AnimatedLotusLoader(
                    size: 96,
                  ));
                } else if (snapshot.hasError) {
                  return ValueListenableBuilder(
                      valueListenable: getIt<LanguageService>().translations,
                      builder: (context, translations, child) {
                        return Center(
                          child: Text(translations["errorOccurred"]!),
                        );
                      });
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No data found"),
                  );
                }

                final start = _currentPage * _itemsPerPage(context);
                final end = (start + _itemsPerPage(context))
                    .clamp(0, widget.documentIDs.length);
                final pageItems = snapshot.data!.sublist(start, end);

                return SizedBox(
                  height: height(context) * 0.1,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount:
                        (widget.documentIDs.length / _itemsPerPage(context))
                            .ceil(),
                    itemBuilder: (context, pageIndex) {
                      return Row(
                        mainAxisAlignment: widget.leftFileAlignment
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        children: pageItems.map((entity) {
                          return SizedBox(
                            width: width(context) * 0.15,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Image.asset(
                                entity.fileIcon,
                                width: height(context) * 0.05,
                                height: height(context) * 0.05,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DocumentViewerPage(
                                      document: entity,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (_currentPage <
              ((widget.documentIDs.length - 1) / _itemsPerPage(context))
                  .floor())
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _nextPage,
              ),
            ),
        ],
      ),
    );
  }
}
