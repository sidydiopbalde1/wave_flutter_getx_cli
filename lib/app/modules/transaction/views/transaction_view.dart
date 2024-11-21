import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

import '../controllers/transaction_controller.dart'; // Adjust import path as needed

class TransactionView extends StatelessWidget {
  final TransactionController controller = Get.put(TransactionController());
  final RxBool _isMultiSelect = false.obs;
  final RxList<Contact> _selectedContacts = <Contact>[].obs;
  final TextEditingController _amountController = TextEditingController();

  TransactionView({super.key});

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
                  _selectedContacts.clear(); // Reset selected contacts
                },
                activeColor: Colors.green,
              )),
          const Text('Multi-Transfert')
        ],
      ),
      body: Column(
        children: [
          // Amount Input
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

          // Contacts List
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
                        title: Text(contact.displayName),
                        subtitle: contact.phones.isNotEmpty
                            ? Text(contact.phones.first.number)
                            : null,
                        onTap: () => _performTransfer(contact),
                      ));
                },
              );
            }),
          ),

          // Transfer Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
              onPressed: _isMultiSelect.value 
                ? _performMultiTransfer 
                : null,
              child: Text(
                _isMultiSelect.value 
                  ? 'Transfert Groupé' 
                  : 'Sélectionnez des contacts pour un transfert groupé',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performTransfer(Contact contact) {
    if (!_isMultiSelect.value) {
      // Validate amount
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        Get.snackbar(
          'Erreur', 
          'Veuillez entrer un montant valide',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Perform single transfer
      controller.transferToContact(contact, amount);
    }
  }

  void _performMultiTransfer() {
    // Validate amount
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Erreur', 
        'Veuillez entrer un montant valide',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate contacts selection
    if (_selectedContacts.isEmpty) {
      Get.snackbar(
        'Erreur', 
        'Veuillez sélectionner au moins un contact',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Perform multi transfer
    controller.transferToMultipleContacts(_selectedContacts, amount);
  }
}