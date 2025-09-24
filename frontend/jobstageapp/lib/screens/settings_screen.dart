import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../dashboard_screen.dart';
import '../theme/theme_provider.dart';
import '../services/auth_service.dart';
import '../loginscreen.dart';
import 'privacy_screen.dart';
import 'help_center_screen.dart';
import 'report_problem_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool jobAlerts = true;
  bool messageNotifications = false;
  bool disponible = true;
  String selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode
              ? const Color(0xFF000000)
              : AppColors.surfaceBg,
          appBar: AppBar(
            backgroundColor: themeProvider.isDarkMode
                ? const Color(0xFF1C1C1E)
                : AppColors.blueDark,
            foregroundColor: Colors.white,
            title: Text(
              'Paramètres',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSettingsSection('Notifications', [
                  _buildSwitchTile(
                    'Notifications push',
                    'Recevoir des notifications sur votre appareil',
                    Icons.notifications,
                    pushNotifications,
                    (value) => setState(() => pushNotifications = value),
                  ),
                  _buildSwitchTile(
                    'Notifications email',
                    'Recevoir des emails de notification',
                    Icons.email,
                    emailNotifications,
                    (value) => setState(() => emailNotifications = value),
                  ),
                  _buildSwitchTile(
                    'Alertes d\'emploi',
                    'Notifications pour les nouvelles offres',
                    Icons.work_outline,
                    jobAlerts,
                    (value) => setState(() => jobAlerts = value),
                  ),
                  _buildSwitchTile(
                    'Messages',
                    'Notifications pour les nouveaux messages',
                    Icons.message_outlined,
                    messageNotifications,
                    (value) => setState(() => messageNotifications = value),
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection('Apparence', [
                  _buildSwitchTile(
                    'Mode sombre',
                    'Utiliser le thème sombre de l\'application',
                    Icons.dark_mode,
                    themeProvider.isDarkMode,
                    (value) async {
                      await themeProvider.setDarkMode(value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value ? 'Mode sombre activé' : 'Mode clair activé',
                            style: GoogleFonts.roboto(),
                          ),
                          backgroundColor: value
                              ? Colors.grey[800]
                              : AppColors.blueDark,
                        ),
                      );
                    },
                  ),
                  _buildLanguageTile(),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection('Compte', [
                  _buildActionTile(
                    'Mot de passe',
                    'Changer votre mot de passe',
                    Icons.lock_outline,
                    () => _showChangePasswordDialog(),
                  ),
                  _buildActionTile(
                    'Confidentialité',
                    'Paramètres de confidentialité',
                    Icons.privacy_tip_outlined,
                    () => _navigateToPrivacySettings(),
                  ),
                  _buildActionTile(
                    'Sécurité',
                    'Authentification à deux facteurs',
                    Icons.security_outlined,
                    () => _showComingSoon(),
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection('Disponibilité', [
                  _buildDisponibiliteTile(themeProvider),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection('Support', [
                  _buildActionTile(
                    'Centre d\'aide',
                    'FAQ et guides d\'utilisation',
                    Icons.help_outline,
                    () => _navigateToHelpCenter(),
                  ),
                  _buildActionTile(
                    'Nous contacter',
                    'Envoyer un message de support',
                    Icons.contact_support_outlined,
                    () => _showContactDialog(),
                  ),
                  _buildActionTile(
                    'Signaler un problème',
                    'Signaler un bug ou un problème',
                    Icons.bug_report_outlined,
                    () => _navigateToReportProblem(),
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection('À propos', [
                  _buildActionTile(
                    'Version de l\'app',
                    'Version 1.0.0 (Build 1)',
                    Icons.info_outline,
                    null,
                  ),
                  _buildActionTile(
                    'Conditions d\'utilisation',
                    'Lire les conditions d\'utilisation',
                    Icons.description_outlined,
                    () => _showComingSoon(),
                  ),
                  _buildActionTile(
                    'Politique de confidentialité',
                    'Lire notre politique de confidentialité',
                    Icons.policy_outlined,
                    () => _showComingSoon(),
                  ),
                ]),
                const SizedBox(height: 30),
                _buildLogoutButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
          ),
          ...children.map(
            (child) => Column(
              children: [
                child,
                if (children.last != child) const Divider(height: 1),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blueDark.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.blueDark, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.blueDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blueDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.blueDark, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.secondaryText,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: _showLanguageDialog,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blueDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.language,
                  color: AppColors.blueDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Langue',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      selectedLanguage,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _showLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout),
            const SizedBox(width: 8),
            Text(
              'Se déconnecter',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Choisir la langue',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Français'),
            _buildLanguageOption('English'),
            _buildLanguageOption('العربية'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      leading: Radio<String>(
        value: language,
        groupValue: selectedLanguage,
        onChanged: (value) {
          if (mounted) {
            setState(() {
              selectedLanguage = value!;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Langue changée vers $language')),
            );
          }
        },
      ),
      onTap: () {
        setState(() {
          selectedLanguage = language;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Langue changée vers $language')),
        );
      },
    );
  }

  void _navigateToPrivacySettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyScreen()),
    );
  }

  void _navigateToHelpCenter() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
    );
  }

  void _navigateToReportProblem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportProblemScreen()),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.blueDark.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.blueDark.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: AppColors.blueDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Changer le mot de passe',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Mot de passe actuel
                        TextField(
                          controller: currentPasswordController,
                          obscureText: obscureCurrentPassword,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Mot de passe actuel',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureCurrentPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureCurrentPassword =
                                      !obscureCurrentPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.blueDark,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Nouveau mot de passe
                        TextField(
                          controller: newPasswordController,
                          obscureText: obscureNewPassword,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Nouveau mot de passe',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureNewPassword = !obscureNewPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.blueDark,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Confirmer le mot de passe
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirmPassword,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            prefixIcon: const Icon(Icons.lock_reset),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.blueDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBg,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          'Annuler',
                          style: GoogleFonts.roboto(
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => _changePassword(
                                currentPasswordController.text,
                                newPasswordController.text,
                                confirmPasswordController.text,
                                setState,
                                () => setState(() => isLoading = true),
                                () => setState(() => isLoading = false),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Modifier',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthode pour changer le mot de passe
  Future<void> _changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
    StateSetter setState,
    VoidCallback setLoading,
    VoidCallback setNotLoading,
  ) async {
    // Validation côté client
    if (currentPassword.isEmpty) {
      _showErrorSnackBar('Veuillez entrer votre mot de passe actuel');
      return;
    }

    if (newPassword.isEmpty) {
      _showErrorSnackBar('Veuillez entrer un nouveau mot de passe');
      return;
    }

    if (newPassword.length < 8) {
      _showErrorSnackBar(
        'Le nouveau mot de passe doit contenir au moins 8 caractères',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorSnackBar('Les mots de passe ne correspondent pas');
      return;
    }

    setLoading();

    try {
      final result = await _authService.changePassword(
        oldPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirm: confirmPassword,
      );

      if (result['success']) {
        Navigator.pop(context);
        _showSuccessSnackBar('Mot de passe modifié avec succès');
      } else {
        _showErrorSnackBar(
          result['message'] ?? 'Erreur lors du changement de mot de passe',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: ${e.toString()}');
    } finally {
      setNotLoading();
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.greenDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFdc3545),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showContactDialog() {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Nous contacter',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Décrivez votre problème ou votre question :',
              style: GoogleFonts.roboto(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: messageController,
              maxLines: 4,
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Votre message...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.roboto(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Message envoyé ! Nous vous répondrons bientôt.',
                  ),
                  backgroundColor: AppColors.greenDark,
                ),
              );
            },
            child: Text(
              'Envoyer',
              style: GoogleFonts.roboto(
                color: AppColors.blueDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Se déconnecter',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: GoogleFonts.roboto(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.roboto(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            child: Text(
              'Se déconnecter',
              style: GoogleFonts.roboto(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Fonctionnalité à venir',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        content: Text(
          'Cette fonctionnalité sera disponible dans une prochaine mise à jour.',
          style: GoogleFonts.roboto(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.roboto(
                color: AppColors.blueDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisponibiliteTile(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: disponible ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          disponible ? Icons.visibility : Icons.visibility_off,
          color: disponible ? Colors.green : Colors.orange,
        ),
        title: Text(
          disponible ? 'Disponible' : 'Non disponible',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: themeProvider.isDarkMode
                ? Colors.white
                : AppColors.primaryText,
          ),
        ),
        subtitle: Text(
          disponible
              ? 'Les recruteurs peuvent vous voir et vous contacter'
              : 'Vous n\'apparaissez pas dans les recherches des recruteurs',
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: themeProvider.isDarkMode
                ? Colors.grey[300]
                : AppColors.secondaryText,
          ),
        ),
        trailing: Switch(
          value: disponible,
          onChanged: (value) {
            setState(() {
              disponible = value;
            });
            _showDisponibiliteMessage();
          },
          activeColor: Colors.green,
          inactiveThumbColor: Colors.orange,
        ),
      ),
    );
  }

  void _showDisponibiliteMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          disponible
              ? 'Vous êtes maintenant disponible pour les recruteurs'
              : 'Vous n\'êtes plus visible par les recruteurs',
        ),
        backgroundColor: disponible ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Appeler la méthode de déconnexion du service d'authentification
      await _authService.logout();

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Déconnexion réussie'),
          backgroundColor: AppColors.greenDark,
        ),
      );

      // Rediriger vers l'écran de connexion
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const JobstageLoginScreen()),
        (route) => false,
      );
    } catch (e) {
      // En cas d'erreur, afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
