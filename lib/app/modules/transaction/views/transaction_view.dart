import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart'; // Ajustez le chemin si nécessaire

class TransactionView extends StatelessWidget {
  final TransactionController controller = Get.put(TransactionController());
  final RxList<Contact> _selectedContacts = <Contact>[].obs;
  final TextEditingController _amountController = TextEditingController();

  TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert de Fonds'),
      ),
      body: Column(
        children: [
          // Zone d'affichage des messages
          Obx(() {
            if (controller.message.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  controller.message.value,
                  style: TextStyle(
                    color: controller.message.value.contains('Erreur') ? Colors.red : Colors.green,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Champ de saisie pour le montant
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant à transférer',
                prefixIcon: const Icon(Icons.monetization_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Liste des contacts
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                itemCount: controller.contacts.length,
                itemBuilder: (context, index) {
                  final contact = controller.contacts[index];
                  return Obx(() => ListTile(
                        leading: Checkbox(
                          value: _selectedContacts.contains(contact),
                          onChanged: (bool? selected) {
                            if (selected == true) {
                              _selectedContacts.add(contact);
                              print('Contact ajouté: ${contact.displayName} - ${contact.phones.isNotEmpty ? contact.phones.first.number : "Pas de numéro"}');
                            } else {
                              _selectedContacts.remove(contact);
                              print('Contact retiré: ${contact.displayName} - ${contact.phones.isNotEmpty ? contact.phones.first.number : "Pas de numéro"}');
                            }
                          },
                        ),
                        title: Text(contact.displayName),
                        subtitle: contact.phones.isNotEmpty
                            ? Text(contact.phones.first.number)
                            : const Text(
                                'Pas de numéro',
                                style: TextStyle(color: Colors.red),
                              ),
                      ));
                },
              );
            }),
          ),

          // Bouton de transfert
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue[700],
              ),
              onPressed: _performMultiTransfer,
              child: const Text(
                'Transfert Groupé',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performMultiTransfer() {
    // Valider le montant
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      controller.updateMessage('Erreur : Veuillez entrer un montant valide');
      return;
    }

    // Valider la sélection des contacts
    if (_selectedContacts.isEmpty) {
      controller.updateMessage('Erreur : Veuillez sélectionner au moins un contact');
      return;
    }

    // Logger les contacts sélectionnés
    print('Nombre de contacts sélectionnés: ${_selectedContacts.length}');
    for (var contact in _selectedContacts) {
      print('Contact sélectionné:');
      print('  - Nom: ${contact.displayName}');
      print('  - Téléphone: ${contact.phones.isNotEmpty ? contact.phones.first.number : "Pas de numéro"}');
      if (contact.phones.isEmpty) {
        print('  ⚠️ ATTENTION: Ce contact n\'a pas de numéro de téléphone');
      }
    }
    print('Montant à transférer par contact: $amount');

    // Utiliser la méthode transferToMultipleContacts du controller
    controller.transferToMultipleContacts(_selectedContacts.toList(), amount);

    // Réinitialiser les sélections après le transfert
    _selectedContacts.clear();
    _amountController.clear();
      // Rediriger vers la page d'accueil après un délai
  Future.delayed(const Duration(seconds: 1), () {
    Get.offNamed('/home'); // Assurez-vous que la route '/home' est définie dans vos routes
  });
  }
}
