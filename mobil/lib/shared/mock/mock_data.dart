// Shared sample lists for jobs, applicants, and message threads.

import '../models/applicant.dart';
import '../models/job.dart';
import '../models/message_thread.dart';

final class MockData {
  const MockData._();

  static final List<Job> _jobs = List<Job>.unmodifiable(Job.mockList());
  static final List<Applicant> _applicants = List<Applicant>.unmodifiable(
    Applicant.mockList(),
  );
  static final List<MessageThread> _threads = List<MessageThread>.unmodifiable(
    MessageThread.mockList(),
  );

  static List<Job> jobs() => _jobs;
  static List<Applicant> applicants() => _applicants;
  static List<MessageThread> threads() => _threads;
}
