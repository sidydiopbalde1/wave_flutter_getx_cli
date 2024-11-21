import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class DistributorController extends GetxController {
  RxDouble solde = 5000.0.obs; // Solde de l'utilisateur
  RxBool afficherSolde = true.obs; // Permet d'afficher/masquer le solde
  RxList<Map<String, String>> transactions = <Map<String, String>>[].obs; // Liste des transactions
  final RxBool isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final logger = Logger();

  @override
  void onInit() {
    super.onInit();
    fetchBalance();
    fetchTransactions();  // Récupérer les transactions lors de l'initialisation
  }

  // Toggle affichage du solde
  void toggleAfficherSolde() {
    afficherSolde.value = !afficherSolde.value;
  }

  // Ajouter une nouvelle transaction
  void ajouterTransaction(String type, String montant) {
    transactions.add({
      'type': type,
      'montant': montant,
      'date': DateTime.now().toIso8601String(),
    });
  }

  // Récupérer le solde de l'utilisateur depuis Firestore
  Future<void> fetchBalance() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          solde.value = (doc.data()?['solde'] ?? 0).toDouble();
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

  // Récupérer les transactions depuis Firestore
Future<void> fetchTransactions() async {
  try {
    isLoading.value = true;
    final user = _auth.currentUser;
    if (user != null) {
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();
      transactions.value = querySnapshot.docs.map((doc) {
        return {
          'type': doc['type'] as String,
          'montant': (doc['montant'] ?? '').toString(),
          'date': (doc['date'] as Timestamp).toDate().toIso8601String(),
        };
      }).toList();
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

}
