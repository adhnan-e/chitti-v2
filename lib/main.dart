import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chitt/core/config/client_config.dart';
import 'package:chitt/core/di/service_locator.dart';
import 'package:chitt/core/design/theme/app_theme.dart';
import 'package:chitt/core/design/theme/theme_provider.dart';
import 'package:chitt/screens/splash_screen.dart';
import 'package:chitt/screens/login_screen.dart';
import 'package:chitt/screens/chitti_list_screen.dart';
import 'package:chitt/screens/member_list_screen.dart';
import 'package:chitt/screens/add_member_screen.dart';
import 'package:chitt/screens/slot_ledger_screen.dart';
import 'package:chitt/screens/profile_screen.dart';
import 'package:chitt/screens/settings_screen.dart';
import 'package:chitt/screens/deleted_members_screen.dart';
import 'package:chitt/screens/member_details_screen.dart';
import 'package:chitt/screens/create_chitti_screen.dart';
import 'package:chitt/screens/add_member_to_chitti_screen.dart';
import 'package:chitt/screens/lucky_draw_results_screen.dart';
import 'package:chitt/screens/organizer_home_screen.dart';
import 'package:chitt/screens/organizer_chitti_details_screen.dart';
import 'package:chitt/screens/chitti_payments_screen.dart';
import 'package:chitt/screens/settlement_bill_screen.dart';
import 'package:chitt/screens/document_viewer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String configJson = String.fromEnvironment('CLIENT_CONFIG', defaultValue: '{}');
  Map<String, dynamic> configMap = {};

  if (configJson != '{}') {
    configMap = jsonDecode(configJson);
  } else {
    configMap = {
      'clientId': 'default_client',
      'clientName': 'Chitti Manager',
      'dbType': 'firebase',
      'credentials': {
        'apiKey': 'AIza...',
        'appId': '1:...',
        'messagingSenderId': '...',
        'projectId': '...',
        'databaseURL': 'https://...',
        'storageBucket': '...',
      }
    };
  }

  final config = ClientConfig.fromMap(configMap);
  await setupServiceLocator(config);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: getIt<ClientConfig>().clientName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/chitti_list': (context) => const ChittiListScreen(),
            '/member_list': (context) => const MemberListScreen(),
            '/add_member': (context) => const AddMemberScreen(),
            '/payment_history': (context) => const SlotLedgerScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/member_details': (context) => const MemberDetailsScreen(),
            '/create_chitti': (context) => const CreateChittiScreen(),
            '/add_member_to_chitti': (context) =>
                const AddMemberToChittiScreen(),
            '/lucky_draw_results': (context) => const LuckyDrawResultsScreen(),
            '/organizer_home': (context) => const OrganizerHomeScreen(),
            '/organizer_chitti_details': (context) =>
                const OrganizerChittiDetailsScreen(),
            '/document_viewer': (context) => const DocumentViewerScreen(),
            '/deleted_members': (context) => const DeletedMembersScreen(),
            '/settlement_bill': (context) => const SettlementBillScreen(),
          },
          onGenerateRoute: (settings) {
            final args = settings.arguments;

            switch (settings.name) {
              case '/chitti_payments':
                if (args is Map<String, dynamic>) {
                  return MaterialPageRoute(
                    builder: (context) =>
                        PaymentCollectionScreen(chittiData: args),
                  );
                }
                return MaterialPageRoute(
                  builder: (context) => const Scaffold(
                    body: Center(
                      child: Text(
                        'Error: Invalid arguments for Payment Collection',
                      ),
                    ),
                  ),
                );
              case '/edit_chitti':
                if (args is Map<String, dynamic>) {
                  return MaterialPageRoute(
                    builder: (context) => CreateChittiScreen(chittiData: args),
                  );
                }
                return MaterialPageRoute(
                  builder: (context) => const Scaffold(
                    body: Center(
                      child: Text('Error: Invalid arguments for Edit Chitti'),
                    ),
                  ),
                );
              default:
                return null;
            }
          },
        );
      },
    );
  }
}
