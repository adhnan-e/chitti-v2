import 'package:get_it/get_it.dart';
import 'package:chitt/core/config/client_config.dart';
import 'package:chitt/core/config/database_type.dart';
import 'package:chitt/core/domain/repositories/i_auth_repository.dart';
import 'package:chitt/core/domain/repositories/i_database_repository.dart';
import 'package:chitt/core/domain/repositories/i_storage_repository.dart';
import 'package:chitt/core/data/datasources/firebase/firebase_auth_datasource.dart';
import 'package:chitt/core/data/datasources/firebase/firebase_database_datasource.dart';
import 'package:chitt/core/data/datasources/firebase/firebase_storage_datasource.dart';
import 'package:chitt/core/data/datasources/supabase/supabase_auth_datasource.dart';
import 'package:chitt/core/data/datasources/supabase/supabase_database_datasource.dart';
import 'package:chitt/core/data/datasources/supabase/supabase_storage_datasource.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator(ClientConfig config) async {
  if (getIt.isRegistered<ClientConfig>()) {
    await getIt.reset();
  }

  getIt.registerSingleton<ClientConfig>(config);

  if (config.dbType == DatabaseType.firebase) {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: config.credentials['apiKey'] ?? '',
          appId: config.credentials['appId'] ?? '',
          messagingSenderId: config.credentials['messagingSenderId'] ?? '',
          projectId: config.credentials['projectId'] ?? '',
          databaseURL: config.credentials['databaseURL'],
          storageBucket: config.credentials['storageBucket'],
        ),
      );
    }

    getIt.registerLazySingleton<IAuthRepository>(() => FirebaseAuthDatasource());
    getIt.registerLazySingleton<IDatabaseRepository>(() => FirebaseDatabaseDatasource());
    getIt.registerLazySingleton<IStorageRepository>(() => FirebaseStorageDatasource());
  } else {
    await Supabase.initialize(
      url: config.credentials['url'] ?? '',
      anonKey: config.credentials['anonKey'] ?? '',
    );

    getIt.registerLazySingleton<IAuthRepository>(() => SupabaseAuthDatasource());
    getIt.registerLazySingleton<IDatabaseRepository>(() => SupabaseDatabaseDatasource());
    getIt.registerLazySingleton<IStorageRepository>(() => SupabaseStorageDatasource());
  }
}
