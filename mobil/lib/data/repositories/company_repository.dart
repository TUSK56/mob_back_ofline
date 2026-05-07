// Contract for jobs, applicants, and message threads.

import '../../shared/models/applicant.dart';
import '../../shared/models/job.dart';
import '../../shared/models/message_thread.dart';

abstract class CompanyRepository {
  Future<List<Job>> fetchJobs();

  Future<List<Applicant>> fetchApplicantsByJobId(String jobId);

  Future<List<MessageThread>> fetchMessageThreads();
}

