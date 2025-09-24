import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import 'settings_page.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      appBar: AppBar(
        title: const Text('Sécurité'),
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Vérifier si on peut faire un retour normal
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // Si on ne peut pas faire pop, rediriger vers les paramètres
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
                (route) => false,
              );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildChangePasswordSection(),
              const SizedBox(height: 24),
              _buildTwoFactorSection(),
              const SizedBox(height: 24),
              _buildSessionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Changer le mot de passe',
            style: RecruiterTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildPasswordField(
            controller: _currentPasswordController,
            label: 'Mot de passe actuel',
            isObscure: true,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'Nouveau mot de passe',
            isObscure: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le nouveau mot de passe est requis';
              }
              if (value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirmer le nouveau mot de passe',
            isObscure: true,
            validator: (value) {
              if (value != _newPasswordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: RecruiterTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Changer le mot de passe'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoFactorSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Authentification à deux facteurs',
            style: RecruiterTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ajoutez une couche de sécurité supplémentaire à votre compte',
            style: RecruiterTheme.bodyMedium.copyWith(
              color: RecruiterTheme.customColors['secondary_text'],
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Activer 2FA'),
            subtitle: const Text('Recommandé pour la sécurité'),
            value: false,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité 2FA en développement'),
                ),
              );
            },
            activeThumbColor: RecruiterTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sessions actives',
            style: RecruiterTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Gérez vos sessions de connexion actives',
            style: RecruiterTheme.bodyMedium.copyWith(
              color: RecruiterTheme.customColors['secondary_text'],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text('Appareil actuel'),
            subtitle: const Text('Android • Connecté maintenant'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Actuel',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Déconnexion des autres appareils'),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Déconnecter tous les autres appareils'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    bool isObscure = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: RecruiterTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: RecruiterTheme.customColors['primary_text'],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Entrez $label',
            hintStyle: RecruiterTheme.bodyMedium.copyWith(
              color:
                  RecruiterTheme.customColors['secondary_text'] ?? Colors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: RecruiterTheme.customColors['border'] ?? Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: RecruiterTheme.customColors['border'] ?? Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: RecruiterTheme.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe changé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }
}
