// register_widgets.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

Widget buildTextField(
  TextEditingController controller, 
  String label, 
  IconData icon, 
  {TextInputType keyboardType = TextInputType.text}
) {
  return FadeInDown(
    delay: const Duration(milliseconds: 400),
    duration: const Duration(milliseconds: 1500),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.blue, // Utilisez la couleur de votre thème
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer $label';
        }
        return null;
      },
    ),
  );
}

Widget buildPasswordField(
  TextEditingController controller, 
  bool isPasswordVisible, 
  Function togglePasswordVisibility
) {
  return FadeInDown(
    delay: const Duration(milliseconds: 600),
    duration: const Duration(milliseconds: 1500),
    child: TextFormField(
      controller: controller,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () => togglePasswordVisibility(),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.blue, // Utilisez la couleur de votre thème
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre mot de passe';
        }
        return null;
      },
    ),
  );
}
