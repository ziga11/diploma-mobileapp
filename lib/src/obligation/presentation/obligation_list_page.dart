import 'package:diplomaapp/src/obligation/domain/user_obligation.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/domain/user.dart';
import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/drawer.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/obligation/data/obligation_repository.dart';
import 'package:diplomaapp/src/obligation/presentation/widgets/obligation_tile.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ListObligationsPage extends StatefulWidget {
  static const route = '/list-obligations';
  final List<int>? highlightedIds;
  const ListObligationsPage({super.key, this.highlightedIds});

  @override
  State<ListObligationsPage> createState() => _ListObligationsPageState();
}

class _ListObligationsPageState extends State<ListObligationsPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  final ItemScrollController _itemScrollController = ItemScrollController();
  final _repository = getIt<ObligationRepository>();
  late final User user;

  bool hasScrolled = false;

  late Future<List<ObligationRecord>> fetchObligations;
  @override
  void initState() {
    user = getIt<UserService>().currentUser!;
    fetchObligations = _repository.fetchObligations(user.id);
    super.initState();
  }

  void _scrollToHighlighted(List<dynamic> flatList) {
    if (widget.highlightedIds == null || hasScrolled) return;
    hasScrolled = true;

    final highlightedIndex = flatList.indexWhere((item) {
      return item is ObligationRecord &&
          item.id == widget.highlightedIds!.first;
    });

    if (highlightedIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _itemScrollController.scrollTo(
          index: highlightedIndex,
          duration: const Duration(milliseconds: 500),
        );
      });
    }
  }

  List<dynamic> createFlatList(
    Map<String, String> translations,
    List<ObligationRecord> incomplete,
    List<ObligationRecord> pending,
    List<ObligationRecord> completed,
  ) {
    final List<dynamic> flatList = [];

    if (incomplete.isNotEmpty) {
      flatList.add({'type': 'header', 'text': translations["incomplete"]!});
      flatList.addAll(incomplete);
    }

    if (pending.isNotEmpty) {
      flatList.add({'type': 'header', 'text': translations["pending"]!});
      flatList.addAll(pending);
    }

    if (completed.isNotEmpty) {
      flatList.add({'type': 'header', 'text': translations["completed"]!});
      flatList.addAll(completed);
    }

    return flatList;
  }

  void sortLists(List<List<ObligationRecord>> obligationLists) {
    for (var list in obligationLists) {
      list.sort((a, b) {
        int aVal = widget.highlightedIds!.contains(a.id) ? 0 : 1;
        int bVal = widget.highlightedIds!.contains(b.id) ? 0 : 1;

        int comparison = aVal.compareTo(bVal);

        return comparison != 0 ? comparison : a.id.compareTo(b.id);
      });
    }
  }

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
      body: Column(
        children: [
          ValueListenableBuilder(
              valueListenable: getIt<LanguageService>().translations,
              builder: (context, translations, _) {
                return Expanded(
                  child: FutureBuilder<List<ObligationRecord>>(
                    future: fetchObligations,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: AnimatedLotusLoader(
                          size: 96,
                        ));
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(translations["errorOccurred"]!),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No data found"),
                        );
                      }

                      final data = snapshot.data!;
                      final completed = data
                          .where((entity) => entity.status == "Completed")
                          .toList();
                      final incomplete = data
                          .where((entity) => entity.status == "Incomplete")
                          .toList();
                      final pending = data
                          .where((entity) => entity.status == "Pending")
                          .toList();

                      if (widget.highlightedIds != null) {
                        sortLists([completed, incomplete, pending]);
                      }

                      final flatList = createFlatList(
                        translations,
                        incomplete,
                        pending,
                        completed,
                      );

                      _scrollToHighlighted(flatList);

                      return RefreshIndicator(
                        onRefresh: () => fetchObligations =
                            _repository.fetchObligations(user.id),
                        child: ScrollablePositionedList.builder(
                          itemScrollController: _itemScrollController,
                          itemCount: flatList.length,
                          itemBuilder: (context, index) {
                            final item = flatList[index];

                            if (item is Map) {
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  item['text'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }

                            final obligation = item as ObligationRecord;
                            return ObligationTile(
                              entity: obligation,
                              translations: translations,
                              highlighted: widget.highlightedIds
                                      ?.contains(obligation.id) ??
                                  false,
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
          const SizedBox(height: 16)
        ],
      ),
    );
  }
}
