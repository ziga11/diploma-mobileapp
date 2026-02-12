import 'package:flutter/material.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/job/data/job_listing_repository.dart';
import 'package:diplomaapp/src/job/domain/job_listing.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class JobPage extends StatefulWidget {
  final JobListing job;
  const JobPage({super.key, required this.job});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  final jRepo = getIt<JobListingRepository>();
  final langCode = getIt<LanguageService>().current.code;

  Map<String, dynamic> translations =
      getIt<LanguageService>().translations.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: DiplomaAppbar(),
      body: SafeArea(
        child: ValueListenableBuilder(
            valueListenable: getIt<LanguageService>().translations,
            builder: (context, t, child) {
              translations = t;
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildJobHeader(),
                          const SizedBox(height: 24),
                          _buildJobDescription(),
                          const SizedBox(height: 24),
                          _buildCompanyInfo(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomActions(),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildJobHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorTheme.bgHighlight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorTheme.bgLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.job.titles[langCode]!,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.white.withValues(alpha: 0.8),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.job.location,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                color: Colors.white.withValues(alpha: 0.8),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(_formatDate(widget.job))),
            ],
          ),
          const SizedBox(height: 16),
          _buildSalaryChip(),
        ],
      ),
    );
  }

  Widget _buildSalaryChip() {
    final salary = widget.job.salary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ColorTheme.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorTheme.bgLight.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        salary,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildJobDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorTheme.bgHighlight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorTheme.bgLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translations["desc"],
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.job.descriptions[langCode]!,
            style: TextStyle(
              color: ColorTheme.lightGray,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorTheme.bgHighlight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorTheme.bgLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translations["companyTranslation"],
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(
                  color: ColorTheme.bgHighlight,
                  width: 1,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: ColorTheme.bgHighlight,
                    blurRadius: 8,
                  )
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 24,
                ),
                Spacer(),
                Expanded(
                  flex: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.company,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.job.location,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: ColorTheme.bgLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: ColorTheme.bgHighlight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _buildActionButton(
              text: translations["callUs"],
              icon: Icons.phone_rounded,
              color: ColorTheme.primaryColor,
              textColor: Colors.white,
              onPressed: () {
                launchUrlString("tel://+386013003100");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(JobListing job) {
    return "${job.date.day}.${job.date.month}.${job.date.year}";
  }
}
