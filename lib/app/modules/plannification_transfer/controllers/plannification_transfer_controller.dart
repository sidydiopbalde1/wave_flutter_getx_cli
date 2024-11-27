import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlannificationTransferController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController recipientController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  
  // Nouvelle observable pour la fréquence
  final RxString selectedFrequency = 'Ponctuel'.obs;

  final Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  final RxBool isProcessing = false.obs;
  final RxList scheduledTransactions = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadScheduledTransactions();
  }

  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        selectedDateTime.value = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    }
  }

  Future<void> loadScheduledTransactions() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      _firestore
          .collection('plannifications')  // Modification de la collection
          .where('senderId', isEqualTo: userId)
          .where('status', isEqualTo: 'scheduled')
          .snapshots()
          .listen((snapshot) {
        scheduledTransactions.value = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
      });
    } catch (e) {
      print('Erreur lors du chargement des transactions planifiées: $e');
    }
  }

  Future<void> scheduleTransaction() async {
    if (!validateInput()) return;

    try {
      isProcessing.value = true;

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Erreur', 'Vous devez être connecté');
        return;
      }

      // Vérifier l'existence du destinataire
      final recipientDoc = await _firestore
          .collection('users')
          .where('telephone', isEqualTo: recipientController.text)
          .get();

      if (recipientDoc.docs.isEmpty) {
        Get.snackbar('Erreur', 'Destinataire non trouvé');
        return;
      }

      final recipientData = recipientDoc.docs.first.data();
      final amount = double.parse(amountController.text);

      // Créer la transaction planifiée
      final docRef = _firestore.collection('plannifications').doc();
      await docRef.set({
        'date': DateTime.now(),
        'id': docRef.id,
        'senderId': userId,
        'receiverId': recipientDoc.docs.first.id,
        'telephone': recipientController.text,
        'recipientName': recipientData['nom'] ?? 'Inconnu',
        'montant': amount,
        'status': 'scheduled',
        'frequency': selectedFrequency.value,
        'nextDate': selectedDateTime.value,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Succès',
        'Transaction planifiée avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Réinitialiser les champs
      clearFields();
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la planification: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  bool validateInput() {
    if (recipientController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez saisir le numéro du destinataire');
      return false;
    }

    if (amountController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez saisir le montant');
      return false;
    }

    if (selectedDateTime.value == null) {
      Get.snackbar('Erreur', 'Veuillez sélectionner la date et l\'heure');
      return false;
    }

    try {
      double.parse(amountController.text);
    } catch (e) {
      Get.snackbar('Erreur', 'Montant invalide');
      return false;
    }

    return true;
  }

  Future<void> cancelScheduledTransaction(String transactionId) async {
    try {
      await _firestore.collection('plannifications').doc(transactionId).delete();
      Get.snackbar(
        'Succès',
        'Transaction planifiée annulée',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'annulation: $e');
    }
  }

  void clearFields() {
    recipientController.clear();
    amountController.clear();
    selectedDateTime.value = null;
    selectedFrequency.value = 'Ponctuel';
  }

  @override
  void onClose() {
    recipientController.dispose();
    amountController.dispose();
    super.onClose();
  }
}