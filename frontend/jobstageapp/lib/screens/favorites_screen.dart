import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard_screen.dart';
import '../services/favorite_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  String selectedTab = 'Offres';
  String selectedFilter = 'Offres';
  final List<String> tabs = ['Offres', 'Formations', 'Entreprises'];
  late AnimationController _animationController;
  late TabController _tabController;

  // Données des favoris
  List<Map<String, dynamic>> favoriteOffers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tabController = TabController(length: tabs.length, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      isLoading = true;
    });

    try {
      final favorites = await FavoriteService.getFavorites();
      setState(() {
        favoriteOffers = favorites;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur chargement favoris: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(Map<String, dynamic> offer) async {
    try {
      final success = await FavoriteService.removeFromFavorites(
        offer['offre']['id'],
      );
      if (success) {
        setState(() {
          favoriteOffers.removeWhere(
            (item) => item['offre']['id'] == offer['offre']['id'],
          );
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Succès'),
            content: Text('Offre retirée des favoris'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Erreur suppression favori: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur'),
          content: Text('Erreur lors de la suppression'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Date inconnue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          'Favoris',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: AppColors.blueDark,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  selectedTab = tabs[index];
                });
              },
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              labelStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
          // Contenu
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOffersTab(),
                _buildTrainingsTab(),
                _buildCompaniesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersTab() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blueDark),
      );
    }

    if (favoriteOffers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun favori',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des offres à vos favoris',
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: favoriteOffers.length,
      itemBuilder: (context, index) {
        final favorite = favoriteOffers[index];
        final offer = favorite['offre'];
        return _buildOfferCard(offer, favorite);
      },
    );
  }

  Widget _buildOfferCard(
    Map<String, dynamic> offer,
    Map<String, dynamic> favorite,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigation vers les détails de l'offre
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer['titre'] ?? 'Titre non disponible',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            offer['entreprise']['nom'] ?? 'Entreprise inconnue',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: AppColors.blueDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.secondaryText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                offer['localisation'] ??
                                    'Localisation non spécifiée',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.work,
                                size: 16,
                                color: AppColors.secondaryText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                offer['type_contrat'] ?? 'Type non spécifié',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bouton de suppression des favoris
                    GestureDetector(
                      onTap: () => _removeFromFavorites(favorite),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (offer['description'] != null)
                  Text(
                    offer['description'],
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (offer['salaire_min'] != null &&
                        offer['salaire_max'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greenDark.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${offer['salaire_min']} - ${offer['salaire_max']} FCFA',
                          style: GoogleFonts.roboto(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greenDark,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      'Ajouté le ${_formatDate(favorite['date_ajout'])}',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                      ),
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

  Widget _buildTrainingsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Formations bientôt disponibles',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette fonctionnalité sera ajoutée prochainement',
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCompaniesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Entreprises bientôt disponibles',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette fonctionnalité sera ajoutée prochainement',
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
