import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import '../../../services/auth_service.dart';
import '../../../loginscreen.dart';
import '../recruiter_navigation.dart';
import 'profile_page.dart';
import 'security_page.dart';
import 'privacy_page.dart';
import 'help_page.dart';
import 'contact_page.dart';
import 'bug_report_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _selectedLanguage = 'Français';
  String _selectedTheme = 'Clair';
  String _companyName = 'Entreprise';
  String _companyEmail = 'email@entreprise.com';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final result = await _authService.getProfile();
    if (result['success'] && mounted) {
      setState(() {
        if (result['user'] != null) {
          final user = result['user'];
          _companyName = user.username;
          _companyEmail = user.email;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      appBar: AppBar(
        title: const Text('Paramètres'),
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
              // Si on ne peut pas faire pop (navigation principale),
              // rediriger vers le dashboard via la navigation principale
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const RecruiterNavigation(),
                ),
                (route) => false,
              );
            }
          },
        ),
      ),
      body: ListView(
        children: [
          _buildProfileSection(),
          _buildNotificationSection(),
          _buildAppearanceSection(),
          _buildAccountSection(),
          _buildSupportSection(),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: RecruiterTheme.primaryColor.withOpacity(0.1),
            child: Text(
              _companyName.isNotEmpty
                  ? _companyName.substring(0, 2).toUpperCase()
                  : 'EN',
              style: RecruiterTheme.headlineMedium.copyWith(
                color: RecruiterTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _companyName,
            style: RecruiterTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _companyEmail,
            style: RecruiterTheme.bodyMedium.copyWith(
              color: RecruiterTheme.customColors['secondary_text'],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Vérifiée CENADI',
                  style: RecruiterTheme.labelSmall.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: 'Notifications',
      children: [
        SwitchListTile(
          title: const Text('Activer les notifications'),
          subtitle: const Text('Recevoir des notifications push'),
          value: _notificationsEnabled,
          onChanged: (value) => setState(() => _notificationsEnabled = value),
          activeThumbColor: RecruiterTheme.primaryColor,
        ),
        SwitchListTile(
          title: const Text('Notifications par email'),
          subtitle: const Text('Recevoir des emails de mise à jour'),
          value: _emailNotifications,
          onChanged: (value) => setState(() => _emailNotifications = value),
          activeThumbColor: RecruiterTheme.primaryColor,
        ),
        SwitchListTile(
          title: const Text('Notifications push'),
          subtitle: const Text('Recevoir des notifications sur l\'appareil'),
          value: _pushNotifications,
          onChanged: (value) => setState(() => _pushNotifications = value),
          activeThumbColor: RecruiterTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      title: 'Apparence',
      children: [
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Langue'),
          subtitle: Text(_selectedLanguage),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showLanguageDialog,
        ),
        ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('Thème'),
          subtitle: Text(_selectedTheme),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showThemeDialog,
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'Compte',
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profil Entreprise'),
          subtitle: const Text('Modifier les informations de l\'entreprise'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _navigateToPage(const ProfilePage()),
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Sécurité'),
          subtitle: const Text('Mot de passe et authentification'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _navigateToPage(const SecurityPage()),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Confidentialité'),
          subtitle: const Text('Gérer vos données personnelles'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _navigateToPage(const PrivacyPage()),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'Support',
      children: [
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Aide'),
          subtitle: const Text('Centre d\'aide et FAQ'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _navigateToPage(const HelpPage()),
        ),
        ListTile(
          leading: const Icon(Icons.contact_support),
          title: const Text('Nous contacter'),
          subtitle: const Text('Support technique et assistance'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _navigateToPage(const ContactPage()),
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text('Signaler un problème'),
          subtitle: const Text('Signaler un bug ou une erreur'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _navigateToPage(const BugReportPage()),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'À propos',
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
          onTap: () => _showSnackBar('Version 1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Conditions d\'utilisation'),
          subtitle: const Text('Lire les conditions d\'utilisation'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showSnackBar('Conditions d\'utilisation'),
        ),
        ListTile(
          leading: const Icon(Icons.policy),
          title: const Text('Politique de confidentialité'),
          subtitle: const Text('Lire la politique de confidentialité'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showSnackBar('Politique de confidentialité'),
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          onTap: _showLogoutDialog,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: RecruiterTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: RecruiterTheme.customColors['primary_text'],
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'Français',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Clair'),
              value: 'Clair',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() => _selectedTheme = value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Sombre'),
              value: 'Sombre',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() => _selectedTheme = value!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performLogout();
            },
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Appeler la méthode de déconnexion du service d'authentification
      await _authService.logout();

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Déconnexion réussie'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Rediriger vers l'écran de connexion
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                const JobstageLoginScreen(userType: 'recruteur'),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      // En cas d'erreur, afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => page,
        settings: const RouteSettings(name: 'settings_subpage'),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
