import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard_screen.dart';
import '../services/application_service.dart';
import '../models/candidature.dart';
import '../widgets/application_card.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  List<Candidature> _applications = [];
  bool _isLoading = true;
  String _selectedFilter = 'Toutes';

  final List<String> _filters = ['Toutes', 'En cours', 'Acceptées', 'Refusées'];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final applications = await ApplicationService.getMyApplications();
      if (mounted) {
        setState(() {
          _applications = applications;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement candidatures: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Erreur lors du chargement des candidatures');
      }
    }
  }

  List<Candidature> get _filteredApplications {
    if (_selectedFilter == 'Toutes') return _applications;

    return _applications.where((app) {
      switch (_selectedFilter) {
        case 'En cours':
          return app.statut == 'envoyee' ||
              app.statut == 'vue' ||
              app.statut == 'preselectionnee';
        case 'Acceptées':
          return app.statut == 'acceptee';
        case 'Refusées':
          return app.statut == 'refusee';
        default:
          return true;
      }
    }).toList();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          'Mes Candidatures',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadApplications,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            color: AppColors.blueDark,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.blueDark
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Liste des candidatures
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.blueDark),
                  )
                : _filteredApplications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredApplications.length,
                    itemBuilder: (context, index) {
                      final application = _filteredApplications[index];
                      return ApplicationCard(
                        candidature: application,
                        onTap: () => _showApplicationDetails(application),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'Toutes'
                ? 'Aucune candidature envoyée'
                : 'Aucune candidature $_selectedFilter.toLowerCase()',
            style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos candidatures apparaîtront ici dès que vous les aurez envoyées.',
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showApplicationDetails(Candidature candidature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Détails de la candidature',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Offre', 'Offre ${candidature.offreId}'),
              _buildDetailRow(
                'Date de candidature',
                _formatDate(candidature.dateCandidature),
              ),
              _buildDetailRow('Statut', _getStatusText(candidature.statut)),

              if (candidature.dateVue != null)
                _buildDetailRow(
                  'Date de vue',
                  _formatDate(candidature.dateVue!),
                ),

              if (candidature.dateReponse != null)
                _buildDetailRow(
                  'Date de réponse',
                  _formatDate(candidature.dateReponse!),
                ),

              if (candidature.cvPath.isNotEmpty)
                _buildDetailRow('CV', 'Fichier joint'),

              if (candidature.lettreMotivationPath.isNotEmpty)
                _buildDetailRow('Lettre de motivation', 'Fichier joint'),

              if (candidature.messageRecruteur.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Message du recruteur:',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    candidature.messageRecruteur,
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.roboto(fontSize: 14))),
        ],
      ),
    );
  }

  String _getStatusText(String statut) {
    switch (statut) {
      case 'envoyee':
        return 'En cours';
      case 'vue':
        return 'Vue';
      case 'preselectionnee':
        return 'Présélectionnée';
      case 'refusee':
        return 'Refusée';
      case 'acceptee':
        return 'Acceptée';
      default:
        return 'Inconnu';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

