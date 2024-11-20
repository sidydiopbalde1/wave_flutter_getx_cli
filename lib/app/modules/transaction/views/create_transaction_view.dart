import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../../../data/models/transactionModel.dart';

class CreateTransactionView extends StatelessWidget {
  const CreateTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.find();

    final montantController = TextEditingController();
    final receiverIdController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 0,
        title: Text(
          'Créer une Transaction',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTransactionForm(montantController, receiverIdController, transactionController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionForm(
    TextEditingController montantController,
    TextEditingController receiverIdController,
    TransactionController transactionController
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Détails de la Transaction',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: montantController,
            labelText: 'Montant',
            icon: Icons.monetization_on_outlined,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: receiverIdController,
            labelText: 'ID du destinataire',
            icon: Icons.person_outline,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          _buildSubmitButton(montantController, receiverIdController, transactionController),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
    );
  }

  Widget _buildSubmitButton(
    TextEditingController montantController,
    TextEditingController receiverIdController,
    TransactionController transactionController
  ) {
    return ElevatedButton(
      onPressed: () {
        final montant = double.tryParse(montantController.text) ?? 0;
        final receiverId = int.tryParse(receiverIdController.text) ?? 0;

        final newTransaction = TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          montant: montant,
          status: 'pending',
          date: DateTime.now(),
          frais: montant * 0.05,
          type: 'transfert',
          senderId: 1, // ID fictif, à remplacer par l'ID réel
          receiverId: receiverId,
        );

        transactionController.createTransaction(newTransaction);
        Get.back(); // Retourner à la liste après la création
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      child: Text(
        'Créer la Transaction',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}