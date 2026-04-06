abstract class IDatabaseRepository {
  // Chitti Operations
  Future<void> createChitti({
    required String name,
    required int duration,
    required String startMonth,
    required List<Map<String, dynamic>> goldOptions,
    required int maxSlots,
    required int paymentDay,
    required int luckyDrawDay,
    required Map<String, dynamic> rewardConfig,
  });
  Future<void> startChitti(String chittiId);
  Future<void> updateChitti(String chittiId, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getChitti(String chittiId);
  Future<List<Map<String, dynamic>>> getAllChittis();
  Future<List<Map<String, dynamic>>> getUserChittis(String userId);
  Stream<Map<String, dynamic>> getChittiStream(String chittiId);

  // User/Member Operations
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
  });
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
  });
  Future<Map<String, dynamic>?> getUserProfile(String userId);
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getAllUsers();
  Future<List<Map<String, dynamic>>> searchUsers(String query);
  Future<Map<String, dynamic>?> findMemberByPhone(String phone);
  Future<void> deleteMember(String userId);
  Future<void> restoreMember(String userId);
  Future<List<Map<String, dynamic>>> getDeletedMembers();

  // Slot Operations
  Future<void> addMemberToChitti({
    required String chittiId,
    required String userId,
    required String userName,
    required int slotNumber,
    required Map<String, dynamic> selectedGoldOption,
    required double totalAmount,
  });
  Future<int> getNextSlotNumber(String chittiId);
  Future<List<Map<String, dynamic>>> getChittiMembersDetails(String chittiId);

  // Financial/Payment Operations
  Future<Map<String, dynamic>> recordPayment({
    required String chittiId,
    required String userId,
    required String slotId,
    required double amount,
    required String paymentMethod,
    required String receivedBy,
    String? notes,
  });
  Future<List<Map<String, dynamic>>> getChittiPayments(String chittiId);
  Future<List<Map<String, dynamic>>> getUserPayments(String userId);
  Future<Map<String, dynamic>> getChittiFinancials(String chittiId);
  Future<Map<String, dynamic>> getSlotBalance(String chittiId, String slotId);

  // Winner Operations
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
  });
  Future<List<Map<String, dynamic>>> getChittiWinners(String chittiId);
  Future<List<Map<String, dynamic>>> getLuckyDrawHistory();

  // Settings
  Future<Map<String, dynamic>> getAppSettings();
  Future<void> updateAppSettings(Map<String, dynamic> data);
  String getCurrencySymbol();
}
