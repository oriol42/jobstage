import 'package:flutter/material.dart';
import '../../dashboard_screen.dart';

class CandidateSettingsPage extends StatefulWidget {
  const CandidateSettingsPage({super.key});

  @override
  State<CandidateSettingsPage> createState() => _CandidateSettingsPageState();
}

class _CandidateSettingsPageState extends State<CandidateSettingsPage> {
  bool _isDisponible = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
  }

  Future<void> _loadCurrentStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger le statut de disponibilité actuel
      // Pour l'instant, on utilise une valeur par défaut
      // Plus tard, on pourra charger depuis l'API
      setState(() {
        _isDisponible = true; // Valeur par défaut
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur lors du chargement du statut: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleDisponibilite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Changement de disponibilité: ${!_isDisponible}');

      // Ici, on appellera l'API pour mettre à jour le statut
      // Pour l'instant, on simule juste le changement local
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isDisponible = !_isDisponible;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isDisponible
                ? 'Vous êtes maintenant disponible pour les recruteurs'
                : 'Vous n\'êtes plus visible par les recruteurs',
          ),
          backgroundColor: _isDisponible ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      print('❌ Erreur lors du changement de disponibilité: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du changement de statut'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Disponibilité'),
                  const SizedBox(height: 16),
                  _buildDisponibiliteCard(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Autres paramètres'),
                  const SizedBox(height: 16),
                  _buildOtherSettings(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildDisponibiliteCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isDisponible ? Icons.visibility : Icons.visibility_off,
                  color: _isDisponible ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isDisponible ? 'Disponible' : 'Non disponible',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isDisponible
                            ? 'Les recruteurs peuvent vous voir et vous contacter'
                            : 'Vous n\'apparaissez pas dans les recherches des recruteurs',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleDisponibilite,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        _isDisponible ? Icons.visibility_off : Icons.visibility,
                      ),
                label: Text(
                  _isDisponible
                      ? 'Se rendre indisponible'
                      : 'Se rendre disponible',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDisponible ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.person,
            title: 'Profil',
            subtitle: 'Modifier vos informations personnelles',
            onTap: () {
              // TODO: Navigation vers la page de profil
            },
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Gérer vos préférences de notification',
            onTap: () {
              // TODO: Navigation vers la page de notifications
            },
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.privacy_tip,
            title: 'Confidentialité',
            subtitle: 'Contrôler la visibilité de vos données',
            onTap: () {
              // TODO: Navigation vers la page de confidentialité
            },
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.help,
            title: 'Aide',
            subtitle: 'Centre d\'aide et support',
            onTap: () {
              // TODO: Navigation vers la page d'aide
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.blueDark),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: AppColors.secondaryText),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
