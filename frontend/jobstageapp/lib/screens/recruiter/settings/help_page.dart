import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import 'settings_page.dart';
import '../../../utils/navigation_helper.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      appBar: NavigationHelper.createAppBar(
        context,
        title: 'Aide',
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        fallbackScreen: const SettingsPage(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildFaqSection(),
            const SizedBox(height: 24),
            _buildContactSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
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
        children: [
          Text(
            'Comment pouvons-nous vous aider ?',
            style: RecruiterTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher dans l\'aide...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
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
            'Questions fréquentes',
            style: RecruiterTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildFaqItem(
            'Comment créer une offre d\'emploi ?',
            'Allez dans l\'onglet "Offres" et cliquez sur le bouton "+" pour créer une nouvelle offre.',
          ),
          _buildFaqItem(
            'Comment contacter un candidat ?',
            'Cliquez sur le profil du candidat et utilisez les options de contact disponibles.',
          ),
          _buildFaqItem(
            'Comment modifier mon profil entreprise ?',
            'Allez dans Paramètres > Profil Entreprise pour modifier vos informations.',
          ),
          _buildFaqItem(
            'Comment gérer les notifications ?',
            'Dans Paramètres > Notifications, vous pouvez activer/désactiver les différents types de notifications.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: RecruiterTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: RecruiterTheme.bodyMedium.copyWith(
              color: RecruiterTheme.customColors['secondary_text'],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
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
            'Besoin d\'aide supplémentaire ?',
            style: RecruiterTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(
              Icons.email,
              color: RecruiterTheme.primaryColor,
            ),
            title: const Text('Nous contacter par email'),
            subtitle: const Text('support@jobstage.cm'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ouverture de l\'application email'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.phone,
              color: RecruiterTheme.primaryColor,
            ),
            title: const Text('Appeler le support'),
            subtitle: const Text('+237 6XX XXX XXX'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ouverture de l\'application téléphone'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: RecruiterTheme.primaryColor),
            title: const Text('Chat en direct'),
            subtitle: const Text('Disponible 24/7'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ouverture du chat de support')),
              );
            },
          ),
        ],
      ),
    );
  }
}
