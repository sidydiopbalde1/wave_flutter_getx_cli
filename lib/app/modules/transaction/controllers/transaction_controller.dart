import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/transactionModel.dart';
import '../../../services/firebase_store_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../services/user_service.dart';

class TransactionController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController authController = Get.find();
  final UserService _userService = UserService(); // Service pour obtenir les utilisateurs
 // Observable pour les messages
  final message = ''.obs;
  // Transactions
  var transactions = <TransactionModel>[].obs;

  // Contacts
  var contacts = <Contact>[].obs;

  // Indicateur de chargement
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserTransactions(); // Charger uniquement les transactions de l'utilisateur connecté
    listenToUserTransactions(); // Écouter les transactions en temps réel pour l'utilisateur connecté
    fetchContacts();
  }

 // Méthode pour mettre à jour le message
  void updateMessage(String newMessage) {
    message.value = newMessage;
  }
  // Charger les transactions de l'utilisateur connecté
  Future<void> fetchUserTransactions() async {
    try {
      isLoading.value = true;

      // Vérifier si l'utilisateur est connecté
      final senderId = authController.user.value?.uid;
      if (senderId == null) {
        Get.snackbar(
          'Erreur',
          'Utilisateur non connecté. Veuillez vous authentifier.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Récupérer les transactions de l'utilisateur connecté
      final documents = await _firestoreService.getUserTransactions('transactions', senderId);

      // Convertir les documents en objets TransactionModel
      transactions.value = documents.map((data) {
        return TransactionModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de récupérer les transactions : $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Écouter les transactions en temps réel pour l'utilisateur connecté
  void listenToUserTransactions() {
    final senderId = authController.user.value?.uid;

    if (senderId != null) {
      _firestoreService
          .listenToDocuments('transactions')
          .listen((documents) {
        transactions.value = documents
            .where((data) => data['senderId'] == senderId) // Filtrer par l'ID de l'utilisateur connecté
            .map((data) {
          return TransactionModel.fromFirestore(data);
        }).toList();
      });
    } else {
      Get.snackbar(
        'Erreur',
        'Utilisateur non connecté. Veuillez vous authentifier.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Charger les contacts
  Future<void> fetchContacts() async {
    try {
      isLoading.value = true;
      if (await FlutterContacts.requestPermission()) {
        final phoneContacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );

        print('Nombre de contacts récupérés : ${phoneContacts.length}');

        contacts.value = phoneContacts;
      } else {
        print('Permission de lecture des contacts refusée');
        Get.snackbar('Erreur', 'Permission de lire les contacts refusée');
      }
    } catch (e) {
      print('Erreur lors du chargement des contacts : $e');
      Get.snackbar('Erreur', 'Impossible de charger les contacts : $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  

  // Transférer à plusieurs contacts
Future<void> transferToMultipleContacts(List<Contact> selectedContacts, double amount) async {
  try {
    // Vérifier si l'utilisateur est connecté
    final senderId = authController.user.value?.uid;
    if (senderId == null) {
      updateMessage('Utilisateur non connecté. Veuillez vous authentifier.');
      return;
    }

    // Calculer les frais et le montant total
    final double fraisParTransfert = amount * 0.05;
    final double montantTotalNecessaire = (amount + fraisParTransfert) * selectedContacts.length;

    // Vérifier le solde actuel
    final userDoc = await _firestoreService.getUserDocument(senderId);
    final currentBalance = userDoc['solde'] ?? 0.0;

    if (montantTotalNecessaire > currentBalance) {
      updateMessage('Solde insuffisant pour effectuer tous les transferts.');
      return;
    }

    // Effectuer les transferts
    for (var contact in selectedContacts) {
      final receiverId = contact.phones.isNotEmpty ? contact.phones.first.number : null;

      if (receiverId == null) {
        updateMessage('Le numéro de téléphone de ${contact.displayName} est invalide.');
        continue;
      }

      final userExists = await _userService.userExistsByPhone(receiverId);
      if (!userExists) {
        updateMessage('Le numéro de téléphone de ${contact.displayName} n\'est pas associé à un utilisateur.');
        continue;
      }

      final frais = amount * 0.05;
      if (currentBalance < (amount + frais)) {
        updateMessage('Solde insuffisant pour effectuer le transfert à ${contact.displayName}.');
        return;
      }

      final double newBalance = currentBalance - (amount + frais);
      await _firestoreService.updateUserBalance(senderId, newBalance);

      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'transfert',
        montant: amount,
        date: Timestamp.now(),
        recipientName: contact.displayName,
        senderId: senderId,
        receiverId: receiverId,
        status: 'completed',
        frais: frais,
      );

      await _firestoreService.addDocument('transactions', transaction.toFirestore());
      updateMessage('Transfert effectué à ${contact.displayName}.');
    }

    updateMessage('Transfert groupé effectué avec succès.');
  } catch (e) {
    updateMessage('Erreur : ${e.toString()}');
  }
}



}
