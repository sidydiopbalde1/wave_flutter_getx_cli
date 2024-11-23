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
    final user = _auth.currentUser;
    if (user != null) {
      logger.i('Fetching balance for user: ${user.uid}');

      // Écoute en temps réel des changements dans le document utilisateur
      _firestore.collection('users').doc(user.uid).snapshots().listen((docSnapshot) {
        if (docSnapshot.exists) {
          balance.value = (docSnapshot.data()?['solde'] ?? 0).toDouble();
        } else {
          logger.w('Profil utilisateur non trouvé');
        }
      });
    }
  } catch (e) {
    logger.e('Erreur lors de la récupération du solde en temps réel: $e');
    _showError('Impossible de récupérer le solde');
  }
}

Future<void> fetchUserTransactions() async {
  try {
    final user = _auth.currentUser;

    if (user != null) {
      logger.i('Fetching transactions for user: ${user.uid}');

      // Écoute en temps réel des transactions
      _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .snapshots()
          .listen((querySnapshot) {
        _processTransactions(querySnapshot, user.uid);
      });
    }
  } catch (e) {
    logger.e('Erreur lors de la récupération des transactions en temps réel: $e');
    _showError('Impossible de récupérer vos transactions');
  }
}

void _processTransactions(QuerySnapshot snapshot, String userId) {
  final fetchedTransactions = snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Conversion de 'date' en DateTime
    final Timestamp timestamp = data['date'] as Timestamp;
    final DateTime dateTime = timestamp.toDate();

    return {
      'id': doc.id,
      'senderId': data['senderId'],
      'receiverId': data['receiverId'], // Assurez-vous que ce champ existe dans vos données
      'montant': data['montant'],
      'date': dateTime,
    };
  }).toList();

  // Mise à jour réactive
  transactions.assignAll(fetchedTransactions);
  logger.d('Transactions mises à jour : $transactions');

  _calculateTotals(fetchedTransactions, userId);
}




  void _calculateTotals(List<Map<String, dynamic>> transactionsList, String userId) {
    totalSent.value = transactionsList
        .where((t) => t['senderId'] == userId)
        .fold(0.0, (sum, t) => sum + (t['montant'] ?? 0.0));

    totalReceived.value = transactionsList
        .where((t) => t['receiverId'] == userId)
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