import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionService extends GetxController {
  final TextEditingController receiverController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendTransaction({required VoidCallback onSuccess}) async {
    String receiverInput = receiverController.text;
    String amount = amountController.text;

    if (receiverInput.isEmpty || amount.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Récupérer l'ID de l'utilisateur connecté
      String currentUserID = _auth.currentUser!.uid;

      // Séparer les numéros (par virgule ou espace) et supprimer les espaces inutiles
      List<String> receivers =
          receiverInput.split(',').map((e) => e.trim()).toList();

      // Vérifier si le solde total est suffisant
      double transactionAmount = double.parse(amount);
      double totalAmount = transactionAmount * receivers.length;
      double senderBalance =
          (await _firestore.collection('users').doc(currentUserID).get())
                  .data()!['solde']
                  ?.toDouble() ??
              0.0;

      if (senderBalance < totalAmount) {
        Get.snackbar(
          'Erreur',
          'Votre solde est insuffisant pour effectuer ces transactions',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Traiter chaque destinataire
      for (String receiver in receivers) {
        // Vérifier que le destinataire existe dans la base de données
        QuerySnapshot<Map<String, dynamic>> usersSnapshot = await _firestore
            .collection('users')
            .where('telephone', isEqualTo: receiver)
            .get();

        if (usersSnapshot.docs.isEmpty) {
          Get.snackbar(
            'Erreur',
            'Le destinataire $receiver n\'existe pas dans la base de données',
            snackPosition: SnackPosition.BOTTOM,
          );
          continue; // Passer au prochain destinataire
        }

        // Récupérer le document du destinataire
        DocumentSnapshot<Map<String, dynamic>> receiverSnapshot =
            usersSnapshot.docs.first;
        String receiverID = receiverSnapshot.id;
        double receiverBalance =
            receiverSnapshot.data()!['solde']?.toDouble() ?? 0.0;

        // Mettre à jour les soldes
        await _firestore
            .collection('users')
            .doc(currentUserID)
            .update({'solde': senderBalance - transactionAmount});
        senderBalance -= transactionAmount; // Déduire immédiatement

        await _firestore
            .collection('users')
            .doc(receiverID)
            .update({'solde': receiverBalance + transactionAmount});

        // Enregistrer la transaction dans la base de données
        await _firestore.collection('transactions').add({
          'sender': currentUserID,
          'receiver': receiverID,
          'amount': transactionAmount,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      Get.snackbar(
        'Succès',
        'Transactions envoyées avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Réinitialiser les champs de saisie
      receiverController.clear();
      amountController.clear();

      onSuccess();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur s\'est produite lors de l\'envoi des transactions',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Erreur lors de l\'envoi des transactions: $e');
    }
  }

  Future<double> getUserBalance() async {
    try {
      String currentUserID = _auth.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await _firestore.collection('users').doc(currentUserID).get();

      return userSnapshot.data()?['solde']?.toDouble() ?? 0.0;
    } catch (e) {
      print('Erreur lors de la récupération du solde: $e');
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> getUserTransactions() async {
    try {
      String currentUserID = _auth.currentUser!.uid;
  
      // Récupérer les transactions où l'utilisateur est soit l'expéditeur soit le destinataire
      QuerySnapshot senderSnapshot = await _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: currentUserID)
          .get();
      print(senderSnapshot);

      QuerySnapshot receiverSnapshot = await _firestore
          .collection('transactions')
          .where('receiverId', isEqualTo: currentUserID)
          .get();

      // Combiner les données
      List<Map<String, dynamic>> transactions = [
        ...senderSnapshot.docs.map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id, // Ajouter l'ID du document
              // 'timestamp': (doc['timestamp'] as Timestamp).toDate(),
            }),
        ...receiverSnapshot.docs.map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id, // Ajouter l'ID du document
              // 'timestamp': (doc['timestamp'] as Timestamp).toDate(),
            }),
      ];

      // Trier par timestamp (les plus récents d'abord)
      // transactions.sort((a, b) =>
      //     (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

      return transactions;
    } catch (e) {
      print('Erreur lors de la récupération des transactions: $e');
      return [];
    }
  }

  @override
  void onClose() {
    receiverController.dispose();
    amountController.dispose();
    super.onClose();
  }
}