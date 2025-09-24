import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import '../../../services/favorite_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await FavoriteService.getFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur chargement favoris: $e');
      setState(() {
        _favorites = [];
        _isLoading = false;
      });
    }
  }

  void _removeFavorite(Map<String, dynamic> favorite) async {
    try {
      final success = await FavoriteService.removeFromFavorites(
        favorite['offre']['id'],
      );
      if (success) {
        setState(() {
          _favorites.removeWhere(
            (item) => item['offre']['id'] == favorite['offre']['id'],
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
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      appBar: AppBar(
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'Favoris',
          style: RecruiterTheme.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: RecruiterTheme.primaryColor,
              ),
            )
          : _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun favori',
                    style: RecruiterTheme.titleLarge.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des offres à vos favoris',
                    style: RecruiterTheme.bodyMedium.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final favorite = _favorites[index];
                final offer = favorite['offre'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Navigation vers les détails de l'offre
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: RecruiterTheme.primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.work,
                                    color: RecruiterTheme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        offer['titre'] ??
                                            'Titre non disponible',
                                        style: RecruiterTheme.titleMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        offer['entreprise']['nom'] ??
                                            'Entreprise inconnue',
                                        style: RecruiterTheme.bodyMedium.copyWith(
                                          color: RecruiterTheme
                                              .customColors['text_secondary'],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        offer['localisation'] ??
                                            'Localisation non spécifiée',
                                        style: RecruiterTheme.bodySmall.copyWith(
                                          color: RecruiterTheme
                                              .customColors['text_secondary'],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          _removeFavorite(favorite),
                                      icon: const Icon(Icons.favorite),
                                      color: Colors.red,
                                      iconSize: 20,
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (offer['description'] != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                offer['description'],
                                style: RecruiterTheme.bodySmall.copyWith(
                                  color: RecruiterTheme
                                      .customColors['text_secondary'],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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
                                      color: RecruiterTheme.primaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${offer['salaire_min']} - ${offer['salaire_max']} FCFA',
                                      style: RecruiterTheme.bodySmall.copyWith(
                                        color: RecruiterTheme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                Text(
                                  'Ajouté le ${_formatDate(favorite['date_ajout'])}',
                                  style: RecruiterTheme.bodySmall.copyWith(
                                    color: RecruiterTheme
                                        .customColors['text_secondary'],
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
              },
            ),
    );
  }
}
