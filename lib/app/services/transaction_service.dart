import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/transactionModel.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      // Ajoute la transaction dans la collection "transactions"
      await _firestore.collection('transactions').add(transaction.toFirestore());
      print("Transaction créée avec succès !");
    } catch (e) {
      print("Erreur lors de la création de la transaction : $e");
    }
  }
}
