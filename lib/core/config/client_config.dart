import 'database_type.dart';

class ClientConfig {
  final String clientId;
  final String clientName;
  final DatabaseType dbType;
  final Map<String, dynamic> credentials;
  final String? currencySymbol;

  ClientConfig({
    required this.clientId,
    required this.clientName,
    required this.dbType,
    required this.credentials,
    this.currencySymbol = '₹',
  });

  factory ClientConfig.fromMap(Map<String, dynamic> map) {
    return ClientConfig(
      clientId: map['clientId'] as String,
      clientName: map['clientName'] as String,
      dbType: DatabaseType.values.firstWhere(
        (e) => e.name == map['dbType'],
        orElse: () => DatabaseType.firebase,
      ),
      credentials: Map<String, dynamic>.from(map['credentials'] as Map),
      currencySymbol: map['currencySymbol'] as String? ?? '₹',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'dbType': dbType.name,
      'credentials': credentials,
      'currencySymbol': currencySymbol,
    };
  }
}
