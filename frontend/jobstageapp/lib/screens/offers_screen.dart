import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard_screen.dart';
import '../utils/offer_status.dart';
import '../services/candidate_api_service.dart';
import '../services/favorite_service.dart';
import '../models/offre.dart';
import '../widgets/simple_apply_dialog.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final CandidateApiService _apiService = CandidateApiService();
  bool _isLoading = true;

  // Système de filtres multiples
  Set<String> selectedFilters = {'Tous'};
  final List<String> filters = [
    'Tous',
    'Emplois',
    'Stages',
    'CDI',
    'CDD',
    'Stage 6 mois',
    'Stage académique',
    'Stage libre',
    'Yaoundé',
    'Douala',
    'Bafoussam',
    'Récent',
    'Match élevé',
    'Freelance',
    'Temps partiel',
    'Télétravail',
  ];

  List<Offre> allOffers = [];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.initialize();
      final offres = await _apiService.getOffres();
      if (mounted) {
        setState(() {
          allOffers = offres;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des offres: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Offre> get filteredOffers {
    if (selectedFilters.isEmpty || selectedFilters.contains('Tous')) {
      return allOffers;
    }

    List<Offre> filtered = List.from(allOffers);

    // Filtrer par type d'offre
    if (selectedFilters.contains('Emplois')) {
      filtered = filtered
          .where((offer) => offer.typeContrat != 'Stage')
          .toList();
    }
    if (selectedFilters.contains('Stages')) {
      filtered = filtered
          .where((offer) => offer.typeContrat == 'Stage')
          .toList();
    }

    // Filtrer par type de contrat
    Set<String> contractFilters = selectedFilters.intersection({
      'CDI',
      'CDD',
      'Stage 6 mois',
      'Stage académique',
      'Stage libre',
      'Freelance',
      'Temps partiel',
    });
    if (contractFilters.isNotEmpty) {
      filtered = filtered.where((offer) {
        return contractFilters.any((filter) {
          switch (filter) {
            case 'Stage 6 mois':
              return offer.typeContrat == 'Stage' && offer.dureeMois == 6;
            case 'Stage académique':
              return offer.typeContrat == 'Stage' &&
                  offer.typeStage == 'Stage court';
            case 'Stage libre':
              return offer.typeContrat == 'Stage' &&
                  offer.typeStage == 'Stage long';
            case 'CDI':
              return offer.typeContrat == 'CDI';
            case 'CDD':
              return offer.typeContrat == 'CDD';
            case 'Freelance':
              return offer.typeContrat == 'Freelance';
            case 'Temps partiel':
              return offer.typeContrat == 'Temps partiel';
            default:
              return offer.typeContrat.contains(filter);
          }
        });
      }).toList();
    }

    // Filtrer par localisation
    Set<String> locationFilters = selectedFilters.intersection({
      'Yaoundé',
      'Douala',
      'Bafoussam',
      'Télétravail',
    });
    if (locationFilters.isNotEmpty) {
      filtered = filtered.where((offer) {
        return locationFilters.any(
          (location) =>
              offer.localisation.toLowerCase().contains(location.toLowerCase()),
        );
      }).toList();
    }

    // Trier si nécessaire
    if (selectedFilters.contains('Récent')) {
      filtered.sort((a, b) => b.datePublication.compareTo(a.datePublication));
    }
    if (selectedFilters.contains('Match élevé')) {
      filtered.sort((a, b) => b.nombreCandidats.compareTo(a.nombreCandidats));
    }

    return filtered;
  }

  Future<void> toggleFavorite(Offre offre) async {
    try {
      final success = await FavoriteService.toggleFavorite(int.parse(offre.id));
      if (success) {
        setState(() {}); // Rafraîchir l'interface
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Favori mis à jour'),
            backgroundColor: AppColors.greenDark,
          ),
        );
      }
    } catch (e) {
      print('Erreur lors de la gestion des favoris: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour des favoris'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isNotEmpty) {
      try {
        final offres = await _apiService.rechercherOffres(query: query);
        setState(() {
          allOffers = offres;
        });
      } catch (e) {
        print('Erreur lors de la recherche: $e');
      }
    } else {
      await _loadOffers();
    }
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (filter == 'Tous') {
        selectedFilters.clear();
        selectedFilters.add('Tous');
      } else {
        selectedFilters.remove(
          'Tous',
        ); // Retirer "Tous" si on sélectionne autre chose
        if (selectedFilters.contains(filter)) {
          selectedFilters.remove(filter);
        } else {
          selectedFilters.add(filter);
        }
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      selectedFilters.clear();
      selectedFilters.add('Tous');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          'Offres d\'Emploi et Stages',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            color: AppColors.blueDark,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    onChanged: _performSearch,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une offre...',
                      hintStyle: GoogleFonts.roboto(
                        color: AppColors.secondaryText,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.secondaryText,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Filter chips avec sélection multiple
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bouton pour effacer tous les filtres
                    if (selectedFilters.isNotEmpty &&
                        !selectedFilters.contains('Tous'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextButton.icon(
                          onPressed: _clearAllFilters,
                          icon: const Icon(
                            Icons.clear_all,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: Text(
                            'Effacer tous les filtres',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                      ),

                    // Liste horizontale des filtres
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters.length,
                        itemBuilder: (context, index) {
                          final filter = filters[index];
                          final isSelected = selectedFilters.contains(filter);
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FilterChip(
                              label: Text(
                                filter,
                                style: GoogleFonts.roboto(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.blueDark,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) => _toggleFilter(filter),
                              backgroundColor: AppColors.blueLight,
                              selectedColor: AppColors.blueDark,
                              checkmarkColor: Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.blueDark
                                    : AppColors.blueLight,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Results count
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  '${filteredOffers.length} offre(s) trouvée(s)',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          // Offers list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOffers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune offre trouvée',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez de modifier vos filtres ou votre recherche',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredOffers.length,
                    itemBuilder: (context, index) {
                      final offer = filteredOffers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildOfferCard(offer, index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Offre offer, int index) {
    final borderColor = offer.typeContrat != 'Stage'
        ? AppColors.greenDark
        : AppColors.blueDark;

    return GestureDetector(
      onTap: () {
        // Navigate to offer details
        _showOfferDetails(offer);
      },
      child: Container(
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
          border: Border(left: BorderSide(color: borderColor, width: 5)),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.titre,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildStatusBadge(offer.statut),
                      const SizedBox(height: 4),
                      Text(
                        offer.entreprise,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        offer.salaireAffichage,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => toggleFavorite(offer),
                      child: FutureBuilder<bool>(
                        future: FavoriteService.isFavorite(int.parse(offer.id)),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.data ?? false;
                          return Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : AppColors.secondaryText,
                            size: 24,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${offer.nombreCandidats} candidats',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildDetailChip(
                    Icons.pin_drop,
                    offer.localisation,
                    AppColors.orangeDark,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildDetailChip(
                    Icons.description,
                    offer.typeContrat,
                    AppColors.blueDark,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildDetailChip(
                    Icons.schedule,
                    _formatTimeAgo(offer.datePublication),
                    Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bouton Postuler
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showApplyDialog(offer),
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Postuler'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: borderColor,
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

  void _showApplyDialog(Offre offer) {
    showDialog(
      context: context,
      builder: (context) => SimpleApplyDialog(offre: offer),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  Widget _buildDetailChip(IconData icon, String text, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showOfferDetails(Offre offer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.titre,
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        offer.entreprise,
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailSection('Salaire', offer.salaireAffichage),
                      _buildLocationSection('Localisation', offer.localisation),
                      _buildDetailSection('Type de contrat', offer.typeContrat),
                      _buildDetailSection(
                        'Niveau d\'expérience',
                        offer.niveauExperience,
                      ),
                      _buildDetailSection(
                        'Publié',
                        _formatTimeAgo(offer.datePublication),
                      ),
                      _buildDetailSection('Description', offer.description),
                      _buildDetailSection(
                        'Compétences requises',
                        offer.competencesRequises.isNotEmpty
                            ? offer.competencesRequises
                                  .map((c) => '• $c')
                                  .join('\n')
                            : 'Non spécifiées',
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showApplicationDialog(offer);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueDark,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Postuler maintenant',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(String title, String location) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openGoogleMaps(location),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.blueDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.blueDark.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.blueDark,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Maps',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openGoogleMaps(String location) {
    // TODO: Implémenter l'ouverture de Google Maps avec la localisation
    // Cette méthode sera connectée au backend plus tard pour :
    // 1. Obtenir la position actuelle du candidat
    // 2. Obtenir les coordonnées précises de l'entreprise
    // 3. Ouvrir Google Maps avec les deux positions pour calculer l'itinéraire

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ouverture de Google Maps pour "$location" - Fonctionnalité à venir',
          style: GoogleFonts.roboto(),
        ),
        backgroundColor: AppColors.blueDark,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showApplicationDialog(Offre offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Candidature envoyée !',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        content: Text(
          'Votre candidature pour le poste "${offer.titre}" chez ${offer.entreprise} a été envoyée avec succès.',
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

  Widget _buildStatusBadge(String status) {
    OfferStatus offerStatus;
    switch (status.toLowerCase()) {
      case 'en cours':
      case 'active':
        offerStatus = OfferStatus.active;
        break;
      case 'en pause':
      case 'paused':
        offerStatus = OfferStatus.paused;
        break;
      case 'expirée':
      case 'expired':
        offerStatus = OfferStatus.expired;
        break;
      default:
        offerStatus = OfferStatus.active;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: OfferStatusHelper.getStatusBackgroundColor(offerStatus),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: OfferStatusHelper.getStatusColor(offerStatus),
          width: 1,
        ),
      ),
      child: Text(
        OfferStatusHelper.getStatusText(offerStatus),
        style: GoogleFonts.roboto(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: OfferStatusHelper.getStatusColor(offerStatus),
        ),
      ),
    );
  }
}
