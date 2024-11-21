import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

import '../controllers/transaction_controller.dart';

class TransactionView extends StatelessWidget {
  final TransactionController controller = Get.put(TransactionController());
  final RxBool _isMultiSelect = false.obs;
  final RxList<Contact> _selectedContacts = <Contact>[].obs;
  final TextEditingController _amountController = TextEditingController();

  TransactionView({super.key});

  void _performMultiTransfer() {
    if (_amountController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez entrer un montant');
      return;
    }

    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      Get.snackbar('Erreur', 'Montant invalide');
      return;
    }

    controller.transferToMultipleContacts(_selectedContacts, amount);
  }

  void transferToMultipleContacts(Contact contact) {
    if (!_isMultiSelect.value) {
      if (_amountController.text.isEmpty) {
        Get.snackbar('Erreur', 'Veuillez entrer un montant');
        return;
      }

      double amount = double.tryParse(_amountController.text) ?? 0.0;
      if (amount <= 0) {
        Get.snackbar('Erreur', 'Montant invalide');
        return;
      }

      controller.transferToContact(contact, amount);
    } else {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert de Fonds'),
        actions: [
          Obx(() => Switch(
                value: _isMultiSelect.value,
                onChanged: (bool value) {
                  _isMultiSelect.value = value;
                  _selectedContacts.clear();
                },
                activeColor: Colors.green,
              )),
          const Text('Multi-Transfert')
        ],
      ),
      body: Column(
        children: [
          // Saisie du montant
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

              if (controller.contacts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.contact_page, size: 100, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text(
                        'Aucun contact trouvé',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      ElevatedButton(
                        onPressed: () => controller.fetchContacts(),
                        child: const Text('Recharger les contacts'),
                      )
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.contacts.length,
                itemBuilder: (context, index) {
                  final contact = controller.contacts[index];
                  return ListTile(
                    leading: _isMultiSelect.value
                        ? Checkbox(
                            value: _selectedContacts.contains(contact),
                            onChanged: (bool? selected) {
                              if (selected == true) {
                                _selectedContacts.add(contact);
                              } else {
                                _selectedContacts.remove(contact);
                              }
                            },
                          )
                        : const Icon(Icons.person),
                    title: Text(contact.displayName.isNotEmpty 
                        ? contact.displayName 
                        : 'Contact sans nom'),
                    subtitle: contact.phones.isNotEmpty
                        ? Text(contact.phones.first.number)
                        : const Text('Pas de numéro'),
                    onTap: () => transferToMultipleContacts(contact),
                  );
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
                backgroundColor: Colors.green,
              ),
              onPressed: _isMultiSelect.value && _selectedContacts.isNotEmpty
                  ? _performMultiTransfer 
                  : null,
              child: Text(
                _isMultiSelect.value 
                  ? 'Transfert Groupé (${_selectedContacts.length} contacts)' 
                  : 'Sélectionnez des contacts pour un transfert groupé',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}