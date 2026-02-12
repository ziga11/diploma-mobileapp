import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:diplomaapp/src/auth/data/auth_repository.dart';
import 'package:diplomaapp/src/document/data/document_repository.dart';
import 'package:diplomaapp/src/employment/data/employment_repository.dart';
import 'package:diplomaapp/src/job/data/job_listing_repository.dart';
import 'package:diplomaapp/src/notification/data/notification_repository.dart';
import 'package:diplomaapp/src/obligation/data/obligation_repository.dart';
import 'package:diplomaapp/src/request/data/request_repository.dart';
import 'package:diplomaapp/src/services/firebase_api.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/link_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/data/encrypted_token_repository.dart';
import 'package:diplomaapp/src/shared/data/slack_repository.dart';
import 'package:diplomaapp/src/shared/data/hashed_token_repository.dart';
import 'package:diplomaapp/src/shared/data/user_repository.dart';
import 'package:diplomaapp/src/shared/domain/retry_http_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<FirebaseAPI>(() => FirebaseAPI());

  getIt.registerLazySingleton<RetryHttpClient>(
      () => RetryHttpClient(client: getIt<http.Client>()));

  getIt.registerLazySingleton<EncryptedTokenRepository>(
      () => EncryptedTokenRepository(getIt<RetryHttpClient>()));
  getIt.registerLazySingleton<HashedTokenRepository>(
      () => HashedTokenRepository(getIt<RetryHttpClient>()));
  getIt.registerLazySingleton<SlackRepository>(
      () => SlackRepository(getIt<RetryHttpClient>()));
  getIt.registerLazySingleton<ObligationRepository>(
      () => ObligationRepository(getIt<RetryHttpClient>()));
  getIt.registerLazySingleton<DocumentRepository>(
      () => DocumentRepository(getIt<RetryHttpClient>()));
  getIt.registerLazySingleton<MessageRepository>(
      () => MessageRepository(getIt<RetryHttpClient>()));
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepository(getIt<RetryHttpClient>()));
  getIt.registerLazySingleton<UserRepository>(
      () => UserRepository(getIt<RetryHttpClient>()));
  getIt.registerLazySingleton<JobListingRepository>(
      () => JobListingRepository());
  getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepository(getIt<RetryHttpClient>()));
  getIt.registerLazySingleton<EmploymentRepository>(
      () => EmploymentRepository(getIt<RetryHttpClient>()));

  getIt.registerSingleton<LanguageService>(LanguageService());
  getIt.registerSingleton<UserService>(UserService());
  getIt.registerSingleton<StartupService>(StartupService());
}
