import 'package:get_it/get_it.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/database_service.dart';

/// Global service locator instance using get_it.
final GetIt serviceLocator = GetIt.instance;

/// Sets up all service dependencies in the service locator.
Future<void> setupServiceLocator() async {
  final databaseService = DatabaseService();
  await databaseService.initialize();
  
  serviceLocator
    ..registerSingleton<DatabaseService>(databaseService)
    ..registerSingleton<AuthService>(AuthService(databaseService));
}
