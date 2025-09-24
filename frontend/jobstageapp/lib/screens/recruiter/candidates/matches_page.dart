import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import '../../../services/recruiter_api_service.dart';
import '../../../models/candidat.dart';
import 'candidate_details_page.dart';
import '../../../utils/navigation_helper.dart';
import '../recruiter_navigation.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final RecruiterApiService _apiService = RecruiterApiService();
  List<Candidat> _candidats = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'Tous';

  final List<String> _filters = [
    'Tous',
    'Disponibles',
    'Non disponibles',
    'Récents',
  ];

  @override
  void initState() {
    super.initState();
    _loadCandidats();
  }

  Future<void> _loadCandidats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Chargement des candidats...');

      // Charger les candidats depuis l'API
      await _apiService.initialize();
      final candidats = _apiService.candidats;

      if (mounted) {
        setState(() {
          _candidats = candidats;
          _isLoading = false;
        });
        print('✅ ${_candidats.length} candidats chargés');
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des candidats: $e');
      if (mounted) {
        setState(() {
          _candidats = [];
          _isLoading = false;
        });
      }
    }
  }

  List<Candidat> get _filteredCandidats {
    var filtered = _candidats.where((candidat) {
      final searchMatch =
          _searchQuery.isEmpty ||
          candidat.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          candidat.prenom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          candidat.domaineEtude.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      if (!searchMatch) return false;

      switch (_selectedFilter) {
        case 'Disponibles':
          return candidat.disponible == true;
        case 'Non disponibles':
          return candidat.disponible == false;
        case 'Récents':
          // Trier par date d'inscription récente
          return true;
        default:
          return true;
      }
    }).toList();

    if (_selectedFilter == 'Récents') {
      filtered.sort((a, b) => b.dateInscription.compareTo(a.dateInscription));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      appBar: NavigationHelper.createAppBar(
        context,
        title: 'Candidats',
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        fallbackScreen: RecruiterNavigation(),
        actions: [
          IconButton(
            onPressed: _loadCandidats,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildCandidatsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Rechercher un candidat...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filtres
          SizedBox(
            height: 40,
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
                    backgroundColor: Colors.white,
                    selectedColor: RecruiterTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: RecruiterTheme.primaryColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: RecruiterTheme.primaryColor),
          SizedBox(height: 16),
          Text('Chargement des candidats...'),
        ],
      ),
    );
  }

  Widget _buildCandidatsList() {
    final filteredCandidats = _filteredCandidats;

    if (filteredCandidats.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCandidats.length,
      itemBuilder: (context, index) {
        final candidat = filteredCandidats[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCandidatCard(candidat),
        );
      },
    );
  }

  Widget _buildCandidatCard(Candidat candidat) {
    final isDisponible = candidat.disponible;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToCandidateDetails(candidat),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et statut
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: RecruiterTheme.primaryColor.withOpacity(
                      0.1,
                    ),
                    child: Text(
                      _getInitials(candidat.prenom, candidat.nom),
                      style: TextStyle(
                        color: RecruiterTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidat.nomComplet,
                          style: RecruiterTheme.headlineSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: RecruiterTheme.customColors['primary_text'],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          candidat.domaineEtude,
                          style: RecruiterTheme.bodyMedium.copyWith(
                            color:
                                RecruiterTheme.customColors['secondary_text'],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(isDisponible),
                ],
              ),
              const SizedBox(height: 12),
              // Informations
              Row(
                children: [
                  if (candidat.localisation.isNotEmpty) ...[
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: RecruiterTheme.customColors['secondary_text'],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      candidat.localisation,
                      style: RecruiterTheme.bodyMedium.copyWith(
                        color: RecruiterTheme.customColors['secondary_text'],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (candidat.niveauEtude.isNotEmpty) ...[
                    Icon(
                      Icons.school,
                      size: 16,
                      color: RecruiterTheme.customColors['secondary_text'],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      candidat.niveauEtude,
                      style: RecruiterTheme.bodyMedium.copyWith(
                        color: RecruiterTheme.customColors['secondary_text'],
                      ),
                    ),
                  ],
                  if (candidat.localisation.isEmpty &&
                      candidat.niveauEtude.isEmpty) ...[
                    Icon(
                      Icons.email,
                      size: 16,
                      color: RecruiterTheme.customColors['secondary_text'],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        candidat.email,
                        style: RecruiterTheme.bodyMedium.copyWith(
                          color: RecruiterTheme.customColors['secondary_text'],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              // Compétences
              if (candidat.competences.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: candidat.competences
                      .take(3)
                      .map(
                        (competence) => Chip(
                          label: Text(
                            competence,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: RecruiterTheme.primaryColor
                              .withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: RecruiterTheme.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: RecruiterTheme.customColors['secondary_text'],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      candidat.telephone.isNotEmpty
                          ? candidat.telephone
                          : 'Téléphone non renseigné',
                      style: RecruiterTheme.bodyMedium.copyWith(
                        color: RecruiterTheme.customColors['secondary_text'],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isDisponible) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDisponible
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDisponible ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDisponible ? Icons.visibility : Icons.visibility_off,
            size: 14,
            color: isDisponible ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isDisponible ? 'Disponible' : 'Indisponible',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDisponible ? Colors.green : Colors.orange,
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
          Icon(
            Icons.person_search,
            size: 80,
            color: RecruiterTheme.customColors['secondary_text'],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucun candidat trouvé'
                : 'Aucun candidat disponible',
            style: RecruiterTheme.headlineSmall.copyWith(
              color: RecruiterTheme.customColors['secondary_text'],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Essayez avec d\'autres mots-clés'
                : 'Les candidats apparaîtront ici quand ils s\'inscriront',
            style: RecruiterTheme.bodyMedium.copyWith(
              color: RecruiterTheme.customColors['secondary_text'],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String prenom, String nom) {
    String prenomInitial = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    String nomInitial = nom.isNotEmpty ? nom[0].toUpperCase() : '';

    if (prenomInitial.isEmpty && nomInitial.isEmpty) {
      return 'C';
    }

    return '$prenomInitial$nomInitial';
  }

  void _navigateToCandidateDetails(Candidat candidat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CandidateDetailsPage(candidat: candidat),
      ),
    );
  }
}
