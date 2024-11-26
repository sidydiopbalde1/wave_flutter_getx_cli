import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../distributor/controllers/distributor_controller.dart';

class TransactionFormView extends StatelessWidget {
  final String serviceType;
  final String phoneNumber;
  final DistributorController controller = Get.put(DistributorController());

  TransactionFormView({
    Key? key,
    required this.serviceType,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceType),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF2F5CA8),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2F5CA8), Color(0xFFF5F6FA)],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildTransactionForm(),
              const SizedBox(height: 16),
              // Ajout du message de statut
              Obx(() => _buildStatusMessage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type d\'opération: $serviceType',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F5CA8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Numéro: $phoneNumber',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    if (controller.message.value.isEmpty) return const SizedBox();

    final bool isError = controller.message.value.toLowerCase().contains('erreur') ||
                        controller.message.value.toLowerCase().contains('insuffisant') ||
                        controller.message.value.toLowerCase().contains('exception');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? Colors.red : Colors.green,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.message.value,
              style: TextStyle(
                color: isError ? Colors.red : Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Montant',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.montantController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Saisir le montant',
                suffixText: 'XOF',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2F5CA8),
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir un montant';
                }
                if (int.tryParse(value) == null) {
                  return 'Veuillez saisir un montant valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => _handleTransaction(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F5CA8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Valider le $serviceType',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTransaction() async {
    if (controller.formKey.currentState!.validate()) {
      final int montant = int.parse(controller.montantController.text);
      
      try {
        await controller.processTransaction(
          serviceType: serviceType,
          phoneNumber: phoneNumber,
          montant: montant,
        );
        
        // Attendre un peu pour que l'utilisateur puisse voir le message de succès
        await Future.delayed(const Duration(seconds: 2));
        
        Get.back();
        Get.back(); // Retour à la page principale après succès
      } catch (e) {
        // Le message d'erreur est déjà géré dans le contrôleur
        print(e);
      }
    }
  }
}