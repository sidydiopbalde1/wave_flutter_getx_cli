import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';
import 'package:logger/logger.dart';

class HomeController extends GetxController {
  // Variables réactives
  final RxBool isBalanceVisible = true.obs;
  final RxDouble balance = 0.0.obs;
  final RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
    final logger = Logger();

  // Instances Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchBalance();
    fetchTransactions();
  }

  void toggleBalanceVisibility() {
    isBalanceVisible.toggle();
  }

  Future<void> fetchBalance() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      logger.i(user?.uid);
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          balance.value = (doc.data()?['solde'] ?? 0).toDouble();
        } else {
          Get.snackbar(
            'Erreur',
            'Profil utilisateur non trouvé',
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer le solde',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions() async {
  try {
    isLoading.value = true;
    final user = _auth.currentUser;

    if (user != null) {
      // Simplifier la requête pour les transactions envoyées
      final sentQuery = await _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: user.uid)
          .get();

      // Simplifier la requête pour les transactions reçues
      final receivedQuery = await _firestore
          .collection('transactions')
          .where('receiverId', isEqualTo: user.uid)
          .get();

      // Combiner et formater toutes les transactions
      List<Map<String, dynamic>> allTransactions = [
        ...sentQuery.docs.map((doc) => {
              'id': doc.id,
              'date': doc['date'].toDate(),
              'isSender': true,
              'montant': doc['montant'],
              'status': doc['status'] ?? 'Completed',
              'type': doc['type'] ?? 'transfert',
              'frais': doc['frais'] ?? 0.0,
            }),
        ...receivedQuery.docs.map((doc) => {
              'id': doc.id,
              'date': doc['date'].toDate(),
              'isSender': false,
              'montant': doc['montant'],
              'status': doc['status'] ?? 'completed',
              'type': doc['type'] ?? 'transfert',
              'frais': doc['frais'] ?? 0.0,
            }),
      ];

      // Trier les transactions côté client
      allTransactions.sort((a, b) => 
        (b['date'] as DateTime).compareTo(a['date'] as DateTime)
      );

      transactions.value = allTransactions;
    }
  } catch (e) {
    Get.snackbar(
      'Erreur',
      'Impossible de récupérer les transactions',
      snackPosition: SnackPosition.TOP,
    );
  } finally {
    isLoading.value = false;
  }
}

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la déconnexion: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Méthode pour rafraîchir les données
  Future<void> refreshData() async {
    await Future.wait([
      fetchBalance(),
      fetchTransactions(),
    ]);
  }

  // Méthode pour obtenir le nombre total de transactions
  int get transactionCount => transactions.length;

  // Méthode pour obtenir le montant total des transactions envoyées
  double get totalSent {
    return transactions
        .where((t) => t['isSender'] == true)
        .fold(0.0, (sum, t) => sum + (t['montant'] ?? 0.0));
  }

  // Méthode pour obtenir le montant total des transactions reçues
  double get totalReceived {
    return transactions
        .where((t) => t['isSender'] == false)
        .fold(0.0, (sum, t) => sum + (t['montant'] ?? 0.0));
  }
}