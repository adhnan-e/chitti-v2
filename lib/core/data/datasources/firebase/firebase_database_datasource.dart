import 'package:firebase_database/firebase_database.dart';
import 'package:chitt/core/domain/repositories/i_database_repository.dart';

class FirebaseDatabaseDatasource implements IDatabaseRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  @override
  Future<void> createChitti({
    required String name,
    required int duration,
    required String startMonth,
    required List<Map<String, dynamic>> goldOptions,
    required int maxSlots,
    required int paymentDay,
    required int luckyDrawDay,
    required Map<String, dynamic> rewardConfig,
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
      'status': 'pending',
      'createdAt': ServerValue.timestamp,
      'members': {},
    });
  }

  @override
  Future<void> startChitti(String chittiId) async {
    await _db.child('chittis/$chittiId').update({
      'status': 'active',
      'startedAt': ServerValue.timestamp,
    });
  }

  @override
  Future<void> updateChitti(String chittiId, Map<String, dynamic> data) async {
    await _db.child('chittis/$chittiId').update(data);
  }

  @override
  Future<Map<String, dynamic>?> getChitti(String chittiId) async {
    final snapshot = await _db.child('chittis/$chittiId').get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data['id'] = chittiId;
      return data;
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllChittis() async {
    final snapshot = await _db.child('chittis').get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.entries.map((e) {
        final map = Map<String, dynamic>.from(e.value as Map);
        map['id'] = e.key;
        return map;
      }).toList();
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getUserChittis(String userId) async {
    final chittis = await getAllChittis();
    return chittis.where((chitti) {
      final members = chitti['members'] as Map? ?? {};
      return members.values.any((slot) {
          return (slot as Map)['userId'] == userId;
      });
    }).toList();
  }

  @override
  Stream<Map<String, dynamic>> getChittiStream(String chittiId) {
    return _db.child('chittis/$chittiId').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data['id'] = chittiId;
        return data;
      }
      return {};
    });
  }

  @override
  Future<void> createUser({
    required String name,
    required String phone,
    String? email,
    String? address,
    String? username,
    String? password,
    bool? needsAppAccess,
    String? photoUrl,
    List<Map<String, dynamic>>? documents,
    String role = 'user',
  }) async {
    final userRef = _db.child('users').push();
    final names = name.split(' ');
    final firstName = names.isNotEmpty ? names.first : name;
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    await userRef.set({
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastname': lastName,
      'phone': phone,
      'email': email,
      'address': address,
      'role': role,
      'photoUrl': photoUrl,
      'documents': documents ?? [],
      'hasAppAccess': needsAppAccess,
      'createdAt': ServerValue.timestamp,
    });
  }

  @override
  Future<void> updateUser({
    required String userId,
    required String name,
    required String phone,
    String? email,
    String? address,
    String? username,
    String? password,
    bool? needsAppAccess,
    String? photoUrl,
    List<Map<String, dynamic>>? documents,
  }) async {
    final names = name.split(' ');
    final firstName = names.isNotEmpty ? names.first : name;
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    await _db.child('users/$userId').update({
      'firstName': firstName,
      'lastname': lastName,
      'phone': phone,
      'email': email,
      'address': address,
      'username': username,
      'password': password,
      'photoUrl': photoUrl,
      'documents': documents,
      'hasAppAccess': needsAppAccess,
      'updatedAt': ServerValue.timestamp,
    });
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final snapshot = await _db.child('users/$userId').get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data['id'] = userId;
      return data;
    }
    return null;
  }

  @override
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _db.child('users/$userId').update(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snapshot = await _db.child('users').get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.entries.map((e) {
        final map = Map<String, dynamic>.from(e.value as Map);
        map['id'] = e.key;
        return map;
      }).toList();
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final allUsers = await getAllUsers();
    final lowerQuery = query.toLowerCase();
    return allUsers.where((user) {
      final firstName = (user['firstName'] as String? ?? '').toLowerCase();
      final lastName = (user['lastname'] as String? ?? '').toLowerCase();
      final username = (user['username'] as String? ?? '').toLowerCase();
      final phone = (user['phone'] as String? ?? '').toLowerCase();
      return firstName.contains(lowerQuery) ||
          lastName.contains(lowerQuery) ||
          username.contains(lowerQuery) ||
          phone.contains(lowerQuery);
    }).toList();
  }

  @override
  Future<Map<String, dynamic>?> findMemberByPhone(String phone) async {
    final snapshot = await _db.child('users').orderByChild('phone').equalTo(phone).get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final id = data.keys.first;
      final userData = Map<String, dynamic>.from(data[id] as Map);
      userData['id'] = id;
      return userData;
    }
    return null;
  }

  @override
  Future<void> deleteMember(String userId) async {
    await _db.child('users/$userId').update({
      'isDeleted': true,
      'deletedAt': ServerValue.timestamp,
    });
  }

  @override
  Future<void> restoreMember(String userId) async {
    await _db.child('users/$userId').update({
      'isDeleted': false,
      'deletedAt': null,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getDeletedMembers() async {
    final allUsers = await getAllUsers();
    return allUsers.where((user) => user['isDeleted'] == true).toList();
  }

  @override
  Future<void> addMemberToChitti({
    required String chittiId,
    required String userId,
    required String userName,
    required int slotNumber,
    required Map<String, dynamic> selectedGoldOption,
    required double totalAmount,
  }) async {
    final slotId = 'slot_${DateTime.now().millisecondsSinceEpoch}_$slotNumber';
    await _db.child('chittis/$chittiId/members/$slotId').set({
      'userId': userId,
      'userName': userName,
      'slotNumber': slotNumber,
      'selectedGoldOption': selectedGoldOption,
      'totalAmount': totalAmount,
      'joinedAt': ServerValue.timestamp,
    });
  }

  @override
  Future<int> getNextSlotNumber(String chittiId) async {
    final snapshot = await _db.child('chittis/$chittiId/members').get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      int max = 0;
      for (var slot in data.values) {
        final num = (slot as Map)['slotNumber'] as int? ?? 0;
        if (num > max) max = num;
      }
      return max + 1;
    }
    return 1;
  }

  @override
  Future<List<Map<String, dynamic>>> getChittiMembersDetails(String chittiId) async {
    final snapshot = await _db.child('chittis/$chittiId/members').get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final List<Map<String, dynamic>> details = [];
      for (var entry in data.entries) {
        final slotData = Map<String, dynamic>.from(entry.value as Map);
        slotData['id'] = entry.key;
        details.add(slotData);
      }
      return details;
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> recordPayment({
    required String chittiId,
    required String userId,
    required String slotId,
    required double amount,
    required String paymentMethod,
    required String receivedBy,
    String? notes,
  }) async {
    final paymentRef = _db.child('payments').push();
    final paymentData = {
      'chittiId': chittiId,
      'userId': userId,
      'slotId': slotId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'receivedBy': receivedBy,
      'notes': notes,
      'paidAt': ServerValue.timestamp,
      'status': 'paid',
    };
    await paymentRef.set(paymentData);
    return {...paymentData, 'id': paymentRef.key};
  }

  @override
  Future<List<Map<String, dynamic>>> getChittiPayments(String chittiId) async {
    final snapshot = await _db.child('payments').orderByChild('chittiId').equalTo(chittiId).get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.entries.map((e) {
        final map = Map<String, dynamic>.from(e.value as Map);
        map['id'] = e.key;
        return map;
      }).toList();
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    final snapshot = await _db.child('payments').orderByChild('userId').equalTo(userId).get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.entries.map((e) {
        final map = Map<String, dynamic>.from(e.value as Map);
        map['id'] = e.key;
        return map;
      }).toList();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getChittiFinancials(String chittiId) async {
    final payments = await getChittiPayments(chittiId);
    double totalCollected = 0;
    for (var p in payments) {
      totalCollected += (p['amount'] ?? 0).toDouble();
    }
    return {
      'totalCollected': totalCollected,
    };
  }

  @override
  Future<Map<String, dynamic>> getSlotBalance(String chittiId, String slotId) async {
    final snapshot = await _db.child('chittis/$chittiId/members/$slotId/balance').get();
    if (snapshot.exists && snapshot.value != null) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return {};
  }

  @override
  Future<void> addWinner({
    required String chittiId,
    required String chittiName,
    required String monthKey,
    required String monthLabel,
    required String userId,
    required String userName,
    required String slotId,
    required int slotNumber,
    required String prize,
  }) async {
    await _db.child('chittis/$chittiId/winners').push().set({
      'slotId': slotId,
      'userId': userId,
      'userName': userName,
      'slotNumber': slotNumber,
      'monthKey': monthKey,
      'monthLabel': monthLabel,
      'prize': prize,
      'chittiName': chittiName,
      'wonAt': ServerValue.timestamp,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getChittiWinners(String chittiId) async {
    final snapshot = await _db.child('chittis/$chittiId/winners').get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.entries.map((e) {
        final map = Map<String, dynamic>.from(e.value as Map);
        map['id'] = e.key;
        return map;
      }).toList();
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getLuckyDrawHistory() async {
    final snapshot = await _db.child('chittis').get();
    List<Map<String, dynamic>> allWinners = [];
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      for (var chittiId in data.keys) {
        final winners = await getChittiWinners(chittiId);
        allWinners.addAll(winners);
      }
    }
    return allWinners;
  }

  @override
  Future<Map<String, dynamic>> getAppSettings() async {
    final snapshot = await _db.child('settings').get();
    if (snapshot.exists && snapshot.value != null) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return {'currencySymbol': '₹'};
  }

  @override
  Future<void> updateAppSettings(Map<String, dynamic> data) async {
    await _db.child('settings').update(data);
  }

  @override
  String getCurrencySymbol() => '₹';
}
