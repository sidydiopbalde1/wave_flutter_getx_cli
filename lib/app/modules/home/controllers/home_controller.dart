// home_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';
import 'package:logger/logger.dart';

class HomeController extends GetxController {
  // Instances Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final logger = Logger();

  // Variables réactives
  final RxBool isBalanceVisible = true.obs;
  final RxDouble balance = 0.0.obs;
  final RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble totalSent = 0.0.obs;
  final RxDouble totalReceived = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      fetchBalance(),
      fetchUserTransactions(),
    ]);
  }

  void toggleBalanceVisibility() => isBalanceVisible.toggle();

  Future<void> fetchBalance() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      logger.i('Fetching balance for user: ${user?.uid}');

      if (user != null) {
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          balance.value = (docSnapshot.data()?['solde'] ?? 0).toDouble();
        } else {
          _showError('Profil utilisateur non trouvé');
        }
      }
    } catch (e) {
      logger.e('Error fetching balance: $e');
      _showError('Impossible de récupérer le solde');
    } finally {
      isLoading.value = false;
    }
  }

Future<void> fetchUserTransactions() async {
  try {
    isLoading.value = true;
    final user = _auth.currentUser;

    if (user != null) {
      final QuerySnapshot transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      // Traitement des transactions
      _processTransactions(transactionsSnapshot, user.uid);
    }
  } catch (e) {
    logger.e('Erreur lors de la récupération des transactions: $e');
    _showError('Impossible de récupérer vos transactions');
  } finally {
    isLoading.value = false;
  }
}

void _processTransactions(QuerySnapshot snapshot, String userId) {
  final transactions = snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Conversion de 'date' en Timestamp et puis en DateTime
    final Timestamp timestamp = data['date'] as Timestamp;
    final DateTime dateTime = timestamp.toDate();

    return {
      'id': doc.id,
      'senderId': data['senderId'],
      'montant': data['montant'],
      'date': dateTime,  // Utilisation de DateTime
      // Ajoutez d'autres champs selon besoin
    };
  }).toList();

  // Vous pouvez ensuite manipuler la liste des transactions
  logger.d('Transactions récupérées : $transactions');
    transactions.assignAll(transactions);  // Mise à jour réactive
  _calculateTotals(transactions);
}


  void _calculateTotals(List<Map<String, dynamic>> transactionsList) {
    totalSent.value = transactionsList
        .where((t) => t['isSender'] == true)
        .fold(0.0, (sum, t) => sum + (t['montant'] ?? 0.0));

    totalReceived.value = transactionsList
        .where((t) => t['isSender'] == false)
        .fold(0.0, (sum, t) => sum + (t['montant'] ?? 0.0));
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      logger.e('Error signing out: $e');
      _showError('Échec de la déconnexion');
    }
  }

  Future<void> refreshData() async {
    await _initializeData();
  }

  void _showError(String message) {
    Get.snackbar(
      'Erreur',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
    );
  }

  // Getters
  int get transactionCount => transactions.length;
}