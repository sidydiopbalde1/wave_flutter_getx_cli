import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../utils/constants/colors.dart';  

Widget customTextField({
  required TextEditingController controller,
  required String labelText,
  required String hintText,
  required IconData prefixIcon,
  bool obscureText = false,
  IconData? suffixIcon,
  void Function()? onSuffixPressed,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon != null
          ? IconButton(
              icon: Icon(suffixIcon),
              onPressed: onSuffixPressed,
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.greyColor),  // Utiliser la couleur gris
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.focusedBorderColor),  // Utiliser la couleur bleue
      ),
    ),
    validator: validator,
  );
}

Widget socialButton(IconData icon, String label, VoidCallback onPressed) {
  return InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor),  // Utiliser la couleur gris clair
        borderRadius: BorderRadius.circular(15),
      ),
      child: FaIcon(
        icon,
        size: 24,
        color: AppColors.greyColor,  // Utiliser la couleur gris pour l'icône
      ),
    ),
  );
}

Widget customButton(String label, VoidCallback onPressed, BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,  // Utiliser la couleur primaire
        foregroundColor: AppColors.buttonTextColor,  // Utiliser la couleur du texte
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
