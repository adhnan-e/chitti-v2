import 'package:chitt/core/di/service_locator.dart';
import 'package:chitt/core/domain/repositories/i_database_repository.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  IDatabaseRepository get _repo => getIt<IDatabaseRepository>();

  Future<void> createChitti({
    required String name,
    required int duration,
    required String startMonth,
    required List<Map<String, dynamic>> goldOptions,
    required int maxSlots,
    required int paymentDay,
    required int luckyDrawDay,
    required Map<String, dynamic> rewardConfig,
  }) => _repo.createChitti(
    name: name,
    duration: duration,
    startMonth: startMonth,
    goldOptions: goldOptions,
    maxSlots: maxSlots,
    paymentDay: paymentDay,
    luckyDrawDay: luckyDrawDay,
    rewardConfig: rewardConfig,
  );

  Future<void> startChitti(String chittiId) => _repo.startChitti(chittiId);

  Future<void> updateChitti(String chittiId, Map<String, dynamic> data) =>
      _repo.updateChitti(chittiId, data);

  Future<Map<String, dynamic>?> getChitti(String chittiId) => _repo.getChitti(chittiId);

  Future<List<Map<String, dynamic>>> getAllChittis() => _repo.getAllChittis();

  Future<List<Map<String, dynamic>>> getUserChittis(String userId) =>
      _repo.getUserChittis(userId);

  Stream<Map<String, dynamic>> getChittiStream(String chittiId) =>
      _repo.getChittiStream(chittiId);

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
  }) => _repo.createUser(
    name: name,
    phone: phone,
    email: email,
    address: address,
    username: username,
    password: password,
    needsAppAccess: needsAppAccess,
    photoUrl: photoUrl,
    documents: documents,
    role: role,
  );

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
  }) => _repo.updateUser(
    userId: userId,
    name: name,
    phone: phone,
    email: email,
    address: address,
    username: username,
    password: password,
    needsAppAccess: needsAppAccess,
    photoUrl: photoUrl,
    documents: documents,
  );

  Future<Map<String, dynamic>?> getUserProfile(String userId) =>
      _repo.getUserProfile(userId);

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) =>
      _repo.updateUserProfile(userId, data);

  Future<List<Map<String, dynamic>>> getAllUsers() => _repo.getAllUsers();

  Future<List<Map<String, dynamic>>> searchUsers(String query) =>
      _repo.searchUsers(query);

  Future<Map<String, dynamic>?> findMemberByPhone(String phone) =>
      _repo.findMemberByPhone(phone);

  Future<void> deleteMember(String userId) => _repo.deleteMember(userId);

  Future<void> restoreMember(String userId) => _repo.restoreMember(userId);

  Future<List<Map<String, dynamic>>> getDeletedMembers() =>
      _repo.getDeletedMembers();

  Future<void> addMemberToChitti({
    required String chittiId,
    required String userId,
    required String userName,
    required int slotNumber,
    required Map<String, dynamic> selectedGoldOption,
    required double totalAmount,
  }) => _repo.addMemberToChitti(
    chittiId: chittiId,
    userId: userId,
    userName: userName,
    slotNumber: slotNumber,
    selectedGoldOption: selectedGoldOption,
    totalAmount: totalAmount,
  );

  Future<int> getNextSlotNumber(String chittiId) => _repo.getNextSlotNumber(chittiId);

  Future<List<Map<String, dynamic>>> getChittiMembersDetails(String chittiId) =>
      _repo.getChittiMembersDetails(chittiId);

  Future<Map<String, dynamic>> recordPayment({
    required String chittiId,
    required String userId,
    required String slotId,
    required double amount,
    required String paymentMethod,
    required String receivedBy,
    String? notes,
  }) => _repo.recordPayment(
    chittiId: chittiId,
    userId: userId,
    slotId: slotId,
    amount: amount,
    paymentMethod: paymentMethod,
    receivedBy: receivedBy,
    notes: notes,
  );

  Future<List<Map<String, dynamic>>> getChittiPayments(String chittiId) =>
      _repo.getChittiPayments(chittiId);

  Future<List<Map<String, dynamic>>> getUserPayments(String userId) =>
      _repo.getUserPayments(userId);

  Future<Map<String, dynamic>> getChittiFinancials(String chittiId) =>
      _repo.getChittiFinancials(chittiId);

  Future<Map<String, dynamic>> getSlotBalance(String chittiId, String slotId) =>
      _repo.getSlotBalance(chittiId, slotId);

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
  }) => _repo.addWinner(
    chittiId: chittiId,
    chittiName: chittiName,
    monthKey: monthKey,
    monthLabel: monthLabel,
    userId: userId,
    userName: userName,
    slotId: slotId,
    slotNumber: slotNumber,
    prize: prize,
  );

  Future<List<Map<String, dynamic>>> getChittiWinners(String chittiId) =>
      _repo.getChittiWinners(chittiId);

  Future<List<Map<String, dynamic>>> getLuckyDrawHistory() =>
      _repo.getLuckyDrawHistory();

  Future<Map<String, dynamic>> getAppSettings() => _repo.getAppSettings();

  Future<void> updateAppSettings(Map<String, dynamic> data) =>
      _repo.updateAppSettings(data);

  String getCurrencySymbol() => _repo.getCurrencySymbol();
}
