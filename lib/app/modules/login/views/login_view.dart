import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../auth/controllers/auth_controller.dart';
import 'login_widget.dart';

class LoginView extends GetView<AuthController> {
  LoginView({Key? key}) : super(key: key);

  // Clés de formulaire et contrôleurs
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final RxBool _isPasswordVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(), // Retour à la page précédente
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Titre principal
                    FadeInDown(
                      duration: const Duration(milliseconds: 1500),
                      child: const Text(
                        'Connexion',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sous-titre
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 1500),
                      child: const Text(
                        'Connectez-vous pour accéder à votre compte',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Champ E-mail
                    FadeInDown(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 1500),
                      child: customTextField(
                        controller: _emailController,
                        labelText: 'E-mail',
                        hintText: 'Entrez votre e-mail',
                        prefixIcon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre e-mail';
                          } else if (!GetUtils.isEmail(value)) {
                            return 'Veuillez entrer un e-mail valide';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Champ Mot de passe
                    Obx(
                      () => FadeInDown(
                        delay: const Duration(milliseconds: 600),
                        duration: const Duration(milliseconds: 1500),
                        child: customTextField(
                          controller: _passwordController,
                          labelText: 'Mot de passe',
                          hintText: 'Entrez votre mot de passe',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: _isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          onSuffixPressed: () {
                            _isPasswordVisible.value =
                                !_isPasswordVisible.value;
                          },
                          obscureText: !_isPasswordVisible.value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lien mot de passe oublié
                    FadeInDown(
                      delay: const Duration(milliseconds: 800),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed('/reset-password'),
                          child: const Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Bouton Se connecter
                    FadeInUp(
                      delay: const Duration(milliseconds: 1000),
                      child: customButton(
                        'Se connecter',
                        _onLoginPressed,
                        context,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lien Créer un compte
                    FadeInUp(
                      delay: const Duration(milliseconds: 1200),
                      child: Center(
                        child: TextButton(
                          onPressed: () => Get.toNamed('/register'),
                          child: const Text(
                            'Créer un compte',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Ligne séparatrice
                    FadeInUp(
                      delay: const Duration(milliseconds: 1200),
                      child: Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Ou continuer avec',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Boutons réseaux sociaux
                    FadeInUp(
                      delay: const Duration(milliseconds: 1400),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          socialButton(
                            FontAwesomeIcons.google,
                            'Google',
                            controller.signInWithGoogle,
                          ),
                          socialButton(
                            FontAwesomeIcons.apple,
                            'Apple',
                            () {}, // Action pour Apple
                          ),
                          socialButton(
                            FontAwesomeIcons.facebook,
                            'Facebook',
                            controller.signInWithFacebook,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Chargement en cours
            Obx(
              () => controller.isLoading.value
                  ? Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour gérer la connexion
  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      controller.signInWithEmailAndPassword(email, password);
    }
  }
}
