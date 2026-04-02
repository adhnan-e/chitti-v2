import 'package:firebase_database/firebase_database.dart';
import 'user_service.dart';

/// Chitti Service - Handles chitti CRUD and member management
class ChittiService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final UserService _userService = UserService();

  // Singleton
  static final ChittiService _instance = ChittiService._internal();
  factory ChittiService() => _instance;
  ChittiService._internal();

  /// Create a new Chitti
  Future<String> createChitti({
    required String name,
    required int duration,
    required String startMonth,
    String? endMonth,
    required List<Map<String, dynamic>> goldOptions,
    required int maxSlots,
    required int paymentDay,
    required int luckyDrawDay,
    required Map<String, Map<String, dynamic>> goldOptionRewards,
  }) async {
    final chittiRef = _db.child('chittis').push();

    // Calculate next dates
    final now = DateTime.now();
    final nextPaymentDate = DateTime(now.year, now.month, paymentDay);
    final nextWinnerDate = DateTime(now.year, now.month, luckyDrawDay);

    await chittiRef.set({
      'name': name,
      'duration': duration,
      'startMonth': startMonth,
      'endMonth': endMonth ?? _calculateEndMonth(startMonth, duration),
      'goldOptions': goldOptions,
      'maxSlots': maxSlots,
      'filledSlots': 0,
      'paymentDay': paymentDay,
      'luckyDrawDay': luckyDrawDay,
      'nextPaymentDate': nextPaymentDate.toIso8601String().split('T')[0],
      'nextWinnerDate': nextWinnerDate.toIso8601String().split('T')[0],
      'currentMonth': 0,
      'totalCollected': 0,
      'totalExpected': 0,
      'outstandingDuesCount': 0,
      'goldOptionRewards': goldOptionRewards,
      'status': 'pending',
      'createdAt': ServerValue.timestamp,
      'members': {},
      'winners': {},
    });

    return chittiRef.key!;
  }

  String _calculateEndMonth(String startMonth, int duration) {
    // Parse "January 2024" format
    final parts = startMonth.split(' ');
    if (parts.length != 2) return startMonth;

    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final monthIndex = months.indexOf(parts[0]);
    final year = int.tryParse(parts[1]) ?? DateTime.now().year;

    if (monthIndex == -1) return startMonth;

    final endMonthIndex = (monthIndex + duration - 1) % 12;
    final endYear = year + ((monthIndex + duration - 1) ~/ 12);

    return '${months[endMonthIndex]} $endYear';
  }

  /// Start a Chitti
  Future<void> startChitti(String chittiId) async {
    await _db.child('chittis/$chittiId').update({
      'status': 'active',
      'currentMonth': 1,
      'startedAt': ServerValue.timestamp,
    });
  }

  /// Update Chitti
  Future<void> updateChitti(String chittiId, Map<String, dynamic> data) async {
    try {
      await _db.child('chittis/$chittiId').update(data);
    } catch (e) {
      print('Error updating chitti: $e');
      rethrow;
    }
  }

  /// Get a specific Chitti
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

  /// Get Chitti as a stream
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

  /// Get all Chittis
  Future<List<Map<String, dynamic>>> getAllChittis() async {
    try {
      final snapshot = await _db.child('chittis').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.entries.map((e) {
          final map = Map<String, dynamic>.from(e.value as Map);
          map['id'] = e.key;
          return map;
        }).toList();
      }
    } catch (e) {
      print('Error getting chittis: $e');
    }
    return [];
  }

  /// Get Chittis for a specific user (with their slot details)
  Future<List<Map<String, dynamic>>> getUserChittis(String userId) async {
    try {
      final userChittisSnap = await _db.child('users/$userId/chittis').get();
      if (!userChittisSnap.exists || userChittisSnap.value == null) {
        return [];
      }

      final userChittisMap = Map<String, dynamic>.from(
        userChittisSnap.value as Map,
      );
      final chittiIds = userChittisMap.keys.toList();

      final List<Map<String, dynamic>> chittis = [];
      for (var chittiId in chittiIds) {
        final chittiSnap = await _db.child('chittis/$chittiId').get();
        if (chittiSnap.exists && chittiSnap.value != null) {
          final chittiData = Map<String, dynamic>.from(chittiSnap.value as Map);
          chittiData['id'] = chittiId;
          chittiData['user_status'] = userChittisMap[chittiId]['status'];
          chittiData['joinedAt'] = userChittisMap[chittiId]['joinedAt'];

          // Get all user's slots in this chitti (slot-based structure)
          final userSlots = await getUserSlotsInChitti(chittiId, userId);
          chittiData['user_slots'] = userSlots;
          chittiData['user_slot_count'] = userSlots.length;

          // For backward compatibility, use the first slot's data as user_details
          if (userSlots.isNotEmpty) {
            chittiData['user_details'] = userSlots.first;
          }

          chittis.add(chittiData);
        }
      }
      return chittis;
    } catch (e) {
      print('Error getting user chittis: $e');
      return [];
    }
  }

  /// Add a member to a Chitti (slot-based storage)
  /// Each slot is stored separately, allowing the same user to have multiple slots
  Future<void> addMemberToChitti({
    required String chittiId,
    required String userId,
    required String userName,
    required int slotNumber,
    required Map<String, dynamic> selectedGoldOption,
    required double totalAmount,
  }) async {
    // Get chitti to calculate monthly amount
    final chitti = await getChitti(chittiId);
    if (chitti == null) throw Exception('Chitti not found');

    final duration = chitti['duration'] as int? ?? 20;
    final monthlyAmount = totalAmount / duration;

    // Generate slot ID
    final slotId = 'slot_$slotNumber';

    // Add slot to chitti (using slot-based key instead of userId)
    await _db.child('chittis/$chittiId/members/$slotId').set({
      'userId': userId,
      'userName': userName,
      'slotNumber': slotNumber,
      'goldOption': selectedGoldOption,
      'totalAmount': totalAmount,
      'joinedAt': ServerValue.timestamp,
      'balance': {
        'currentBalance': 0.0,
        'totalPaid': 0.0,
        'totalDue': totalAmount,
        'originalTotalDue': totalAmount,
        'currentMonthlyAmount': monthlyAmount,
        'originalMonthlyAmount': monthlyAmount,
        'remainingMonths': duration,
        'isWinner': false,
        'winnerMonth': null,
        'discountStartMonth': null,
        'prizeAmount': 0.0,
        'discountAmount': 0.0,
        'lastPaymentDate': null,
        'missedPayments': 0,
        'lastUpdated': ServerValue.timestamp,
      },
    });

    // Update user's chittis list (track that user is in this chitti)
    await _db.child('users/$userId/chittis/$chittiId').set({
      'joinedAt': ServerValue.timestamp,
      'status': 'active',
    });

    // Update chitti counters
    await _updateChittiCounters(chittiId);
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

  /// Get user's slots in a specific chitti
  Future<List<Map<String, dynamic>>> getUserSlotsInChitti(
    String chittiId,
    String userId,
  ) async {
    final chitti = await getChitti(chittiId);
    if (chitti == null) return [];

    final membersMap = chitti['members'] as Map? ?? {};
    final List<Map<String, dynamic>> userSlots = [];

    for (var entry in membersMap.entries) {
      final slotData = Map<String, dynamic>.from(entry.value as Map);
      if (slotData['userId'] == userId) {
        slotData['slotId'] = entry.key;
        userSlots.add(slotData);
      }
    }
    return userSlots;
  }

  /// Update chitti counters (filledSlots, totalExpected, etc.)
  Future<void> _updateChittiCounters(String chittiId) async {
    try {
      final chittiSnap = await _db.child('chittis/$chittiId').get();
      if (!chittiSnap.exists) return;

      final chittiData = Map<String, dynamic>.from(chittiSnap.value as Map);
      final membersMap = chittiData['members'] as Map? ?? {};

      int filledSlots = 0;
      double totalExpected = 0;
      int outstandingDuesCount = 0;

      membersMap.forEach((uid, data) {
        final mData = Map<String, dynamic>.from(data as Map);
        filledSlots++;
        totalExpected += (mData['totalAmount'] ?? 0).toDouble();

        final balance = mData['balance'] as Map?;
        if (balance != null) {
          final currentBalance = (balance['currentBalance'] ?? 0).toDouble();
          if (currentBalance < 0) outstandingDuesCount++;
        }
      });

      await _db.child('chittis/$chittiId').update({
        'filledSlots': filledSlots,
        'totalExpected': totalExpected,
        'outstandingDuesCount': outstandingDuesCount,
      });
    } catch (e) {
      print('Error updating chitti counters: $e');
    }
  }

  /// Get member details for a chitti (slot-based structure)
  /// Returns a list of all slots with user details
  Future<List<Map<String, dynamic>>> getChittiMembersDetails(
    String chittiId,
  ) async {
    try {
      final chittiSnap = await _db.child('chittis/$chittiId').get();
      if (!chittiSnap.exists) return [];

      final chittiData = Map<String, dynamic>.from(chittiSnap.value as Map);
      final membersMap = chittiData['members'] as Map? ?? {};

      final List<Map<String, dynamic>> slotDetails = [];

      // Cache user profiles to avoid duplicate fetches
      final Map<String, Map<String, dynamic>?> userProfileCache = {};

      for (var entry in membersMap.entries) {
        final slotId = entry.key;
        final slotData = Map<String, dynamic>.from(entry.value as Map);
        final userId = slotData['userId'] as String?;

        if (userId == null) continue;

        // Get user profile from cache or fetch
        if (!userProfileCache.containsKey(userId)) {
          userProfileCache[userId] = await _userService.getUserProfile(userId);
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
            'balance': slotData['balance'],
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

  /// Advance chitti to next month
  Future<void> advanceMonth(String chittiId) async {
    try {
      final chitti = await getChitti(chittiId);
      if (chitti == null) return;

      final currentMonth = chitti['currentMonth'] as int? ?? 0;
      final duration = chitti['duration'] as int? ?? 20;
      final paymentDay = chitti['paymentDay'] as int? ?? 15;
      final luckyDrawDay = chitti['luckyDrawDay'] as int? ?? 20;

      if (currentMonth >= duration) {
        // Complete the chitti
        await _db.child('chittis/$chittiId').update({
          'status': 'completed',
          'completedAt': ServerValue.timestamp,
        });
        return;
      }

      // Calculate next dates
      final now = DateTime.now();
      final nextMonth = DateTime(now.year, now.month + 1);
      final nextPaymentDate = DateTime(
        nextMonth.year,
        nextMonth.month,
        paymentDay,
      );
      final nextWinnerDate = DateTime(
        nextMonth.year,
        nextMonth.month,
        luckyDrawDay,
      );

      await _db.child('chittis/$chittiId').update({
        'currentMonth': currentMonth + 1,
        'nextPaymentDate': nextPaymentDate.toIso8601String().split('T')[0],
        'nextWinnerDate': nextWinnerDate.toIso8601String().split('T')[0],
      });
    } catch (e) {
      print('Error advancing month: $e');
      rethrow;
    }
  }
}
