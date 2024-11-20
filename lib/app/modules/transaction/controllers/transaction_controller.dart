import 'package:get/get.dart';
import '../../../data/models/transactionModel.dart';
import '../../../services/firebase_store_service.dart';

class TransactionController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // Liste observable pour stocker les transactions
  var transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    listenToTransactions(); // Écouter les transactions en temps réel dès l'initialisation
  }

  // Méthode pour créer une transaction
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await _firestoreService.addDocument('transactions', transaction.toFirestore());
      Get.snackbar('Succès', 'Transaction créée avec succès !');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer la transaction : $e');
    }
  }

  // Méthode pour récupérer les transactions (une fois)
  Future<void> fetchTransactions() async {
    try {
      final documents = await _firestoreService.getDocuments('transactions');
      transactions.value = documents.map((data) {
        return TransactionModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de récupérer les transactions : $e');
    }
  }

  // Méthode pour écouter les transactions en temps réel
  void listenToTransactions() {
    _firestoreService.listenToDocuments('transactions').listen((documents) {
      transactions.value = documents.map((data) {
        return TransactionModel.fromFirestore(data);
      }).toList();
    });
  }

  // Méthode pour mettre à jour une transaction
  Future<void> updateTransaction(String id, Map<String, dynamic> updatedData) async {
    try {
      await _firestoreService.updateDocument('transactions', id, updatedData);
      Get.snackbar('Succès', 'Transaction mise à jour avec succès !');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour la transaction : $e');
    }
  }

  // Méthode pour supprimer une transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await _firestoreService.deleteDocument('transactions', id);
      Get.snackbar('Succès', 'Transaction supprimée avec succès !');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la transaction : $e');
    }
  }
}
