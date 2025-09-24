import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import '../../../services/recruiter_api_service.dart';
import '../../../models/offre.dart';
import 'create_offer_page.dart';
import 'offer_details_page.dart';
import '../../../utils/navigation_helper.dart';
import '../recruiter_navigation.dart';

class OffersListPage extends StatefulWidget {
  const OffersListPage({super.key});

  @override
  State<OffersListPage> createState() => _OffersListPageState();
}

class _OffersListPageState extends State<OffersListPage> {
  final RecruiterApiService _apiService = RecruiterApiService();
  List<Offre> _offres = [];
  String _selectedFilter = 'Toutes';
  bool _isLoading = true;

  final List<String> _filters = [
    'Toutes',
    'Actives',
    'Désactivées',
    'CDI',
    'CDD',
    'Stage',
  ];

  @override
  void initState() {
    super.initState();
    _loadOffres();
  }

  Future<void> _loadOffres() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Chargement des offres du recruteur...');

      // Initialiser le service et charger les offres
      await _apiService.initialize();
      print('📊 Nombre d\'offres récupérées: ${_apiService.offres.length}');

      if (mounted) {
        setState(() {
          _offres = _apiService.offres;
          _isLoading = false;
        });
        print('✅ Offres chargées avec succès');
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des offres: $e');
      if (mounted) {
        setState(() {
          _offres = [];
          _isLoading = false;
        });
      }
    }
  }

  List<Offre> get _filteredOffres {
    if (_selectedFilter == 'Toutes') return _offres;
    if (_selectedFilter == 'Actives') {
      return _offres.where((offre) => offre.isActive).toList();
    }
    if (_selectedFilter == 'Désactivées') {
      return _offres.where((offre) => !offre.isActive).toList();
    }
    return _offres
        .where((offre) => offre.typeContrat == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    print('📱 OffersListPage.build() appelé');
    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      appBar: NavigationHelper.createAppBar(
        context,
        title: 'Mes offres',
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        fallbackScreen: RecruiterNavigation(),
        actions: [
          IconButton(onPressed: _loadOffres, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildOffresList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateOffer,
        backgroundColor: RecruiterTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              selectedColor: RecruiterTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: RecruiterTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? RecruiterTheme.primaryColor
                    : RecruiterTheme.customColors['secondary_text'],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: RecruiterTheme.primaryColor),
    );
  }

  Widget _buildOffresList() {
    final filteredOffres = _filteredOffres;

    if (filteredOffres.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOffres.length,
      itemBuilder: (context, index) {
        final offre = filteredOffres[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOfferCardWithActions(offre),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 80,
            color: RecruiterTheme.customColors['secondary_text'],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'Toutes'
                ? 'Aucune offre créée'
                : 'Aucune offre trouvée',
            style: RecruiterTheme.headlineSmall.copyWith(
              color: RecruiterTheme.customColors['secondary_text'],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'Toutes'
                ? 'Créez votre première offre d\'emploi'
                : 'Essayez un autre filtre',
            style: RecruiterTheme.bodyMedium.copyWith(
              color: RecruiterTheme.customColors['secondary_text'],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateOffer,
            icon: const Icon(Icons.add),
            label: const Text('Créer une offre'),
            style: ElevatedButton.styleFrom(
              backgroundColor: RecruiterTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateOffer() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CreateOfferPage()))
        .then((_) {
          // Recharger les offres après création
          _loadOffres();
        });
  }

  Widget _buildOfferCardWithActions(Offre offre) {
    final isDisabled = !offre.isActive;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDisabled ? Colors.grey[100] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDisabled ? 0.05 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : () => _navigateToOfferDetails(offre),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec titre et statut
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offre.titre,
                            style: RecruiterTheme.headlineSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDisabled
                                  ? Colors.grey[600]
                                  : RecruiterTheme.customColors['primary_text'],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Informations entreprise et localisation
                          Row(
                            children: [
                              Icon(
                                Icons.business,
                                size: 16,
                                color: isDisabled
                                    ? Colors.grey[500]
                                    : RecruiterTheme
                                          .customColors['secondary_text'],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  offre.entreprise,
                                  style: RecruiterTheme.bodyMedium.copyWith(
                                    color: isDisabled
                                        ? Colors.grey[500]
                                        : RecruiterTheme
                                              .customColors['secondary_text'],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: isDisabled
                                    ? Colors.grey[500]
                                    : RecruiterTheme
                                          .customColors['secondary_text'],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  offre.localisation,
                                  style: RecruiterTheme.bodyMedium.copyWith(
                                    color: isDisabled
                                        ? Colors.grey[500]
                                        : RecruiterTheme
                                              .customColors['secondary_text'],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(offre),
                  ],
                ),
                const SizedBox(height: 12),
                // Chips d'information avec Wrap pour éviter l'overflow
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(offre.typeContrat, Icons.work),
                    _buildInfoChip(offre.niveauExperience, Icons.trending_up),
                    if (offre.salaireAffichage.isNotEmpty)
                      _buildInfoChip(
                        offre.salaireAffichage,
                        Icons.attach_money,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Pied de carte avec date et actions
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Publiée le ${_formatDate(offre.datePublication)}',
                        style: RecruiterTheme.bodySmall.copyWith(
                          color: isDisabled
                              ? Colors.grey[500]
                              : RecruiterTheme.customColors['secondary_text'],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Actions dans un Row compact
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _toggleOfferStatus(offre),
                          icon: Icon(
                            offre.isActive ? Icons.pause : Icons.play_arrow,
                            color: isDisabled
                                ? Colors.grey[600]
                                : RecruiterTheme.primaryColor,
                            size: 20,
                          ),
                          tooltip: offre.isActive ? 'Désactiver' : 'Activer',
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: const EdgeInsets.all(4),
                        ),
                        IconButton(
                          onPressed: () => _showOfferActions(offre),
                          icon: Icon(
                            Icons.more_vert,
                            color: isDisabled
                                ? Colors.grey[600]
                                : RecruiterTheme.primaryColor,
                            size: 20,
                          ),
                          tooltip: 'Actions',
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Offre offre) {
    final isActive = offre.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? RecruiterTheme.primaryColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Désactivée',
        style: RecruiterTheme.labelSmall.copyWith(
          color: isActive ? RecruiterTheme.primaryColor : Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: RecruiterTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: RecruiterTheme.primaryColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: RecruiterTheme.labelSmall.copyWith(
                color: RecruiterTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _toggleOfferStatus(Offre offre) {
    setState(() {
      // Créer une nouvelle offre avec le statut inversé
      final index = _offres.indexWhere((o) => o.id == offre.id);
      if (index != -1) {
        _offres[index] = offre.copyWith(isActive: !offre.isActive);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(!offre.isActive ? 'Offre activée' : 'Offre désactivée'),
        backgroundColor: !offre.isActive ? Colors.green : Colors.orange,
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            setState(() {
              final index = _offres.indexWhere((o) => o.id == offre.id);
              if (index != -1) {
                _offres[index] = offre.copyWith(isActive: offre.isActive);
              }
            });
          },
        ),
      ),
    );
  }

  void _showOfferActions(Offre offre) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.of(context).pop();
                _editOffer(offre);
              },
            ),
            ListTile(
              leading: Icon(
                offre.isActive ? Icons.pause : Icons.play_arrow,
                color: offre.isActive ? Colors.orange : Colors.green,
              ),
              title: Text(offre.isActive ? 'Désactiver' : 'Activer'),
              onTap: () {
                Navigator.of(context).pop();
                _toggleOfferStatus(offre);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(offre);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _editOffer(Offre offre) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CreateOfferPage(offreToEdit: offre),
          ),
        )
        .then((_) {
          // Recharger les offres après modification
          _loadOffres();
        });
  }

  void _showDeleteConfirmation(Offre offre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'offre'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'offre "${offre.titre}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteOffer(offre);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _deleteOffer(Offre offre) {
    setState(() {
      _offres.removeWhere((o) => o.id == offre.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Offre "${offre.titre}" supprimée'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            setState(() {
              _offres.add(offre);
            });
          },
        ),
      ),
    );
  }

  void _navigateToOfferDetails(Offre offre) {
    if (!offre.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cette offre est désactivée. Activez-la pour y accéder.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => OfferDetailsPage(offre: offre)),
    );
  }
}
