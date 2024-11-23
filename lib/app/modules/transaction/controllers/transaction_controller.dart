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
  
  

  // Transférer à plusieurs contacts
Future<void> transferToMultipleContacts(List<Contact> selectedContacts, double amount) async {
  try {
    // Vérifier si l'utilisateur est connecté
    final senderId = authController.user.value?.uid;
    print('Sender ID (Utilisateur connecté) : $senderId');
    if (senderId == null) {
      Get.snackbar(
        'Erreur',
        'Utilisateur non connecté. Veuillez vous authentifier.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Calculer les frais et le montant total nécessaire
    final double fraisParTransfert = amount * 0.05;
    final double montantTotalNecessaire = (amount + fraisParTransfert) * selectedContacts.length;
    print('Frais par transfert : $fraisParTransfert');
    print('Montant total nécessaire : $montantTotalNecessaire');

    // Vérifier le solde de l'utilisateur
    final userDoc = await _firestoreService.getUserDocument(senderId);
    print('Données utilisateur : $userDoc');
    final currentBalance = userDoc['solde'] ?? 0.0;
    print('Solde actuel : $currentBalance');

    if (montantTotalNecessaire > currentBalance) {
      print('Erreur : Solde insuffisant');
      Get.snackbar(
        'Erreur',
        'Solde insuffisant pour effectuer tous les transferts. Solde nécessaire: ${montantTotalNecessaire.toStringAsFixed(2)}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Effectuer les transferts pour chaque contact
    for (var contact in selectedContacts) {
      print('Traitement du contact : ${contact.displayName}');
      final receiverId = contact.phones.isNotEmpty ? contact.phones.first.number : null;
      print('Numéro de téléphone du contact : $receiverId');

      if (receiverId == null) {
        print('Erreur : Numéro de téléphone non disponible pour ${contact.displayName}');
        Get.snackbar(
          'Erreur',
          'Le numéro de téléphone de ${contact.displayName} est invalide.',
          snackPosition: SnackPosition.BOTTOM,
        );
        continue;
      }

      final userExists = await _userService.userExistsByPhone(receiverId);
      print('Existence de l\'utilisateur pour $receiverId : $userExists');
      if (!userExists) {
        print('Erreur : Utilisateur non trouvé pour $receiverId');
        Get.snackbar(
          'Erreur',
          'Le numéro de téléphone de ${contact.displayName} n\'est pas associé à un utilisateur.',
          snackPosition: SnackPosition.BOTTOM,
        );
        continue;
      }

      final frais = amount * 0.05;
      print('Frais calculés pour ${contact.displayName} : $frais');

      if (currentBalance < (amount + frais)) {
        print('Erreur : Solde insuffisant pour ${contact.displayName}');
        Get.snackbar(
          'Erreur',
          'Solde insuffisant pour effectuer le transfert à ${contact.displayName}.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final double newBalance = currentBalance - (amount + frais);
      print('Nouveau solde après transfert à ${contact.displayName} : $newBalance');

      // Mettre à jour le solde de l'utilisateur dans Firestore
      await _firestoreService.updateUserBalance(senderId, newBalance);

      // Créer l'objet TransactionModel
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

      print('Transaction créée pour ${contact.displayName} : ${transaction.toFirestore()}');

      // Ajouter la transaction à Firestore
      await _firestoreService.addDocument('transactions', transaction.toFirestore());

      // Afficher un message de succès
      print('Succès : Transfert effectué à ${contact.displayName}');
      Get.snackbar(
        'Succès',
        'Transfert effectué à ${contact.displayName}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    print('Tous les transferts ont été effectués avec succès.');
    Get.snackbar(
      'Succès',
      'Transfert groupé effectué à ${selectedContacts.length} contacts',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } catch (e) {
    print('Erreur lors du transfert : $e');
    Get.snackbar(
      'Erreur',
      'Impossible d\'effectuer le transfert : $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}


}
