import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import 'settings_page.dart';
import '../../../utils/navigation_helper.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      appBar: NavigationHelper.createAppBar(
        context,
        title: 'Confidentialité',
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        fallbackScreen: const SettingsPage(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(
              title: 'Données personnelles',
              children: [
                SwitchListTile(
                  title: const Text(
                    'Partager mes données avec des partenaires',
                  ),
                  subtitle: const Text(
                    'Permettre aux partenaires d\'accéder à vos données',
                  ),
                  value: false,
                  onChanged: (value) {},
                  activeThumbColor: RecruiterTheme.primaryColor,
                ),
                SwitchListTile(
                  title: const Text('Analytics et amélioration'),
                  subtitle: const Text('Aider à améliorer l\'application'),
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: RecruiterTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Visibilité du profil',
              children: [
                SwitchListTile(
                  title: const Text('Profil public'),
                  subtitle: const Text('Votre profil est visible par tous'),
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: RecruiterTheme.primaryColor,
                ),
                SwitchListTile(
                  title: const Text('Apparaître dans les recherches'),
                  subtitle: const Text(
                    'Permettre aux candidats de vous trouver',
                  ),
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: RecruiterTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Notifications',
              children: [
                SwitchListTile(
                  title: const Text('Notifications marketing'),
                  subtitle: const Text('Recevoir des offres et promotions'),
                  value: false,
                  onChanged: (value) {},
                  activeThumbColor: RecruiterTheme.primaryColor,
                ),
                SwitchListTile(
                  title: const Text('Notifications de sécurité'),
                  subtitle: const Text('Alertes importantes sur votre compte'),
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: RecruiterTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Données',
              children: [
                ListTile(
                  title: const Text('Télécharger mes données'),
                  subtitle: const Text('Obtenir une copie de vos données'),
                  trailing: const Icon(Icons.download),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Téléchargement des données...'),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Supprimer mon compte'),
                  subtitle: const Text('Supprimer définitivement votre compte'),
                  trailing: const Icon(Icons.delete, color: Colors.red),
                  onTap: () {
                    _showDeleteAccountDialog(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
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
            title,
            style: RecruiterTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer définitivement votre compte ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Suppression du compte...')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
