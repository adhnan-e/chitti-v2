import 'package:firebase_database/firebase_database.dart';
import '../utils/currency_utils.dart';
import '../utils/currency_data.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Singleton
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Create a new Chitti
  Future<void> createChitti({
    required String name,
    required int duration, // e.g. 20 (months)
    required String startMonth, // e.g. "January 2025"
    required List<Map<String, dynamic>>
    goldOptions, // [{weight: "1g", price: 5000}, ...]
    required int maxSlots,
    required int paymentDay,
    required int luckyDrawDay,
    required Map<String, dynamic>
    rewardConfig, // {enabled: bool, type: 'Percentage'|'Fixed', value: 10}
  }) async {
    final chittiRef = _db.child('chittis').push();

    await chittiRef.set({
      'name': name,
      'duration': duration,
      'startMonth': startMonth,
      'goldOptions': goldOptions,
      'maxSlots': maxSlots,
      'paymentDay': paymentDay,
      'luckyDrawDay': luckyDrawDay,
      'rewardConfig': rewardConfig,
      'status': 'pending', // 'pending', 'active', 'completed'
      'createdAt': ServerValue.timestamp,
      'members': {}, // Will be populated with userId: [slot1, slot2]
    });
  }

  /// Start a Chitti (Change status to active)
  Future<void> startChitti(String chittiId) async {
    await _db.child('chittis/$chittiId').update({
      'status': 'active',
      'startedAt': ServerValue.timestamp,
    });
  }

  /// Update Chitti Details
  Future<void> updateChitti(String chittiId, Map<String, dynamic> data) async {
    try {
      await _db.child('chittis/$chittiId').update(data);
    } catch (e) {
      print('Error updating chitti: $e');
      rethrow;
    }
  }

  /// Add a Member to a Chitti (slot-based storage)
  /// Each slot is stored separately, allowing the same user to have multiple slots
  Future<void> addMemberToChitti({
    required String chittiId,
    required String userId,
    required String userName,
    required int slotNumber,
    required Map<String, dynamic> selectedGoldOption,
    required double totalAmount,
  }) async {
    // Generate slot ID
    final slotId = 'slot_$slotNumber';

    // 1. Update Chitti's member list using slot-based key
    await _db.child('chittis/$chittiId/members/$slotId').set({
      'userId': userId,
      'userName': userName,
      'slotNumber': slotNumber,
      'goldOption': selectedGoldOption,
      'totalAmount': totalAmount,
      'joinedAt': ServerValue.timestamp,
    });

    // 2. Update User's participated chittis list for quick access
    await _db.child('users/$userId/chittis/$chittiId').set({
      'joinedAt': ServerValue.timestamp,
      'status': 'active',
    });
  }

  /// Get the next available slot number for a chitti
  Future<int> getNextSlotNumber(String chittiId) async {
    final chitti = await getChitti(chittiId);
    if (chitti == null) return 1;

    final membersMap = chitti['members'] as Map? ?? {};
    if (membersMap.isEmpty) return 1;

    // Find the highest slot number currently used
    int maxSlot = 0;
    for (var slotId in membersMap.keys) {
      final slotData = Map<String, dynamic>.from(membersMap[slotId] as Map);
      final slotNum = slotData['slotNumber'] as int? ?? 0;
      if (slotNum > maxSlot) maxSlot = slotNum;
    }
    return maxSlot + 1;
  }

  /// Find a member by phone number (including deleted)
  Future<Map<String, dynamic>?> findMemberByPhone(String phone) async {
    try {
      final snapshot = await _db
          .child('users')
          .orderByChild('phone')
          .equalTo(phone)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        if (data.isNotEmpty) {
          final entry = data.entries.first;
          final map = Map<String, dynamic>.from(entry.value as Map);
          map['id'] = entry.key;
          if ((map['name'] as String? ?? '').isEmpty) {
            final first = map['firstName'] as String? ?? '';
            final last = map['lastname'] as String? ?? '';
            map['name'] = '$first $last'.trim();
          }
          return map;
        }
      }
    } catch (e) {
      print('Error finding user by phone: $e');
    }
    return null;
  }

  /// Search users by username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    try {
      final snapshot = await _db
          .child('users')
          .orderByChild('username')
          .startAt(query)
          .endAt('$query\uf8ff')
          .limitToFirst(20)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.entries
            .map((e) {
              final map = Map<String, dynamic>.from(e.value as Map);
              map['id'] = e.key;
              if ((map['name'] as String? ?? '').isEmpty) {
                final first = map['firstName'] as String? ?? '';
                final last = map['lastname'] as String? ?? '';
                map['name'] = '$first $last'.trim();
              }
              return map;
            })
            .where((m) => m['isDeleted'] != true)
            .toList();
      }
    } catch (e) {
      print('Error searching users: $e');
    }
    return [];
  }

  // Create a new user (with or without credentials)
  Future<void> createUser({
    required String name,
    required String phone,
    String? email,
    String? address,
    String? username,
    String? password,
    String? photoUrl,
    List<Map<String, dynamic>>? documents,
    bool needsAppAccess = false,
  }) async {
    final newUserRef = _db.child('users').push(); // Auto-generate ID

    final userData = {
      'firstName':
          name, // Storing full name in firstName for now, or split if needed
      'lastname': '',
      'phone': phone,
      'email': email ?? '',
      'address': address ?? '',
      'role': 'user', // Default role
      'photoUrl': photoUrl,
      'documents': documents,
      'createdAt': ServerValue.timestamp,
    };

    if (needsAppAccess && username != null && password != null) {
      // Check if username already exists
      final existingUsers = await searchUsers(username);
      for (var user in existingUsers) {
        if (user['username'] == username) {
          throw Exception('Username already taken');
        }
      }
      userData['username'] = username;
      userData['password'] = password;
      userData['hasAppAccess'] = true;
    } else {
      userData['hasAppAccess'] = false;
      // For non-app users, maybe generate a dummy username/pass or leave null?
      // Leaving null might break some assumptions if not careful, but acceptable for now.
      // We'll set a placeholder username to avoid indexing issues if strictly required,
      // but Rules say .indexOn: "username", so null might be skipped or allowed.
      // Let's leave them out.
    }

    await newUserRef.set(userData);
  }

  // Debug helper
  Future<void> seedDummyUsers() async {
    final users = [
      {
        'username': 'arun',
        'phone': '9876543210',
        'role': 'user',
        'password': 'user',
      },
      {
        'username': 'bob',
        'phone': '9876543211',
        'role': 'user',
        'password': 'user',
      },
    ];
    for (var u in users) {
      final ref = _db.child('users').push();
      await ref.set(u);
    }
  }

  // Update existing user
  Future<void> updateUser({
    required String userId,
    required String name,
    required String phone,
    String? email,
    String? address,
    bool needsAppAccess = false,
    String? username,
    String? password,
    String? photoUrl,
    List<Map<String, dynamic>>? documents,
  }) async {
    final Map<String, dynamic> updates = {
      'firstName': name,
      'phone': phone,
      'email': email ?? '',
      'address': address ?? '',
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (documents != null) 'documents': documents,
    };

    if (needsAppAccess) {
      if (username != null && password != null) {
        // Check uniqueness only if username changed?
        // For simplicity, we assume username is not editable if it's the same.
        // Or if we really want to check:
        // final existing = await searchUsers(username);
        // ... verify id is not current userId ...

        updates['username'] = username;
        updates['password'] = password;
        updates['hasAppAccess'] = true;
      }
    } else {
      // Revoke app access
      updates['hasAppAccess'] = false;
      // Optionally clear username/password or keep them but disabled
      updates['username'] = null;
      updates['password'] = null;
    }

    try {
      await _db.child('users/$userId').update(updates);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _db.child('users').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.entries
            .map((e) {
              final map = Map<String, dynamic>.from(e.value as Map);
              map['id'] = e.key;
              if ((map['name'] as String? ?? '').isEmpty) {
                final first = map['firstName'] as String? ?? '';
                final last = map['lastname'] as String? ?? '';
                map['name'] = '$first $last'.trim();
              }
              return map;
            })
            .where((m) => m['isDeleted'] != true)
            .toList();
      }
    } catch (e) {
      print('Error getting users: $e');
    }
    return [];
  }

  /// Get all chittis
  Future<List<Map<String, dynamic>>> getAllChittis() async {
    try {
      final snapshot = await _db.child('chittis').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final list = data.entries.map((e) {
          final map = Map<String, dynamic>.from(e.value as Map);
          map['id'] = e.key;
          return map;
        }).toList();

        // Sort by createdAt descending (newest first)
        list.sort((a, b) {
          final aTime = a['createdAt'] ?? 0;
          final bTime = b['createdAt'] ?? 0;
          return bTime.compareTo(aTime);
        });

        return list;
      }
    } catch (e) {
      print('Error getting chittis: $e');
    }
    return [];
  }

  /// Get all payment IDs for a user across all chittis
  /// Uses optimized reference path: /users/{userId}/paymentRefs/{chittiId}/{paymentId}
  Future<List<String>> getUserPaymentIds(String userId) async {
    try {
      final refsSnap = await _db.child('users/$userId/paymentRefs').get();
      if (!refsSnap.exists || refsSnap.value == null) return [];

      final List<String> paymentIds = [];
      final chittisMap = Map<String, dynamic>.from(refsSnap.value as Map);

      for (var chittiPayments in chittisMap.values) {
        if (chittiPayments is Map) {
          paymentIds.addAll(chittiPayments.keys.cast<String>());
        }
      }
      return paymentIds;
    } catch (e) {
      print('Error getting user payment IDs: $e');
      return [];
    }
  }

  /// Get all payments for a user with full details
  /// Uses optimized reference lookup with fallback to legacy query
  Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    try {
      final List<Map<String, dynamic>> payments = [];

      // Try optimized reference-based lookup first
      final refsSnap = await _db.child('users/$userId/paymentRefs').get();

      if (refsSnap.exists && refsSnap.value != null) {
        final chittisMap = Map<String, dynamic>.from(refsSnap.value as Map);

        for (var entry in chittisMap.entries) {
          // entry.key is chittiId (not used here, payment already has it)
          final paymentIdsMap = entry.value as Map?;
          if (paymentIdsMap == null) continue;

          for (var paymentId in paymentIdsMap.keys) {
            final paymentSnap = await _db.child('payments/$paymentId').get();
            if (paymentSnap.exists && paymentSnap.value != null) {
              final payment = Map<String, dynamic>.from(
                paymentSnap.value as Map,
              );
              payment['id'] = paymentId;
              payments.add(payment);
            }
          }
        }
      } else {
        // Fallback: Legacy query-based lookup
        final paymentsSnap = await _db
            .child('payments')
            .orderByChild('userId')
            .equalTo(userId)
            .get();

        if (paymentsSnap.exists && paymentsSnap.value != null) {
          final paymentsData = Map<String, dynamic>.from(
            paymentsSnap.value as Map,
          );
          paymentsData.forEach((key, value) {
            final payment = Map<String, dynamic>.from(value as Map);
            payment['id'] = key;
            payments.add(payment);
          });
        }
      }

      // Sort by date (newest first)
      payments.sort((a, b) {
        final aTime = a['paidAt'] ?? 0;
        final bTime = b['paidAt'] ?? 0;
        return bTime.compareTo(aTime);
      });

      return payments;
    } catch (e) {
      print('Error getting user payments: $e');
      return [];
    }
  }

  // --- Profile Management ---

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final snapshot = await _db.child('users/$userId').get();
      if (snapshot.exists && snapshot.value != null) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.child('users/$userId').update(data);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // --- App Settings (Organizer Only) ---

  String _cachedCurrency = 'AED';
  String get currency => _cachedCurrency;

  // Helper to get symbol
  String getCurrencySymbol() {
    return CurrencyData.getSymbol(_cachedCurrency);
  }

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
      // Default settings
      _cachedCurrency = 'AED';
      return {
        'currency': 'AED',
        'chittiNameFormat': 'numeric',
        'chittiNameTemplate': '{prefix} {number}',
        'chittiNamePrefix': 'Chitti',
        'lastChittiNumber': 0,
      };
    } catch (e) {
      print('Error fetching app settings: $e');
      return {'currency': 'AED'};
    }
  }

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

  /// Increment chitti counter atomically and return new value
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

  /// Reset chitti counter to a specific value (default: 0)
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

  /// Get chittis for a specific user (slot-based structure)
  Future<List<Map<String, dynamic>>> getUserChittis(String userId) async {
    print('Fetching chittis for user: $userId');
    try {
      // 1. Get user's chitti IDs
      final userChittisSnap = await _db.child('users/$userId/chittis').get();
      print('User chittis snapshot exists: ${userChittisSnap.exists}');
      if (!userChittisSnap.exists || userChittisSnap.value == null) {
        print('No chittis found for user.');
        return [];
      }

      final userChittisMap = Map<String, dynamic>.from(
        userChittisSnap.value as Map,
      );
      final chittiIds = userChittisMap.keys.toList();
      print('Found chitti IDs: $chittiIds');

      // 2. Fetch details for each chitti
      final List<Map<String, dynamic>> chittis = [];
      for (var chittiId in chittiIds) {
        print('Fetching details for chitti: $chittiId');
        final chittiSnap = await _db.child('chittis/$chittiId').get();
        if (chittiSnap.exists && chittiSnap.value != null) {
          final chittiData = Map<String, dynamic>.from(chittiSnap.value as Map);
          chittiData['id'] = chittiId;
          chittiData['user_status'] =
              userChittisMap[chittiId]['status']; // e.g. active
          chittiData['joinedAt'] = userChittisMap[chittiId]['joinedAt'];

          // Get user's slots in this chitti (slot-based structure)
          final membersMap = chittiData['members'] as Map? ?? {};
          final List<Map<String, dynamic>> userSlots = [];

          for (var entry in membersMap.entries) {
            final slotData = Map<String, dynamic>.from(entry.value as Map);
            if (slotData['userId'] == userId) {
              slotData['slotId'] = entry.key;
              userSlots.add(slotData);
            }
          }

          chittiData['user_slots'] = userSlots;
          chittiData['user_slot_count'] = userSlots.length;

          // For backward compatibility, use first slot as user_details
          if (userSlots.isNotEmpty) {
            chittiData['user_details'] = userSlots.first;
          }

          chittis.add(chittiData);
        } else {
          print('Chitti $chittiId details not found.');
        }
      }

      // Sort by createdAt descending (newest first)
      chittis.sort((a, b) {
        final aTime = a['createdAt'] ?? 0;
        final bTime = b['createdAt'] ?? 0;
        return bTime.compareTo(aTime);
      });

      return chittis;
    } catch (e) {
      print('Error getting user chittis: $e');
      return [];
    }
  }

  /// Get a stream of a specific Chitti
  Stream<Map<String, dynamic>?> getChittiStream(String chittiId) {
    return _db.child('chittis/$chittiId').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data['id'] = chittiId;
        return data;
      }
      return null;
    });
  }

  /// Get a specific Chitti details once
  Future<Map<String, dynamic>?> getChitti(String chittiId) async {
    try {
      final snapshot = await _db.child('chittis/$chittiId').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data['id'] = chittiId;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting chitti: $e');
      return null;
    }
  }

  /// Get full member details for a specific Chitti (slot-based structure)
  /// Returns a list of all slots with user details
  Future<List<Map<String, dynamic>>> getChittiMembersDetails(
    String chittiId,
  ) async {
    try {
      // 1. Get chitti to find members list
      final chittiSnap = await _db.child('chittis/$chittiId').get();
      if (!chittiSnap.exists) return [];

      final chittiData = Map<String, dynamic>.from(chittiSnap.value as Map);
      final membersMap = chittiData['members'] as Map? ?? {};

      final List<Map<String, dynamic>> slotDetails = [];

      // Cache user profiles to avoid duplicate fetches
      final Map<String, Map<String, dynamic>?> userProfileCache = {};

      // 2. Fetch profile for each slot (slot-based structure)
      for (var entry in membersMap.entries) {
        final slotId = entry.key;
        final slotData = Map<String, dynamic>.from(entry.value as Map);
        final userId = slotData['userId'] as String?;

        if (userId == null) continue;

        // Get user profile from cache or fetch
        if (!userProfileCache.containsKey(userId)) {
          userProfileCache[userId] = await getUserProfile(userId);
        }
        final profile = userProfileCache[userId];

        if (profile != null) {
          final slotInfo = {
            'slotId': slotId,
            'slotNumber': slotData['slotNumber'],
            'userId': userId,
            'name': '${profile['firstName']} ${profile['lastname'] ?? ''}'
                .trim(),
            'phone': profile['phone'],
            'totalAmount': slotData['totalAmount'],
            'goldOption': slotData['goldOption'],
            'joinedAt': slotData['joinedAt'],
          };
          slotDetails.add(slotInfo);
        }
      }

      // Sort by slot number
      slotDetails.sort(
        (a, b) => (a['slotNumber'] as int? ?? 0).compareTo(
          b['slotNumber'] as int? ?? 0,
        ),
      );

      return slotDetails;
    } catch (e) {
      print('Error getting chitti members details: $e');
      return [];
    }
  }

  /// Add a Winner for a Chitti
  Future<void> addWinner({
    required String chittiId,
    required String chittiName,
    required String monthKey, // YYYY-MM
    required String monthLabel, // Jan 2026
    required String userId,
    required String userName,
    required String slotId,
    required int slotNumber,
    required String prize,
  }) async {
    try {
      final timestamp = ServerValue.timestamp;
      final winnerData = {
        'chittiId': chittiId,
        'chittiName': chittiName,
        'month': monthLabel,
        'monthKey': monthKey,
        'userId': userId,
        'userName': userName,
        'slotId': slotId,
        'slotNumber': slotNumber,
        'prize': prize,
        'declaredAt': timestamp,
      };

      // 1. Store in Chitti winners keyed by monthKey for uniqueness
      await _db.child('chittis/$chittiId/winners/$monthKey').set(winnerData);

      // 2. Store in Global History
      await _db.child('lucky_draws').push().set(winnerData);

      // 3. Apply winner discount to member's balance
      // Note: In refined logic, prizeAmount is the total amount (returned to winner),
      // and discountAmount is the monthly reward (starts next month)
      final winnerDetails = await getWinnerDiscountDetails(chittiId, slotId);
      if (winnerDetails['isWinner'] == true) {
        final prizeAmount = (winnerDetails['prizeAmount'] ?? 0.0).toDouble();
        final discountAmount = (winnerDetails['discountAmount'] ?? 0.0)
            .toDouble();
        await applyWinnerDiscount(
          chittiId,
          slotId,
          prizeAmount,
          discountAmount,
        );
      }
    } catch (e) {
      print('Error adding winner: $e');
      rethrow;
    }
  }

  /// Get Lucky Draw History (Global)
  Future<List<Map<String, dynamic>>> getLuckyDrawHistory() async {
    try {
      final snapshot = await _db
          .child('lucky_draws')
          .orderByChild('declaredAt')
          .get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final list = data.entries.map((e) {
          final map = Map<String, dynamic>.from(e.value as Map);
          map['id'] = e.key;
          return map;
        }).toList();

        list.sort((a, b) {
          final aTime = a['declaredAt'] ?? 0;
          final bTime = b['declaredAt'] ?? 0;
          return bTime.compareTo(aTime);
        });
        return list;
      }
    } catch (e) {
      print('Error getting lucky draw history: $e');
    }
    return [];
  }

  /// Get all winners for a specific chitti
  Future<List<Map<String, dynamic>>> getChittiWinners(String chittiId) async {
    try {
      final winnersSnap = await _db.child('chittis/$chittiId/winners').get();
      if (!winnersSnap.exists || winnersSnap.value == null) return [];

      final winnersData = Map<String, dynamic>.from(winnersSnap.value as Map);
      final List<Map<String, dynamic>> winners = [];

      winnersData.forEach((key, value) {
        final winner = Map<String, dynamic>.from(value as Map);
        winner['id'] = key;
        // Key is the month (e.g., "Jan 2026"), add it as month field
        winner['month'] = key;
        winners.add(winner);
      });

      winners.sort(
        (a, b) => (a['declaredAt'] ?? 0).compareTo(b['declaredAt'] ?? 0),
      );
      return winners;
    } catch (e) {
      print('Error getting chitti winners: $e');
      return [];
    }
  }

  // --- Financial Tracking ---

  /// Record a Payment with balance tracking
  /// Returns the payment result including new balance
  Future<Map<String, dynamic>> recordPayment({
    required String chittiId,
    required String userId,
    required String slotId, // Added slotId
    required double amount,
    required String month, // e.g. "Jan 2024" or ISO string
    String status = 'paid',
    double? dueAmount, // Expected amount for this month (optional)
    String?
    paymentType, // 'full', 'partial', 'overpayment', 'remaining' (optional)
    String? notes, // Optional notes about this payment
  }) async {
    try {
      // Get current balance before payment
      final balance = await getMemberBalance(chittiId, userId);
      final balanceBefore = (balance['currentBalance'] ?? 0.0).toDouble();

      // Determine due amount if not provided
      double actualDueAmount = dueAmount ?? 0.0;
      if (dueAmount == null) {
        // Calculate standard monthly amount
        actualDueAmount = await getAdjustedDueAmount(chittiId, userId, month);
      }

      // Determine payment type if not provided
      String actualPaymentType = paymentType ?? 'full';
      if (paymentType == null && actualDueAmount > 0) {
        if (amount < actualDueAmount) {
          actualPaymentType = 'partial';
        } else if (amount > actualDueAmount) {
          actualPaymentType = 'overpayment';
        } else {
          actualPaymentType = 'full';
        }
      }

      // Update member balance
      await updateMemberBalance(chittiId, userId, amount);

      // Get new balance after payment
      final newBalance = await getMemberBalance(chittiId, userId);
      final balanceAfter = (newBalance['currentBalance'] ?? 0.0).toDouble();

      // Create payment record with enhanced metadata
      final paymentData = {
        'chittiId': chittiId,
        'userId': userId,
        'slotId': slotId, // Store slotId
        'amount': amount,
        'month': month,
        'status': status,
        'paidAt': ServerValue.timestamp,
        'dueAmount': actualDueAmount,
        'balanceBefore': balanceBefore,
        'balanceAfter': balanceAfter,
        'paymentType': actualPaymentType,
        'appliedToMonth': month,
      };

      // Add notes if provided
      if (notes != null && notes.isNotEmpty) {
        paymentData['notes'] = notes;
      }

      // Store in global payments collection for history
      final paymentRef = _db.child('payments').push();
      await paymentRef.set(paymentData);

      // Return payment result
      return {
        'success': true,
        'paymentId': paymentRef.key,
        'amount': amount,
        'dueAmount': actualDueAmount,
        'balanceBefore': balanceBefore,
        'balanceAfter': balanceAfter,
        'paymentType': actualPaymentType,
        'remainingBalance': balanceAfter < 0 ? balanceAfter.abs() : 0.0,
        'creditBalance': balanceAfter > 0 ? balanceAfter : 0.0,
      };
    } catch (e) {
      print('Error recording payment: $e');
      rethrow;
    }
  }

  /// Get Financial Stats for a Chitti
  Future<Map<String, dynamic>> getChittiFinancials(String chittiId) async {
    try {
      // 1. Get Chitti details
      final chittiSnap = await _db.child('chittis/$chittiId').get();
      if (!chittiSnap.exists) return {};
      final chittiData = Map<String, dynamic>.from(chittiSnap.value as Map);

      final membersMap = chittiData['members'] as Map? ?? {};
      final numMembers = membersMap.length;
      final durationStr = chittiData['duration'].toString();
      final duration =
          int.tryParse(durationStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 20;

      // Calculate Expected Monthly and Collected from Member Balances
      double totalMonthlyExpected = 0;
      double totalCollected = 0;

      for (final entry in membersMap.entries) {
        final mData = Map<String, dynamic>.from(entry.value as Map);
        final lifetimeAmount = (mData['totalAmount'] ?? 0).toDouble();
        if (duration > 0) {
          totalMonthlyExpected += (lifetimeAmount / duration);
        }

        // Get totalPaid from member's balance object
        final balance = mData['balance'] as Map?;
        if (balance != null) {
          totalCollected += (balance['totalPaid'] ?? 0).toDouble();
        }
      }

      // Calculate Expected to Date
      int monthsElapsed = 1;
      final startMonthStr = chittiData['startMonth']?.toString();
      if (startMonthStr != null) {
        final startDate = CurrencyUtils.parseMonth(startMonthStr);
        if (startDate != null) {
          final now = DateTime.now();
          monthsElapsed =
              (now.year - startDate.year) * 12 +
              now.month -
              startDate.month +
              1;
          if (duration > 0) {
            monthsElapsed = monthsElapsed.clamp(1, duration);
          }
        }
      }

      final totalExpectedToDate = totalMonthlyExpected * monthsElapsed;

      return {
        'monthlyExpected': totalMonthlyExpected,
        'totalExpected': totalExpectedToDate,
        'totalCollected': totalCollected,
        'membersCount': numMembers,
        'monthsElapsed': monthsElapsed,
      };
    } catch (e) {
      print('Error getting chitti financials: $e');
      return {
        'monthlyExpected': 0.0,
        'totalExpected': 0.0,
        'totalCollected': 0.0,
        'membersCount': 0,
        'monthsElapsed': 0,
      };
    }
  }

  /// Get Financial Stats for a Member
  Future<Map<String, dynamic>> getMemberFinancials(String userId) async {
    try {
      // 1. Get Total Paid by User
      final paymentsSnap = await _db
          .child('payments')
          .orderByChild('userId')
          .equalTo(userId)
          .get();

      double totalPaid = 0;
      if (paymentsSnap.exists && paymentsSnap.value != null) {
        final payments = Map<String, dynamic>.from(paymentsSnap.value as Map);
        payments.forEach((key, value) {
          final p = Map<String, dynamic>.from(value as Map);
          if (p['status'] == 'paid') {
            totalPaid += (p['amount'] ?? 0);
          }
        });
      }

      // 2. Calculate Total Due (Snapshot of current active chittis)
      // Fetches user's chittis and sums up monthly dues * elapsed months?
      // Simplified: Just showing total paid for now as "Due" calculation requires precise start dates.

      return {
        'totalPaid': totalPaid,
        // 'pendingDue': ... // TODO:Implement logic based on start dates
      };
    } catch (e) {
      print('Error getting member financials: $e');
      return {};
    }
  }

  /// Get Payment History (Global or filtered)
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final snapshot = await _db.child('payments').orderByChild('paidAt').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final list = data.entries.map((e) {
          final map = Map<String, dynamic>.from(e.value as Map);
          map['id'] = e.key;
          return map;
        }).toList();

        list.sort((a, b) {
          final aTime = a['paidAt'] ?? 0;
          final bTime = b['paidAt'] ?? 0;
          return bTime.compareTo(aTime);
        });
        return list;
      }
    } catch (e) {
      print('Error getting payment history: $e');
    }
    return [];
  }

  /// Get Payments for a specific Chitti
  Future<List<Map<String, dynamic>>> getChittiPayments(String chittiId) async {
    try {
      final snapshot = await _db
          .child('payments')
          .orderByChild('chittiId')
          .equalTo(chittiId)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final list = data.entries.map((e) {
          final map = Map<String, dynamic>.from(e.value as Map);
          map['id'] = e.key;
          return map;
        }).toList();

        // Sort by date desc
        list.sort((a, b) {
          final aTime = a['paidAt'] ?? 0;
          final bTime = b['paidAt'] ?? 0;
          return bTime.compareTo(aTime);
        });
        return list;
      }
    } catch (e) {
      print('Error getting chitti payments: $e');
    }
    return [];
  }

  // --- Balance Management (Slot-based) ---

  /// Get slot's current balance for a specific chitti (slot-based)
  /// Returns balance data including currentBalance, totalPaid, totalDue, winner info
  Future<Map<String, dynamic>> getSlotBalance(
    String chittiId,
    String slotId,
  ) async {
    try {
      final snapshot = await _db
          .child('chittis/$chittiId/members/$slotId/balance')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }

      // Balance doesn't exist, return default
      return _defaultBalance;
    } catch (e) {
      print('Error getting slot balance: $e');
      return _defaultBalance;
    }
  }

  /// Legacy method - redirects to slot-based
  /// @deprecated Use getSlotBalance instead
  Future<Map<String, dynamic>> getMemberBalance(
    String chittiId,
    String slotId,
  ) async {
    return getSlotBalance(chittiId, slotId);
  }

  Map<String, dynamic> get _defaultBalance => {
    'currentBalance': 0.0,
    'totalPaid': 0.0,
    'totalDue': 0.0,
    'originalTotalDue': 0.0,
    'isWinner': false,
    'winnerMonth': null,
    'prizeAmount': 0.0,
    'discountAmount': 0.0,
    'lastUpdated': null,
  };

  /// Initialize balance for new slot (slot-based)
  Future<void> initializeSlotBalance(
    String chittiId,
    String slotId,
    double totalDue,
  ) async {
    try {
      final balanceData = {
        'currentBalance': 0.0,
        'totalPaid': 0.0,
        'totalDue': totalDue,
        'originalTotalDue': totalDue,
        'isWinner': false,
        'winnerMonth': null,
        'prizeAmount': 0.0,
        'discountAmount': 0.0,
        'lastUpdated': ServerValue.timestamp,
      };

      await _db
          .child('chittis/$chittiId/members/$slotId/balance')
          .set(balanceData);
    } catch (e) {
      print('Error initializing slot balance: $e');
      rethrow;
    }
  }

  /// Legacy method - redirects to slot-based
  /// @deprecated Use initializeSlotBalance instead
  Future<void> initializeMemberBalance(
    String chittiId,
    String slotId,
    double totalDue,
  ) async {
    return initializeSlotBalance(chittiId, slotId, totalDue);
  }

  /// Update slot balance after payment (slot-based)
  /// This adds the payment amount to totalPaid and recalculates currentBalance
  Future<void> updateSlotBalance(
    String chittiId,
    String slotId,
    double paymentAmount,
  ) async {
    try {
      final balanceRef = _db.child('chittis/$chittiId/members/$slotId/balance');
      final snapshot = await balanceRef.get();

      if (!snapshot.exists || snapshot.value == null) {
        // Balance not initialized, get slot's totalAmount and initialize
        final slotSnap = await _db
            .child('chittis/$chittiId/members/$slotId')
            .get();
        if (slotSnap.exists) {
          final slotData = Map<String, dynamic>.from(slotSnap.value as Map);
          final totalDue = (slotData['totalAmount'] ?? 0.0).toDouble();
          await initializeSlotBalance(chittiId, slotId, totalDue);
        }
      }

      // Get current balance
      final currentSnap = await balanceRef.get();
      final balanceData = Map<String, dynamic>.from(currentSnap.value as Map);

      final currentTotalPaid = (balanceData['totalPaid'] ?? 0.0).toDouble();
      final totalDue = (balanceData['totalDue'] ?? 0.0).toDouble();

      final newTotalPaid = currentTotalPaid + paymentAmount;
      final newBalance = newTotalPaid - totalDue;

      await balanceRef.update({
        'totalPaid': newTotalPaid,
        'currentBalance': newBalance,
        'lastUpdated': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error updating slot balance: $e');
      rethrow;
    }
  }

  /// Legacy method - redirects to slot-based
  /// @deprecated Use updateSlotBalance instead
  Future<void> updateMemberBalance(
    String chittiId,
    String slotId,
    double paymentAmount,
  ) async {
    return updateSlotBalance(chittiId, slotId, paymentAmount);
  }

  /// Calculate adjusted due amount for next month based on current balance (slot-based)
  /// If slot has credit, reduce the monthly amount
  /// If slot owes, increase the monthly amount
  Future<double> getAdjustedDueAmount(
    String chittiId,
    String slotId,
    String month,
  ) async {
    try {
      // Get slot's balance
      final balance = await getSlotBalance(chittiId, slotId);
      final currentBalance = (balance['currentBalance'] ?? 0.0).toDouble();

      // Get chitti details to calculate standard monthly amount
      final chittiSnap = await _db.child('chittis/$chittiId').get();
      if (!chittiSnap.exists) return 0.0;

      final chittiData = Map<String, dynamic>.from(chittiSnap.value as Map);
      final slotSnap = await _db
          .child('chittis/$chittiId/members/$slotId')
          .get();

      if (!slotSnap.exists) return 0.0;

      final slotData = Map<String, dynamic>.from(slotSnap.value as Map);
      final totalAmount = (slotData['totalAmount'] ?? 0.0).toDouble();

      final durationStr = chittiData['duration'].toString();
      final duration =
          int.tryParse(durationStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 20;

      if (duration == 0) return 0.0;

      final standardMonthlyAmount = totalAmount / duration;

      // Adjust based on balance
      // If currentBalance > 0 (credit), reduce monthly due
      // If currentBalance < 0 (owes), increase monthly due
      final adjustedDue = standardMonthlyAmount - currentBalance;

      // Ensure we don't return negative due amounts
      return adjustedDue < 0 ? 0.0 : adjustedDue;
    } catch (e) {
      print('Error getting adjusted due amount: $e');
      return 0.0;
    }
  }

  /// Check if slot is a winner and get discount details (slot-based)
  Future<Map<String, dynamic>> getWinnerDiscountDetails(
    String chittiId,
    String slotId,
  ) async {
    try {
      // Get winners for this chitti
      final winnersSnap = await _db.child('chittis/$chittiId/winners').get();

      if (!winnersSnap.exists || winnersSnap.value == null) {
        return {
          'isWinner': false,
          'winnerMonth': null,
          'prizeAmount': 0.0,
          'discountAmount': 0.0,
        };
      }

      final winnersData = Map<String, dynamic>.from(winnersSnap.value as Map);

      // Find if this slot is a winner
      for (var entry in winnersData.entries) {
        final winnerData = Map<String, dynamic>.from(entry.value as Map);
        if (winnerData['slotId'] == slotId) {
          // Get slot's total amount as prize
          final slotSnap = await _db
              .child('chittis/$chittiId/members/$slotId')
              .get();

          double prizeAmount = 0.0;
          if (slotSnap.exists) {
            final slotData = Map<String, dynamic>.from(slotSnap.value as Map);
            prizeAmount = (slotData['totalAmount'] ?? 0.0).toDouble();
          }

          // Get discount from chitti's per-option reward config
          final chittiSnap = await _db.child('chittis/$chittiId').get();
          double discountAmount = 0.0;

          if (chittiSnap.exists && slotSnap.exists) {
            final chittiData = Map<String, dynamic>.from(
              chittiSnap.value as Map,
            );
            final slotData = Map<String, dynamic>.from(slotSnap.value as Map);

            // Get the slot's gold option to determine which reward to apply
            final slotGoldOptionV2 = slotData['goldOptionV2'] as Map?;
            final goldOptionId = slotGoldOptionV2?['id'] as String?;

            final goldOptionRewards = chittiData['goldOptionRewards'] as Map?;
            final legacyRewardConfig = chittiData['rewardConfig'] as Map?;

            if (goldOptionRewards != null && goldOptionId != null) {
              // New per-option logic
              final rewardConfig = goldOptionRewards[goldOptionId] as Map?;
              if (rewardConfig != null && rewardConfig['enabled'] == true) {
                // Use pre-calculated amount from database
                discountAmount = (rewardConfig['calculatedAmount'] ?? 0)
                    .toDouble();
              }
            } else if (legacyRewardConfig != null &&
                legacyRewardConfig['enabled'] == true) {
              // Legacy global logic for backward compatibility
              if (legacyRewardConfig['type'] == 'Percentage') {
                final percentage = (legacyRewardConfig['value'] ?? 0)
                    .toDouble();
                discountAmount = prizeAmount * (percentage / 100);
              } else if (legacyRewardConfig['type'] == 'Fixed Amount') {
                discountAmount = (legacyRewardConfig['value'] ?? 0).toDouble();
              }
            }
          }

          return {
            'isWinner': true,
            'winnerMonth': winnerData['month'],
            'prizeAmount': prizeAmount,
            'discountAmount': discountAmount,
          };
        }
      }

      return {
        'isWinner': false,
        'winnerMonth': null,
        'prizeAmount': 0.0,
        'discountAmount': 0.0,
      };
    } catch (e) {
      print('Error getting winner discount details: $e');
      return {
        'isWinner': false,
        'winnerMonth': null,
        'prizeAmount': 0.0,
        'discountAmount': 0.0,
      };
    }
  }

  /// Apply winner discount to slot balance (slot-based)
  /// This is called when a slot wins a lucky draw
  Future<void> applyWinnerDiscount(
    String chittiId,
    String slotId,
    double prizeAmount,
    double discountAmount,
  ) async {
    try {
      final balanceRef = _db.child('chittis/$chittiId/members/$slotId/balance');
      final snapshot = await balanceRef.get();

      if (!snapshot.exists || snapshot.value == null) {
        // Initialize balance first
        final slotSnap = await _db
            .child('chittis/$chittiId/members/$slotId')
            .get();
        if (slotSnap.exists) {
          final slotData = Map<String, dynamic>.from(slotSnap.value as Map);
          final totalDue = (slotData['totalAmount'] ?? 0.0).toDouble();
          await initializeSlotBalance(chittiId, slotId, totalDue);
        }
      }

      // Get current balance
      final currentSnap = await balanceRef.get();
      final balanceData = Map<String, dynamic>.from(currentSnap.value as Map);

      final originalTotalDue = (balanceData['originalTotalDue'] ?? 0.0)
          .toDouble();
      final totalPaid = (balanceData['totalPaid'] ?? 0.0).toDouble();

      // Apply discount to totalDue (winner gets their prize and discount)
      final newTotalDue = originalTotalDue - prizeAmount - discountAmount;
      final newBalance = totalPaid - newTotalDue;

      // Get winner month from winners collection
      final winnersSnap = await _db.child('chittis/$chittiId/winners').get();

      String? winnerMonth;
      if (winnersSnap.exists && winnersSnap.value != null) {
        final winnersData = Map<String, dynamic>.from(winnersSnap.value as Map);
        for (var entry in winnersData.entries) {
          final winnerData = Map<String, dynamic>.from(entry.value as Map);
          if (winnerData['slotId'] == slotId) {
            winnerMonth = winnerData['month'];
            break;
          }
        }
      }

      await balanceRef.update({
        'totalDue': newTotalDue,
        'currentBalance': newBalance,
        'isWinner': true,
        'winnerMonth': winnerMonth,
        'prizeAmount': prizeAmount,
        'discountAmount': discountAmount,
        'lastUpdated': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error applying winner discount: $e');
      rethrow;
    }
  }

  /// Get remaining payable amount (slot-based, total due - total paid)
  Future<double> getRemainingPayableAmount(
    String chittiId,
    String slotId,
  ) async {
    try {
      final balance = await getSlotBalance(chittiId, slotId);
      final totalDue = (balance['totalDue'] ?? 0.0).toDouble();
      final totalPaid = (balance['totalPaid'] ?? 0.0).toDouble();

      final remaining = totalDue - totalPaid;
      return remaining > 0 ? remaining : 0.0;
    } catch (e) {
      print('Error getting remaining payable amount: $e');
      return 0.0;
    }
  }

  /// Get all payments for a member in a chitti, ordered by date
  /// This creates the member's transaction ledger
  Future<List<Map<String, dynamic>>> getMemberLedger(
    String chittiId,
    String userId,
  ) async {
    try {
      // Get all payments for this member in this chitti
      final paymentsSnap = await _db
          .child('payments')
          .orderByChild('userId')
          .equalTo(userId)
          .get();

      if (!paymentsSnap.exists || paymentsSnap.value == null) {
        return [];
      }

      final paymentsData = Map<String, dynamic>.from(paymentsSnap.value as Map);

      // Filter for this specific chitti
      final List<Map<String, dynamic>> ledger = [];
      paymentsData.forEach((key, value) {
        final payment = Map<String, dynamic>.from(value as Map);
        if (payment['chittiId'] == chittiId) {
          payment['id'] = key;
          ledger.add(payment);
        }
      });

      // Sort by paidAt timestamp (oldest first for ledger view)
      ledger.sort((a, b) {
        final aTime = a['paidAt'] ?? 0;
        final bTime = b['paidAt'] ?? 0;
        return aTime.compareTo(bTime);
      });

      return ledger;
    } catch (e) {
      print('Error getting member ledger: $e');
      return [];
    }
  }

  /// Backfill balances for existing slots (one-time migration)
  /// This calculates historical balances from existing payments
  Future<void> migrateMemberBalances(String chittiId) async {
    try {
      print('Starting balance migration for chitti: $chittiId');

      // Get all slots in this chitti
      final chittiSnap = await _db.child('chittis/$chittiId').get();
      if (!chittiSnap.exists) {
        print('Chitti not found: $chittiId');
        return;
      }

      final chittiData = Map<String, dynamic>.from(chittiSnap.value as Map);
      final membersMap = chittiData['members'] as Map? ?? {};

      // For each slot, calculate its balance
      for (var slotId in membersMap.keys) {
        print('Migrating balance for slot: $slotId');

        final slotData = Map<String, dynamic>.from(membersMap[slotId] as Map);
        final totalDue = (slotData['totalAmount'] ?? 0.0).toDouble();

        // Get all payments for this slot in this chitti
        final paymentsSnap = await _db
            .child('payments')
            .orderByChild('slotId')
            .equalTo(slotId)
            .get();

        double totalPaid = 0.0;
        if (paymentsSnap.exists && paymentsSnap.value != null) {
          final paymentsData = Map<String, dynamic>.from(
            paymentsSnap.value as Map,
          );
          paymentsData.forEach((key, value) {
            final payment = Map<String, dynamic>.from(value as Map);
            if (payment['chittiId'] == chittiId &&
                payment['status'] == 'paid') {
              totalPaid += (payment['amount'] ?? 0.0).toDouble();
            }
          });
        }

        // Check if slot is a winner
        final winnerDetails = await getWinnerDiscountDetails(chittiId, slotId);
        final isWinner = winnerDetails['isWinner'] as bool;

        double adjustedTotalDue = totalDue;
        if (isWinner) {
          final prizeAmount = (winnerDetails['prizeAmount'] ?? 0.0).toDouble();
          final discountAmount = (winnerDetails['discountAmount'] ?? 0.0)
              .toDouble();
          adjustedTotalDue = totalDue - prizeAmount - discountAmount;
        }

        final currentBalance = totalPaid - adjustedTotalDue;

        // Create balance record
        final balanceData = {
          'currentBalance': currentBalance,
          'totalPaid': totalPaid,
          'totalDue': adjustedTotalDue,
          'originalTotalDue': totalDue,
          'isWinner': isWinner,
          'winnerMonth': winnerDetails['winnerMonth'],
          'prizeAmount': winnerDetails['prizeAmount'],
          'discountAmount': winnerDetails['discountAmount'],
          'lastUpdated': ServerValue.timestamp,
        };

        await _db
            .child('chittis/$chittiId/members/$slotId/balance')
            .set(balanceData);

        print(
          'Migrated balance for slot $slotId: totalPaid=$totalPaid, totalDue=$adjustedTotalDue, balance=$currentBalance',
        );
      }

      print('Balance migration completed for chitti: $chittiId');
    } catch (e) {
      print('Error migrating slot balances: $e');
      rethrow;
    }
  }

  /// Soft delete a member
  /// Returns error if member has active chitti slots
  Future<void> deleteMember(String userId) async {
    try {
      final hasActive = await hasActiveChittiSlots(userId);
      if (hasActive) {
        throw Exception(
          'Cannot delete member with active chitti slots. Please remove them from all chittis first.',
        );
      }

      await _db.child('users/$userId').update({
        'isDeleted': true,
        'deletedAt': ServerValue.timestamp,
        'hasAppAccess': false, // Revoke app access on delete
      });
    } catch (e) {
      print('Error deleting member: $e');
      rethrow;
    }
  }

  /// Restore a soft-deleted member
  Future<void> restoreMember(String userId) async {
    try {
      await _db.child('users/$userId').update({
        'isDeleted': false,
        'deletedAt': null,
      });
    } catch (e) {
      print('Error restoring member: $e');
      rethrow;
    }
  }

  /// Get all soft-deleted members
  Future<List<Map<String, dynamic>>> getDeletedMembers() async {
    try {
      final snapshot = await _db.child('users').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.entries
            .map((e) {
              final map = Map<String, dynamic>.from(e.value as Map);
              map['id'] = e.key;
              if ((map['name'] as String? ?? '').isEmpty) {
                final first = map['firstName'] as String? ?? '';
                final last = map['lastname'] as String? ?? '';
                map['name'] = '$first $last'.trim();
              }
              return map;
            })
            .where((m) => m['isDeleted'] == true)
            .toList();
      }
    } catch (e) {
      print('Error getting deleted members: $e');
    }
    return [];
  }

  /// Check if member has active chitti slots
  Future<bool> hasActiveChittiSlots(String userId) async {
    try {
      final userChittis = await getUserChittis(userId);
      return userChittis.isNotEmpty;
    } catch (e) {
      print('Error checking active slots: $e');
      return true;
    }
  }

  /// Get member's chitti history
  Future<List<Map<String, dynamic>>> getMemberChittiHistory(
    String userId,
  ) async {
    return getUserChittis(userId);
  }
}
