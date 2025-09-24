import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../dashboard_screen.dart';
import '../../../services/application_service.dart';
import '../../../models/candidature.dart';
import '../../../widgets/recruiter_application_card.dart';

class RecruiterApplicationsPage extends StatefulWidget {
  const RecruiterApplicationsPage({super.key});

  @override
  State<RecruiterApplicationsPage> createState() =>
      _RecruiterApplicationsPageState();
}

class _RecruiterApplicationsPageState extends State<RecruiterApplicationsPage> {
  List<Candidature> _applications = [];
  bool _isLoading = true;
  String _selectedFilter = 'Toutes';

  final List<String> _filters = [
    'Toutes',
    'Nouvelles',
    'Vues',
    'Présélectionnées',
    'Rejetées',
    'Acceptées',
  ];

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
      final applications = await ApplicationService.getRecruiterApplications();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des candidatures: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Candidature> get _filteredApplications {
    if (_selectedFilter == 'Toutes') return _applications;

    switch (_selectedFilter) {
      case 'Nouvelles':
        return _applications.where((app) => app.statut == 'envoyee').toList();
      case 'Vues':
        return _applications.where((app) => app.statut == 'vue').toList();
      case 'Présélectionnées':
        return _applications
            .where((app) => app.statut == 'preselectionnee')
            .toList();
      case 'Rejetées':
        return _applications.where((app) => app.statut == 'refusee').toList();
      case 'Acceptées':
        return _applications.where((app) => app.statut == 'acceptee').toList();
      default:
        return _applications;
    }
  }

  Future<void> _updateApplicationStatus(
    Candidature candidature,
    String newStatus,
  ) async {
    try {
      final success = await ApplicationService.updateApplicationStatus(
        candidatureId: candidature.id,
        nouveauStatut: newStatus,
      );

      if (success) {
        setState(() {
          final index = _applications.indexWhere(
            (app) => app.id == candidature.id,
          );
          if (index != -1) {
            _applications[index] = candidature.copyWith(statut: newStatus);
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Statut mis à jour: ${_getStatusText(newStatus)}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la mise à jour du statut'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Erreur mise à jour statut: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showApplicationDetails(Candidature candidature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de la candidature'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Candidat: ${candidature.candidatNom ?? 'N/A'}'),
              Text('Email: ${candidature.candidatEmail ?? 'N/A'}'),
              Text('Téléphone: ${candidature.candidatTelephone ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Offre: ${candidature.offreTitre ?? 'N/A'}'),
              Text('Entreprise: ${candidature.offreEntreprise ?? 'N/A'}'),
              Text('Localisation: ${candidature.offreLocalisation ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Statut: ${_getStatusText(candidature.statut)}'),
              Text('Date: ${_formatDate(candidature.dateCandidature)}'),
              if (candidature.cvPath.isNotEmpty)
                Text('CV: ${candidature.cvPath}'),
              if (candidature.lettreMotivationPath.isNotEmpty)
                Text('Lettre: ${candidature.lettreMotivationPath}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: Text(
          'Candidatures Reçues',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        backgroundColor: AppColors.surfaceBg,
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
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: AppColors.blueDark,
                    checkmarkColor: Colors.white,
                  ),
                );
              },
            ),
          ),

          // Liste des candidatures
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredApplications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredApplications.length,
                    itemBuilder: (context, index) {
                      final application = _filteredApplications[index];
                      return RecruiterApplicationCard(
                        candidature: application,
                        onTap: () => _showApplicationDetails(application),
                        onMarkAsViewed: () =>
                            _updateApplicationStatus(application, 'vue'),
                        onPreSelect: () => _updateApplicationStatus(
                          application,
                          'preselectionnee',
                        ),
                        onAccept: () =>
                            _updateApplicationStatus(application, 'acceptee'),
                         onReject: () =>
                             _updateApplicationStatus(application, 'refusee'),
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
          Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune candidature',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les candidatures apparaîtront ici dès qu\'elles seront envoyées.',
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStatusText(String statut) {
    switch (statut) {
      case 'envoyee':
        return 'Nouvelle';
      case 'vue':
        return 'Vue';
      case 'preselectionnee':
        return 'Présélectionnée';
      case 'refusee':
        return 'Rejetée';
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
