import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/job/data/job_listing_repository.dart';
import 'package:diplomaapp/src/job/presentation/widgets/job_card.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';

class JobSearchPage extends StatefulWidget {
  const JobSearchPage({super.key});

  @override
  State<JobSearchPage> createState() => _JobSearchPageState();
}

class _JobSearchPageState extends State<JobSearchPage> {
  final _keywordController = TextEditingController();

  final jRepo = getIt<JobListingRepository>();
  final langCode = getIt<LanguageService>().current.code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DiplomaAppbar(),
        body: ValueListenableBuilder(
            valueListenable: getIt<LanguageService>().translations,
            builder: (context, translations, child) {
              return Column(
                children: [
                  _buildSearchField(
                    controller: _keywordController,
                    hintText: translations["searchKeywords"]!,
                    icon: Icons.search,
                  ),
                  Expanded(
                    child: FutureBuilder(
                        future: jRepo.fetchJobs(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: AnimatedLotusLoader(
                              size: 96,
                            ));
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(translations["errorOccurred"]!),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data == null ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text("Error: No data"),
                            );
                          }
                          return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final entity = snapshot.data![index];
                                if (_keywordController.text.isNotEmpty) {
                                  String searchParams =
                                      "${entity.company.toLowerCase()} ${entity.titles[langCode]!.toLowerCase()} ${entity.location.toLowerCase()}";

                                  if (!searchParams.contains(
                                      _keywordController.text.toLowerCase())) {
                                    return SizedBox.shrink();
                                  }
                                }

                                return JobCard(job: entity);
                              });
                        }),
                  ),
                ],
              );
            }));
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
