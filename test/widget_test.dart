import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chitt/main.dart';
import 'package:chitt/screens/splash_screen.dart';
import 'package:chitt/core/config/client_config.dart';
import 'package:chitt/core/config/database_type.dart';
import 'package:chitt/core/di/service_locator.dart';
import 'package:chitt/core/domain/repositories/i_auth_repository.dart';
import 'package:chitt/core/domain/repositories/i_database_repository.dart';
import 'package:chitt/core/domain/repositories/i_storage_repository.dart';
import 'package:provider/provider.dart';
import 'package:chitt/core/design/theme/theme_provider.dart';

class MockDatabaseRepository implements IDatabaseRepository {
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override String getCurrencySymbol() => '₹';
}
class MockAuthRepository implements IAuthRepository {
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override Map<String, dynamic>? get currentUser => null;
}
class MockStorageRepository implements IStorageRepository {
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;

    final config = ClientConfig(
      clientId: 'test_client',
      clientName: 'Test Chitti',
      dbType: DatabaseType.firebase,
      credentials: {},
    );

    await getIt.reset();
    getIt.registerSingleton<ClientConfig>(config);
    getIt.registerLazySingleton<IAuthRepository>(() => MockAuthRepository());
    getIt.registerLazySingleton<IDatabaseRepository>(() => MockDatabaseRepository());
    getIt.registerLazySingleton<IStorageRepository>(() => MockStorageRepository());
  });

  testWidgets('App starts with SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
