import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard_screen.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool profileVisible = true;
  bool showEmail = false;
  bool showPhone = false;
  bool allowRecruiterContact = true;
  bool shareDataWithPartners = false;
  bool allowAnalytics = true;
  bool allowMarketingEmails = false;
  bool allowLocationTracking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          'Confidentialité',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPrivacySection(
              'Visibilité du profil',
              'Contrôlez qui peut voir vos informations',
              [
                _buildSwitchTile(
                  'Profil visible',
                  'Rendre votre profil visible aux recruteurs',
                  Icons.visibility,
                  profileVisible,
                  (value) => setState(() => profileVisible = value),
                ),
                _buildSwitchTile(
                  'Afficher l\'email',
                  'Permettre aux recruteurs de voir votre email',
                  Icons.email_outlined,
                  showEmail,
                  (value) => setState(() => showEmail = value),
                ),
                _buildSwitchTile(
                  'Afficher le téléphone',
                  'Permettre aux recruteurs de voir votre numéro',
                  Icons.phone_outlined,
                  showPhone,
                  (value) => setState(() => showPhone = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPrivacySection(
              'Communication',
              'Gérez vos préférences de communication',
              [
                _buildSwitchTile(
                  'Contact recruteurs',
                  'Permettre aux recruteurs de vous contacter',
                  Icons.business_outlined,
                  allowRecruiterContact,
                  (value) => setState(() => allowRecruiterContact = value),
                ),
                _buildSwitchTile(
                  'Emails marketing',
                  'Recevoir des emails promotionnels',
                  Icons.email_outlined,
                  allowMarketingEmails,
                  (value) => setState(() => allowMarketingEmails = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPrivacySection(
              'Données et analyse',
              'Contrôlez l\'utilisation de vos données',
              [
                _buildSwitchTile(
                  'Partage de données',
                  'Partager vos données avec nos partenaires',
                  Icons.share_outlined,
                  shareDataWithPartners,
                  (value) => setState(() => shareDataWithPartners = value),
                ),
                _buildSwitchTile(
                  'Analytics',
                  'Aider à améliorer l\'application',
                  Icons.analytics_outlined,
                  allowAnalytics,
                  (value) => setState(() => allowAnalytics = value),
                ),
                _buildSwitchTile(
                  'Localisation',
                  'Utiliser votre position pour des recommandations',
                  Icons.location_on_outlined,
                  allowLocationTracking,
                  (value) => setState(() => allowLocationTracking = value),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildActionButton(
              'Réinitialiser les paramètres',
              'Remettre tous les paramètres par défaut',
              Icons.restore_outlined,
              () => _showResetDialog(),
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              'Télécharger mes données',
              'Obtenir une copie de toutes vos données',
              Icons.download_outlined,
              () => _downloadData(),
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              'Supprimer mon compte',
              'Supprimer définitivement votre compte',
              Icons.delete_outline,
              () => _showDeleteAccountDialog(),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(
    String title,
    String subtitle,
    List<Widget> children,
  ) {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.3)
                : AppColors.blueDark.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppColors.blueDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.blueDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDestructive ? Colors.red : AppColors.primaryText,
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
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Réinitialiser les paramètres',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir remettre tous les paramètres de confidentialité par défaut ?',
          style: GoogleFonts.roboto(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.roboto()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueDark,
              foregroundColor: Colors.white,
            ),
            child: Text('Réinitialiser', style: GoogleFonts.roboto()),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Supprimer le compte',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Cette action est irréversible. Toutes vos données seront définitivement supprimées.',
          style: GoogleFonts.roboto(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.roboto()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implémenter la suppression du compte
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Supprimer', style: GoogleFonts.roboto()),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      profileVisible = true;
      showEmail = false;
      showPhone = false;
      allowRecruiterContact = true;
      shareDataWithPartners = false;
      allowAnalytics = true;
      allowMarketingEmails = false;
      allowLocationTracking = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Paramètres réinitialisés !',
          style: GoogleFonts.roboto(),
        ),
        backgroundColor: AppColors.blueDark,
      ),
    );
  }

  void _downloadData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Téléchargement de vos données...',
          style: GoogleFonts.roboto(),
        ),
        backgroundColor: AppColors.blueDark,
      ),
    );
  }
}
