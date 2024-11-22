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

  // Transférer à un contact
  Future<void> transferToContact(Contact contact, double amount) async {
    try {
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

      // Obtenir l'ID du destinataire (numéro de téléphone du contact)
      final receiverId = contact.phones.isNotEmpty ? contact.phones.first.number : 'Inconnu';

      // Calculer les frais (par exemple 5% du montant)
      final double frais = amount * 0.05;

      // Vérifier si le destinataire existe dans la collection 'users'
      final userExists = await _userService.userExistsByPhone(receiverId);
      if (!userExists) {
        Get.snackbar('Erreur', 'Le numéro de téléphone n\'est pas associé à un utilisateur.');
        return;
      }

      // Récupérer le solde actuel de l'utilisateur
      final userDoc = await _firestoreService.getUserDocument(senderId);
      final double currentBalance = userDoc['balance'] ?? 0.0;

      // Vérifier si l'utilisateur a assez d'argent pour effectuer le transfert
      if (currentBalance < (amount + frais)) {
        Get.snackbar(
          'Erreur',
          'Solde insuffisant pour effectuer le transfert.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Soustraire le montant du solde de l'utilisateur
      final newBalance = currentBalance - (amount + frais);

      // Mettre à jour le solde de l'utilisateur dans Firestore
      await _firestoreService.updateUserBalance(senderId, newBalance);

      // Créer l'objet TransactionModel
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'transfer',
        montant: amount,
        date: Timestamp.now(),
        recipientName: contact.displayName,
        senderId: senderId,
        receiverId: receiverId,
        status: 'completed',
        frais: frais,
      );

      // Ajouter la transaction à Firestore
      await _firestoreService.addDocument('transactions', transaction.toFirestore());

      // Afficher un message de succès
      Get.snackbar(
        'Succès',
        'Transfert effectué à ${contact.displayName}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'effectuer le transfert : $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Transférer à plusieurs contacts
Future<void> transferToMultipleContacts(List<Contact> selectedContacts, double amount) async {
  try {
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

    // Calculer le montant total nécessaire (montant * nombre de contacts + frais totaux)
    final double fraisParTransfert = amount * 0.05;
    final double montantTotalNecessaire = (amount + fraisParTransfert) * selectedContacts.length;

    // Vérifier le solde de l'utilisateur
    final userDoc = await _firestoreService.getUserDocument(senderId);
    final double currentBalance = userDoc['solde'] ?? 0.0;

    if (montantTotalNecessaire > currentBalance) {
      Get.snackbar(
        'Erreur', 
        'Solde insuffisant pour effectuer tous les transferts. Solde nécessaire: ${montantTotalNecessaire.toStringAsFixed(2)}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Effectuer les transferts
    for (var contact in selectedContacts) {
      await transferToContact(contact, amount);
    }

    Get.snackbar(
      'Succès', 
      'Transfert groupé effectué à ${selectedContacts.length} contacts',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } catch (e) {
    Get.snackbar(
      'Erreur', 
      'Impossible d\'effectuer le transfert groupé : $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
}
