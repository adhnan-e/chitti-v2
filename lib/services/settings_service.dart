import 'package:firebase_database/firebase_database.dart';
import 'package:chitt/core/models/gold_option.dart';
import 'package:chitt/utils/currency_data.dart';
import 'package:chitt/utils/currency_utils.dart';

/// Settings Service - Handles app configuration
class SettingsService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Singleton
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  String _cachedCurrency = 'AED';
  String get currency => _cachedCurrency;

  // ============ MASTER DATA: Gold Types ============

  /// Default gold types
  static const List<String> defaultGoldTypes = [
    'Coin',
    'Biscuit',
    'Bar',
    'Jewelry',
  ];

  /// Get available gold types
  Future<List<String>> getGoldTypes() async {
    try {
      final settings = await getAppSettings();
      final types = settings['goldTypes'];
      if (types != null && types is List) {
        return List<String>.from(types.map((e) => e.toString()));
      }
      // Return defaults if not set
      return List<String>.from(defaultGoldTypes);
    } catch (e) {
      print('Error fetching gold types: $e');
      return List<String>.from(defaultGoldTypes);
    }
  }

  /// Add a new gold type
  Future<void> addGoldType(String type) async {
    try {
      final types = await getGoldTypes();
      if (!types.contains(type)) {
        types.add(type);
        await updateAppSettings({'goldTypes': types});
      }
    } catch (e) {
      print('Error adding gold type: $e');
      rethrow;
    }
  }

  /// Remove a gold type
  Future<void> removeGoldType(String type) async {
    try {
      final types = await getGoldTypes();
      types.remove(type);
      await updateAppSettings({'goldTypes': types});
    } catch (e) {
      print('Error removing gold type: $e');
      rethrow;
    }
  }

  // ============ MASTER DATA: Gold Purities ============

  /// Default gold purities
  static const List<String> defaultGoldPurities = [
    '24 Karat',
    '22 Karat',
    '18 Karat',
    '14 Karat',
  ];

  /// Get available gold purities
  Future<List<String>> getGoldPurities() async {
    try {
      final settings = await getAppSettings();
      final purities = settings['goldPurities'];
      if (purities != null && purities is List) {
        return List<String>.from(purities.map((e) => e.toString()));
      }
      // Return defaults if not set
      return List<String>.from(defaultGoldPurities);
    } catch (e) {
      print('Error fetching gold purities: $e');
      return List<String>.from(defaultGoldPurities);
    }
  }

  /// Add a new gold purity
  Future<void> addGoldPurity(String purity) async {
    try {
      final purities = await getGoldPurities();
      if (!purities.contains(purity)) {
        purities.add(purity);
        await updateAppSettings({'goldPurities': purities});
      }
    } catch (e) {
      print('Error adding gold purity: $e');
      rethrow;
    }
  }

  /// Remove a gold purity
  Future<void> removeGoldPurity(String purity) async {
    try {
      final purities = await getGoldPurities();
      purities.remove(purity);
      await updateAppSettings({'goldPurities': purities});
    } catch (e) {
      print('Error removing gold purity: $e');
      rethrow;
    }
  }

  // ============ MASTER DATA: Gold Options V2 ============

  /// Get available gold options (new structure with type, purity, weight)
  Future<List<GoldOption>> getGoldOptionsV2() async {
    try {
      final settings = await getAppSettings();
      final options = settings['goldOptionsV2'];
      if (options != null && options is List) {
        return options
            .map((e) => GoldOption.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching gold options V2: $e');
      return [];
    }
  }

  /// Add a new gold option
  Future<void> addGoldOptionV2(GoldOption option) async {
    try {
      final options = await getGoldOptionsV2();
      // Check for duplicate (same type, purity, weight)
      final exists = options.any(
        (o) =>
            o.type == option.type &&
            o.purity == option.purity &&
            o.weight == option.weight,
      );
      if (!exists) {
        options.add(option);
        await updateAppSettings({
          'goldOptionsV2': options.map((o) => o.toMap()).toList(),
        });
      }
    } catch (e) {
      print('Error adding gold option V2: $e');
      rethrow;
    }
  }

  /// Remove a gold option by ID
  Future<void> removeGoldOptionV2(String optionId) async {
    try {
      final options = await getGoldOptionsV2();
      options.removeWhere((o) => o.id == optionId);
      await updateAppSettings({
        'goldOptionsV2': options.map((o) => o.toMap()).toList(),
      });
    } catch (e) {
      print('Error removing gold option V2: $e');
      rethrow;
    }
  }

  /// Get currency symbol
  String getCurrencySymbol() {
    return CurrencyData.getSymbol(_cachedCurrency);
  }

  /// Get app settings
  Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final snapshot = await _db.child('app_settings').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _cachedCurrency = data['currency'] ?? 'AED';
        CurrencyUtils.setCurrencySymbol(
          CurrencyData.getSymbol(_cachedCurrency),
        );
        return data;
      }
      _cachedCurrency = 'AED';
      return _defaultSettings;
    } catch (e) {
      print('Error fetching app settings: $e');
      return {'currency': 'AED'};
    }
  }

  Map<String, dynamic> get _defaultSettings => {
    'currency': 'AED',
    'chittiNameFormat': 'numeric',
    'chittiNameTemplate': '{prefix} {number}',
    'chittiNamePrefix': 'Chitti',
    'lastChittiNumber': 0,
  };

  /// Update app settings
  Future<void> updateAppSettings(Map<String, dynamic> data) async {
    try {
      await _db.child('app_settings').update(data);
      if (data.containsKey('currency')) {
        _cachedCurrency = data['currency'];
        CurrencyUtils.setCurrencySymbol(
          CurrencyData.getSymbol(_cachedCurrency),
        );
      }
    } catch (e) {
      print('Error updating app settings: $e');
      rethrow;
    }
  }

  /// Increment chitti counter atomically
  Future<int> incrementChittiCounter() async {
    try {
      final settings = await getAppSettings();
      final currentCounter = settings['lastChittiNumber'] as int? ?? 0;
      final newCounter = currentCounter + 1;
      await updateAppSettings({'lastChittiNumber': newCounter});
      return newCounter;
    } catch (e) {
      print('Error incrementing chitti counter: $e');
      rethrow;
    }
  }

  /// Reset chitti counter
  Future<void> resetChittiCounter([int value = 0]) async {
    try {
      await updateAppSettings({
        'lastChittiNumber': value,
        'lastChittiLetter': '',
      });
    } catch (e) {
      print('Error resetting chitti counter: $e');
      rethrow;
    }
  }

  /// Get available gold weight options
  Future<List<int>> getGoldOptions() async {
    try {
      final settings = await getAppSettings();
      final options = settings['goldOptions'];
      if (options != null && options is List) {
        return List<int>.from(
          options.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0),
        );
      }
      // Default gold options
      return [];
    } catch (e) {
      print('Error fetching gold options: $e');
      return [];
    }
  }

  /// Add a new gold weight option
  Future<void> addGoldOption(int grams) async {
    try {
      final options = await getGoldOptions();
      if (!options.contains(grams)) {
        options.add(grams);
        options.sort();
        await updateAppSettings({'goldOptions': options});
      }
    } catch (e) {
      print('Error adding gold option: $e');
      rethrow;
    }
  }

  /// Remove a gold weight option
  Future<void> removeGoldOption(int grams) async {
    try {
      final options = await getGoldOptions();
      options.remove(grams);
      await updateAppSettings({'goldOptions': options});
    } catch (e) {
      print('Error removing gold option: $e');
      rethrow;
    }
  }
}
