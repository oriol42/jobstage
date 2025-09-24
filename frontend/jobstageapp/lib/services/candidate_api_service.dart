import '../models/offre.dart';
import '../models/candidature.dart';
import '../models/notification.dart';
import 'api_service.dart';

class CandidateApiService {
  static final CandidateApiService _instance = CandidateApiService._internal();
  factory CandidateApiService() => _instance;
  CandidateApiService._internal();

  // Cache local pour les données
  List<Offre> _offres = [];
  List<Candidature> _candidatures = [];
  List<Offre> _favoris = [];
  List<Offre> _offresRecommandees = [];

  // Getters
  List<Offre> get offres => _offres;
  List<Candidature> get candidatures => _candidatures;
  List<Offre> get favoris => _favoris;
  List<Offre> get offresRecommandees => _offresRecommandees;

  // Initialiser le service
  Future<void> initialize() async {
    await ApiService.initialize();
    await _loadOffres();
    await _loadCandidatures();
    await _loadFavoris();
    await _loadOffresRecommandees();
  }

  // ========== OFFRES ==========

  // Méthode utilitaire pour parser les doubles de manière sécurisée
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Future<void> _loadOffres() async {
    try {
      final offresData = await ApiService.getOffres();
      _offres = offresData.map((data) => _mapToOffre(data)).toList();
    } catch (e) {
      print('Erreur lors du chargement des offres: $e');
      // En cas d'erreur, garder les offres existantes ou initialiser une liste vide
      if (_offres.isEmpty) {
        _offres = [];
      }
    }
  }

  Offre _mapToOffre(Map<String, dynamic> data) {
    return Offre(
      id: data['id'].toString(),
      entrepriseId:
          data['entreprise_id']?.toString() ??
          data['entreprise']?['id']?.toString() ??
          '0',
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      secteurActivite: data['secteur_activite'] ?? '',
      competencesRequises: List<String>.from(
        data['competences_requises'] ?? [],
      ),
      localisation: data['localisation'] ?? '',
      typeContrat: data['type_contrat'] ?? '',
      typeStage: data['type_stage'] ?? '',
      dureeMois: data['duree_mois'] ?? 0,
      salaireMin: _parseDouble(data['salaire_min']) ?? 0.0,
      salaireMax: _parseDouble(data['salaire_max']) ?? 0.0,
      salaireText: data['salaire_text'] ?? '',
      niveauEtudes: data['niveau_etudes'] ?? '',
      niveauExperience: data['niveau_experience'] ?? '',
      experienceRequise: data['experience_requise'] ?? 0,
      datePublication: DateTime.parse(data['date_publication']),
      dateExpiration: DateTime.parse(data['date_expiration']),
      statut: data['statut'] ?? 'active',
      nombreCandidats: data['nombre_candidats'] ?? 0,
      nombreCandidatures: data['nombre_candidatures'] ?? 0,
      avantages: List<String>.from(data['avantages'] ?? []),
      processusRecrutement: data['processus_recrutement'] ?? '',
      contactEmail: data['contact_email'] ?? '',
      contactTelephone: data['contact_telephone'] ?? '',
      isActive: data['is_active'] ?? true,
      // Propriétés de compatibilité
      entreprise: data['entreprise_nom'] ?? data['entreprise']?['nom'] ?? '',
      lieu: data['localisation'] ?? '',
      salaire: data['salaire_text'] ?? data['salaire'] ?? '',
    );
  }

  Future<List<Offre>> getOffres({
    String? search,
    String? typeContrat,
    String? niveauExperience,
    String? localisation,
    int? salaireMin,
    int? salaireMax,
  }) async {
    try {
      final offresData = await ApiService.getOffres(
        search: search,
        typeContrat: typeContrat,
        niveauExperience: niveauExperience,
        localisation: localisation,
        salaireMin: salaireMin,
        salaireMax: salaireMax,
      );
      return offresData.map((data) => _mapToOffre(data)).toList();
    } catch (e) {
      print('Erreur lors de la recherche d\'offres: $e');
      return [];
    }
  }

  Future<Offre?> getOffre(int id) async {
    try {
      final offreData = await ApiService.getOffre(id);
      if (offreData != null) {
        return _mapToOffre(offreData);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'offre: $e');
      return null;
    }
  }

  // ========== CANDIDATURES ==========

  Future<void> _loadCandidatures() async {
    try {
      final candidaturesData = await ApiService.getCandidatures();
      _candidatures = candidaturesData
          .map((data) => _mapToCandidature(data))
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des candidatures: $e');
      _candidatures = [];
    }
  }

  Candidature _mapToCandidature(Map<String, dynamic> data) {
    return Candidature(
      id: data['id'].toString(),
      candidatId: data['candidat']['id'].toString(),
      offreId: data['offre']['id'].toString(),
      cvPath: data['cv_path'] ?? '',
      lettreMotivationPath: data['lettre_motivation_path'] ?? '',
      dateCandidature: DateTime.parse(data['date_candidature']),
      statut: data['statut'] ?? 'envoyee',
      scoreMatching: (data['score_matching'] ?? 0).toDouble(),
      dateVue: data['date_vue'] != null
          ? DateTime.parse(data['date_vue'])
          : null,
    );
  }

  Future<bool> postulerOffre(
    int offreId,
    Map<String, dynamic> candidatureData,
  ) async {
    try {
      final result = await ApiService.postulerOffre(offreId, candidatureData);
      if (result != null) {
        await _loadCandidatures(); // Recharger les candidatures
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la candidature: $e');
      return false;
    }
  }

  Future<List<Candidature>> getCandidaturesByOffre(String offreId) async {
    await _loadCandidatures();
    return _candidatures.where((c) => c.offreId == offreId).toList();
  }

  // ========== FAVORIS ==========

  Future<void> _loadFavoris() async {
    try {
      final favorisData = await ApiService.getFavoris();
      _favoris = favorisData.map((data) => _mapToOffre(data['offre'])).toList();
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
      _favoris = [];
    }
  }

  Future<bool> toggleFavori(int offreId) async {
    try {
      final success = await ApiService.toggleFavori(offreId);
      if (success) {
        await _loadFavoris(); // Recharger les favoris
      }
      return success;
    } catch (e) {
      print('Erreur lors de la gestion des favoris: $e');
      return false;
    }
  }

  Future<bool> isFavori(int offreId) async {
    await _loadFavoris();
    return _favoris.any((offre) => offre.id == offreId.toString());
  }

  // ========== OFFRES RECOMMANDÉES ==========

  Future<void> _loadOffresRecommandees() async {
    try {
      final offresData = await ApiService.getOffresRecommandees();
      _offresRecommandees = offresData
          .map((data) => _mapToOffre(data))
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des offres recommandées: $e');
      _offresRecommandees = [];
    }
  }

  // ========== RECHERCHE ET FILTRES ==========

  Future<List<Offre>> rechercherOffres({
    String? query,
    String? typeContrat,
    String? niveauExperience,
    String? localisation,
    int? salaireMin,
    int? salaireMax,
  }) async {
    return await getOffres(
      search: query,
      typeContrat: typeContrat,
      niveauExperience: niveauExperience,
      localisation: localisation,
      salaireMin: salaireMin,
      salaireMax: salaireMax,
    );
  }

  // ========== STATISTIQUES ==========

  Future<Map<String, int>> getStatistiquesCandidat() async {
    await _loadCandidatures();
    await _loadFavoris();

    return {
      'candidatures_envoyees': _candidatures.length,
      'candidatures_en_cours': _candidatures
          .where((c) => c.statut == 'en_cours')
          .length,
      'candidatures_acceptees': _candidatures
          .where((c) => c.statut == 'acceptee')
          .length,
      'offres_favorites': _favoris.length,
    };
  }

  // ========== NOTIFICATIONS ==========

  Future<List<NotificationModel>> getNotifications() async {
    // Pour l'instant, on utilise des données statiques
    // Dans une vraie app, vous auriez une API pour récupérer les notifications
    return [
      NotificationModel(
        id: '1',
        destinataireId: '1',
        type: 'nouvelle_offre',
        titre: 'Nouvelle offre',
        message: 'Une nouvelle offre correspond à votre profil',
        dateCreation: DateTime.now().subtract(const Duration(hours: 1)),
        actionUrl: '/offres/1',
      ),
      NotificationModel(
        id: '2',
        destinataireId: '1',
        type: 'candidature_acceptee',
        titre: 'Candidature acceptée',
        message: 'Votre candidature pour "Développeur Flutter" a été acceptée',
        dateCreation: DateTime.now().subtract(const Duration(hours: 3)),
        actionUrl: '/candidatures/1',
      ),
    ];
  }
}
