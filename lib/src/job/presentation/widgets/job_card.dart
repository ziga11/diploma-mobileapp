import 'package:flutter/material.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/job/domain/job_listing.dart';
import 'package:diplomaapp/src/job/presentation/job_page.dart';
import 'package:diplomaapp/src/services/language_service.dart';

class JobCard extends StatefulWidget {
  final JobListing job;

  const JobCard({super.key, required this.job});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  final langCode = getIt<LanguageService>().current.code;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorTheme.bgLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: ColorTheme.white.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobPage(job: widget.job),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Title
                Text(
                  widget.job.titles[langCode]!,
                  style: TextStyle(
                    color: ColorTheme.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),
                Text(
                  widget.job.descriptions[langCode]!,
                  style: TextStyle(
                    color: ColorTheme.lightGray,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: ColorTheme.lightGray,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.job.location,
                        style: TextStyle(
                          color: ColorTheme.lightGray,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: ColorTheme.white.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(widget.job),
                      style: TextStyle(
                        color: ColorTheme.lightGray,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 12),

                // Salary Section
                SizedBox(
                  width: double.infinity,
                  child: _buildSalaryChip(widget.job),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryChip(JobListing job) {
    final salary = job.salary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorTheme.secondaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ColorTheme.secondaryColor,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            salary,
            style: TextStyle(
              color: ColorTheme.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: ColorTheme.bgLight,
          ),
        ],
      ),
    );
  }

  String _formatDate(JobListing job) {
    return "${job.date.day}.${job.date.month}.${job.date.year}";
  }
}
