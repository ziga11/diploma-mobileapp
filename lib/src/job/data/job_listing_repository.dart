import 'package:diplomaapp/src/job/domain/job_listing.dart';
import 'package:diplomaapp/src/utils/other.dart';

class JobListingRepository {
  Future<List<JobListing>> fetchJobs() async {
    Map<String, dynamic> jobJson = await loadJson("assets/job_listings.json");

    return (jobJson["job_listings"] as List<dynamic>)
        .map((e) => JobListing.fromJson(e))
        .toList();
  }
}
