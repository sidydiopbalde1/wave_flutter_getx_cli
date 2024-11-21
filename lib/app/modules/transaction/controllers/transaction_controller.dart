import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import '../../../data/models/transactionModel.dart';
import '../../../services/firebase_store_service.dart';

class TransactionController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // Transactions
  var transactions = <TransactionModel>[].obs;

  // Contacts
  var contacts = <Contact>[].obs;

  // Indicateur de chargement
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
    listenToTransactions();
    fetchContacts();
  }

  // Charger les transactions
  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      final documents = await _firestoreService.getDocuments('transactions');
      transactions.value = documents.map((data) {
        return TransactionModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de récupérer les transactions : $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Écouter les transactions en temps réel
  void listenToTransactions() {
    _firestoreService.listenToDocuments('transactions').listen((documents) {
      transactions.value = documents.map((data) {
        return TransactionModel.fromFirestore(data);
      }).toList();
    });
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
      
      String senderId = 'currentUserId'; 
      String receiverId = contact.phones.isNotEmpty ? contact.phones.first.number : 'Inconnu';
      
      // Calculer les frais (par exemple 5% du montant)
      double frais = amount * 0.05;

      // Créer l'objet TransactionModel
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'transfer',
        montant: amount,
        date: DateTime.now(),
        recipientName: contact.displayName,
        senderId: senderId,
        receiverId: receiverId,
        status: 'pending',
        frais: frais,
      );

      // Ajouter la transaction à Firestore
      await _firestoreService.addDocument('transactions', transaction.toFirestore());

      // Afficher un message de succès
      Get.snackbar('Succès', 'Transfert effectué à ${contact.displayName}');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'effectuer le transfert : $e');
    }
  }

  // Transférer à plusieurs contacts
  Future<void> transferToMultipleContacts(List<Contact> selectedContacts, double amount) async {
    try {
      for (var contact in selectedContacts) {
        await transferToContact(contact, amount);
      }
      Get.snackbar('Succès', 'Transfert groupé effectué à ${selectedContacts.length} contacts');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'effectuer le transfert groupé : $e');
    }
  }
}