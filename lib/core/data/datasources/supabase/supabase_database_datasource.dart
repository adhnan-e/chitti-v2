import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chitt/core/domain/repositories/i_database_repository.dart';

class SupabaseDatabaseDatasource implements IDatabaseRepository {
  final SupabaseClient _client = Supabase.instance.client;

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
    await _client.from('chittis').insert({
      'name': name,
      'duration': duration,
      'start_month': startMonth,
      'gold_options': goldOptions,
      'max_slots': maxSlots,
      'payment_day': paymentDay,
      'lucky_draw_day': luckyDrawDay,
      'reward_config': rewardConfig,
      'status': 'pending',
    });
  }

  @override
  Future<void> startChitti(String chittiId) async {
    await _client.from('chittis').update({'status': 'active'}).eq('id', chittiId);
  }

  @override
  Future<void> updateChitti(String chittiId, Map<String, dynamic> data) async {
    await _client.from('chittis').update(data).eq('id', chittiId);
  }

  @override
  Future<Map<String, dynamic>?> getChitti(String chittiId) async {
    final response = await _client.from('chittis').select().eq('id', chittiId).maybeSingle();
    return response != null ? Map<String, dynamic>.from(response) : null;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllChittis() async {
    final response = await _client.from('chittis').select();
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getUserChittis(String userId) async {
    final response = await _client
        .from('chittis')
        .select('*, slots!inner(user_id)')
        .eq('slots.user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Stream<Map<String, dynamic>> getChittiStream(String chittiId) {
    return _client
        .from('chittis')
        .stream(primaryKey: ['id'])
        .eq('id', chittiId)
        .map((list) => list.isNotEmpty ? Map<String, dynamic>.from(list.first) : {});
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
    final names = name.split(' ');
    final firstName = names.isNotEmpty ? names.first : name;
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    await _client.from('users').insert({
      'username': username,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'address': address,
      'role': role,
      'photo_url': photoUrl,
      'documents': documents ?? [],
      'has_app_access': needsAppAccess,
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

    await _client.from('users').update({
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'address': address,
      'username': username,
      'password': password,
      'photo_url': photoUrl,
      'documents': documents,
      'has_app_access': needsAppAccess,
    }).eq('id', userId);
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _client.from('users').select().eq('id', userId).maybeSingle();
    return response != null ? Map<String, dynamic>.from(response) : null;
  }

  @override
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _client.from('users').update(data).eq('id', userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _client.from('users').select();
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final response = await _client
        .from('users')
        .select()
        .or('username.ilike.%$query%,first_name.ilike.%$query%,last_name.ilike.%$query%,phone.ilike.%$query%');
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>?> findMemberByPhone(String phone) async {
    final response = await _client.from('users').select().eq('phone', phone).maybeSingle();
    return response != null ? Map<String, dynamic>.from(response) : null;
  }

  @override
  Future<void> deleteMember(String userId) async {
    await _client.from('users').update({'is_deleted': true}).eq('id', userId);
  }

  @override
  Future<void> restoreMember(String userId) async {
    await _client.from('users').update({'is_deleted': false}).eq('id', userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getDeletedMembers() async {
    final response = await _client.from('users').select().eq('is_deleted', true);
    return List<Map<String, dynamic>>.from(response);
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
    await _client.from('slots').insert({
      'chitti_id': chittiId,
      'user_id': userId,
      'user_name': userName,
      'slot_number': slotNumber,
      'selected_gold_option': selectedGoldOption,
      'total_amount': totalAmount,
    });
  }

  @override
  Future<int> getNextSlotNumber(String chittiId) async {
    final response = await _client
        .from('slots')
        .select('slot_number')
        .eq('chitti_id', chittiId)
        .order('slot_number', ascending: false)
        .limit(1)
        .maybeSingle();
    if (response != null) {
      return (response['slot_number'] as int) + 1;
    }
    return 1;
  }

  @override
  Future<List<Map<String, dynamic>>> getChittiMembersDetails(String chittiId) async {
    final response = await _client
        .from('slots')
        .select('*, users(*)')
        .eq('chitti_id', chittiId);
    return List<Map<String, dynamic>>.from(response);
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
    final response = await _client.from('payments').insert({
      'chitti_id': chittiId,
      'user_id': userId,
      'slot_id': slotId,
      'amount': amount,
      'payment_method': paymentMethod,
      'received_by': receivedBy,
      'notes': notes,
      'status': 'paid',
    }).select().single();
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getChittiPayments(String chittiId) async {
    final response = await _client.from('payments').select().eq('chitti_id', chittiId);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    final response = await _client.from('payments').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> getChittiFinancials(String chittiId) async {
    final response = await _client.rpc('get_chitti_financials', params: {'p_chitti_id': chittiId});
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<Map<String, dynamic>> getSlotBalance(String chittiId, String slotId) async {
    final response = await _client
        .from('slot_balances')
        .select()
        .eq('chitti_id', chittiId)
        .eq('slot_id', slotId)
        .maybeSingle();
    return response != null ? Map<String, dynamic>.from(response) : {};
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
    await _client.from('winners').insert({
      'chitti_id': chittiId,
      'chitti_name': chittiName,
      'month_key': monthKey,
      'month_label': monthLabel,
      'user_id': userId,
      'user_name': userName,
      'slot_id': slotId,
      'slot_number': slotNumber,
      'prize': prize,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getChittiWinners(String chittiId) async {
    final response = await _client.from('winners').select().eq('chitti_id', chittiId);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getLuckyDrawHistory() async {
    final response = await _client.from('winners').select('*, chittis(name)');
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> getAppSettings() async {
    final response = await _client.from('settings').select().maybeSingle();
    return response != null ? Map<String, dynamic>.from(response) : {'currency_symbol': '₹'};
  }

  @override
  Future<void> updateAppSettings(Map<String, dynamic> data) async {
    await _client.from('settings').update(data);
  }

  @override
  String getCurrencySymbol() => '₹';
}
