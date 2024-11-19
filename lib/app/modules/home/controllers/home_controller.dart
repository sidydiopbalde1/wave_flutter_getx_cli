import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final RxBool isBalanceVisible = true.obs;
  final RxDouble balance = 0.0.obs;
  final RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;

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
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        balance.value = doc.data()?['balance'] ?? 0.0;
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de récupérer le solde');
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final querySnapshot = await _firestore
            .collection('transactions')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .get();

        transactions.value = querySnapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList();
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de récupérer les transactions');
    }
  }
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(Routes.LOGIN); // Redirection vers la page de login après déconnexion
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la déconnexion: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}