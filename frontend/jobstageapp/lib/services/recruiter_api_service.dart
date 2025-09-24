import '../models/offre.dart';
import '../models/candidature.dart';
import '../models/candidat.dart';
import '../models/notification.dart';
import 'api_service.dart';

class RecruiterApiService {
  static final RecruiterApiService _instance = RecruiterApiService._internal();
  factory RecruiterApiService() => _instance;
  RecruiterApiService._internal();

  // Cache local pour les données
  List<Offre> _offres = [];
  List<Candidature> _candidatures = [];
  List<Candidat> _candidats = [];
  List<NotificationModel> _notifications = [];

  // Données d'entreprise par défaut
  late Map<String, dynamic> _entreprise;

  // Getters
  List<Offre> get offres => _offres;
  List<Candidature> get candidatures => _candidatures;
  List<Candidat> get candidats => _candidats;
  List<NotificationModel> get notifications => _notifications;

  Future<void> loadData() async {
    await _loadOffres();
    await _loadCandidatures();
    await _loadCandidats();
    await _loadNotifications();
  }

  Map<String, dynamic> get entreprise => _entreprise;

  // Initialiser le service
  Future<void> initialize() async {
    await ApiService.initialize();

    // Initialiser les données d'entreprise par défaut
    _entreprise = {
      'id': '1',
      'nom': 'TechCorp Cameroun',
      'email': 'contact@techcorp.cm',
      'telephone': '+237 6XX XX XX XX',
    };

    await _loadOffres();
    await _loadCandidatures();
    await _loadCandidats();
    await _loadNotifications();
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
      final offresData = await ApiService.getOffresRecruteur();
      _offres = offresData.map((data) => _mapToOffre(data)).toList();
    } catch (e) {
      print('Erreur lors du chargement des offres: $e');
      _offres = [];
    }
  }

  Offre _mapToOffre(Map<String, dynamic> data) {
    return Offre(
      id: data['id'].toString(),
      entrepriseId: data['entreprise']['id'].toString(),
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
      niveauEtudes: data['niveau_etudes'] ?? '',
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
      entreprise: data['entreprise']['nom'] ?? '',
      lieu: data['localisation'] ?? '',
      salaire: data['salaire_text'] ?? data['salaire_display'] ?? '',
      niveauExperience: data['niveau_experience'] ?? '',
      isActive: data['is_active'] ?? true,
    );
  }

  Future<List<Offre>> getOffresByEntreprise(String entrepriseId) async {
    await _loadOffres();
    return _offres.where((o) => o.entrepriseId == entrepriseId).toList();
  }

  Future<void> addOffre(Offre offre) async {
    try {
      final offreData = {
        'titre': offre.titre,
        'description': offre.description,
        'secteur_activite': offre.secteurActivite,
        'competences_requises': offre.competencesRequises,
        'localisation': offre.localisation,
        'type_contrat': offre.typeContrat,
        'type_stage': offre.typeStage,
        'duree_mois': offre.dureeMois,
        'salaire_min': offre.salaireMin,
        'salaire_max': offre.salaireMax,
        'niveau_etudes': offre.niveauEtudes,
        'niveau_experience': offre.niveauExperience,
        'experience_requise': offre.experienceRequise,
        'date_expiration': offre.dateExpiration.toIso8601String(),
        'salaire_text': offre.salaire,
        'contact_email': offre.contactEmail,
        'contact_telephone': offre.contactTelephone,
        'is_active': offre.isActive,
        'avantages': offre.avantages,
        'processus_recrutement': offre.processusRecrutement,
      };

      final result = await ApiService.createOffre(offreData);
      if (result != null) {
        await _loadOffres(); // Recharger les offres
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'offre: $e');
      rethrow;
    }
  }

  Future<void> modifierOffre(Offre offre) async {
    try {
      final offreData = {
        'titre': offre.titre,
        'description': offre.description,
        'secteur_activite': offre.secteurActivite,
        'competences_requises': offre.competencesRequises,
        'localisation': offre.localisation,
        'type_contrat': offre.typeContrat,
        'type_stage': offre.typeStage,
        'duree_mois': offre.dureeMois,
        'salaire_min': offre.salaireMin,
        'salaire_max': offre.salaireMax,
        'niveau_etudes': offre.niveauEtudes,
        'niveau_experience': offre.niveauExperience,
        'experience_requise': offre.experienceRequise,
        'date_expiration': offre.dateExpiration.toIso8601String(),
        'salaire_text': offre.salaire,
        'contact_email': offre.contactEmail,
        'contact_telephone': offre.contactTelephone,
        'is_active': offre.isActive,
        'avantages': offre.avantages,
        'processus_recrutement': offre.processusRecrutement,
      };

      final result = await ApiService.updateOffre(
        int.parse(offre.id),
        offreData,
      );
      if (result != null) {
        await _loadOffres(); // Recharger les offres
      }
    } catch (e) {
      print('Erreur lors de la modification de l\'offre: $e');
      rethrow;
    }
  }

  Future<void> supprimerOffre(String offreId) async {
    try {
      final success = await ApiService.deleteOffre(int.parse(offreId));
      if (success) {
        await _loadOffres(); // Recharger les offres
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'offre: $e');
      rethrow;
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

  Future<List<Candidature>> getCandidaturesByOffre(String offreId) async {
    await _loadCandidatures();
    return _candidatures.where((c) => c.offreId == offreId).toList();
  }

  Future<void> modifierStatutCandidature(
    String candidatureId,
    String nouveauStatut,
  ) async {
    try {
      // Ici, vous pourriez appeler une API pour modifier le statut
      // Pour l'instant, on met à jour localement
      final index = _candidatures.indexWhere((c) => c.id == candidatureId);
      if (index != -1) {
        _candidatures[index] = _candidatures[index].copyWith(
          statut: nouveauStatut,
          dateVue: nouveauStatut != 'envoyee' ? DateTime.now() : null,
        );
      }
    } catch (e) {
      print('Erreur lors de la modification du statut: $e');
      rethrow;
    }
  }

  // ========== CANDIDATS ==========

  Future<void> _loadCandidats() async {
    try {
      print('🔄 Chargement des candidats depuis l\'API...');

      // Charger les candidats depuis l'API
      final candidatsData = await ApiService.getCandidats();
      _candidats = candidatsData.map((data) => _mapToCandidat(data)).toList();

      print('✅ ${_candidats.length} candidats chargés depuis l\'API');

      // Données de fallback si l'API ne retourne rien
      if (_candidats.isEmpty) {
        print(
          '⚠️ Aucun candidat trouvé, utilisation des données de démonstration',
        );
        _candidats = [
          Candidat(
            id: '1',
            nom: 'Kouam',
            prenom: 'Marie',
            email: 'marie.kouam@email.com',
            telephone: '+237 6XX XX XX XX',
            localisation: 'Yaoundé',
            domaineEtude: 'Informatique',
            niveauEtude: 'Bac+5',
            anneeDiplome: 2022,
            universite: 'Université de Yaoundé I',
            competences: [
              'Flutter',
              'Dart',
              'Firebase',
              'Git',
              'API REST',
              'JavaScript',
            ],
            experiences: [
              'Développeur Mobile - 2 ans',
              'Stagiaire Développement - 6 mois',
            ],
            cvPath: 'assets/cvs/marie_kouam.pdf',
            lettreMotivationPath: 'assets/lettres/marie_kouam.pdf',
            dateInscription: DateTime.now().subtract(const Duration(days: 15)),
            scoreMatching: 96.0,
          ),
          Candidat(
            id: '2',
            nom: 'Mbarga',
            prenom: 'Jean',
            email: 'jean.mbarga@email.com',
            telephone: '+237 6XX XX XX XX',
            localisation: 'Douala',
            domaineEtude: 'Informatique',
            niveauEtude: 'Bac+3',
            anneeDiplome: 2023,
            universite: 'Université de Douala',
            competences: [
              'Flutter',
              'React Native',
              'JavaScript',
              'Node.js',
              'MongoDB',
            ],
            experiences: ['Développeur Mobile - 1 an', 'Projets personnels'],
            cvPath: 'assets/cvs/jean_mbarga.pdf',
            lettreMotivationPath: 'assets/lettres/jean_mbarga.pdf',
            dateInscription: DateTime.now().subtract(const Duration(days: 10)),
            scoreMatching: 92.0,
          ),
          Candidat(
            id: '3',
            nom: 'Ndam',
            prenom: 'Claire',
            email: 'claire.ndam@email.com',
            telephone: '+237 6XX XX XX XX',
            localisation: 'Bafoussam',
            domaineEtude: 'Marketing',
            niveauEtude: 'Bac+5',
            anneeDiplome: 2024,
            universite: 'Université de Bafoussam',
            competences: [
              'Marketing Digital',
              'Social Media',
              'Google Ads',
              'Analytics',
              'Content Creation',
            ],
            experiences: ['Stagiaire Marketing - 3 mois'],
            cvPath: 'assets/cvs/claire_ndam.pdf',
            lettreMotivationPath: 'assets/lettres/claire_ndam.pdf',
            dateInscription: DateTime.now().subtract(const Duration(days: 5)),
            scoreMatching: 89.0,
          ),
        ];
      }
    } catch (e) {
      print('Erreur lors du chargement des candidats: $e');
      _candidats = [];
    }
  }

  Candidat _mapToCandidat(Map<String, dynamic> data) {
    return Candidat(
      id: data['id'].toString(),
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
      localisation: data['localisation'] ?? '',
      domaineEtude: data['domaine_etude'] ?? '',
      niveauEtude: data['niveau_etude'] ?? '',
      anneeDiplome: data['annee_diplome'] ?? DateTime.now().year,
      universite: data['universite'] ?? '',
      competences: List<String>.from(data['competences'] ?? []),
      experiences: List<String>.from(data['experiences'] ?? []),
      cvPath: data['cv_path'] ?? '',
      lettreMotivationPath: data['lettre_motivation_path'] ?? '',
      dateInscription: DateTime.parse(
        data['date_inscription'] ?? DateTime.now().toIso8601String(),
      ),
      isActif: data['is_actif'] ?? true,
      disponible: data['disponible'] ?? true,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      scoreMatching: (data['score_matching'] ?? 0.0).toDouble(),
    );
  }

  Future<List<Candidat>> getCandidatsRecommandes(String offreId) async {
    await _loadCandidats();
    final offre = _offres.firstWhere((o) => o.id == offreId);
    return _candidats
        .where(
          (c) =>
              c.domaineEtude == offre.secteurActivite ||
              c.competences.any(
                (comp) => offre.competencesRequises.contains(comp),
              ),
        )
        .toList()
      ..sort((a, b) => b.scoreMatching.compareTo(a.scoreMatching));
  }

  // ========== NOTIFICATIONS ==========

  Future<void> _loadNotifications() async {
    try {
      // Pour l'instant, on utilise des données statiques
      // Dans une vraie app, vous auriez une API pour récupérer les notifications
      _notifications = [
        NotificationModel(
          id: '1',
          destinataireId: '1',
          type: 'nouvelle_candidature',
          titre: 'Nouvelle candidature',
          message: 'Marie Kouam a postulé pour "Développeur Flutter Senior"',
          dateCreation: DateTime.now().subtract(const Duration(hours: 2)),
          actionUrl: '/candidatures/1',
        ),
        NotificationModel(
          id: '2',
          destinataireId: '1',
          type: 'candidat_match',
          titre: 'Candidat très compatible',
          message: 'Jean Mbarga correspond à 92% avec vos critères',
          dateCreation: DateTime.now().subtract(const Duration(hours: 4)),
          actionUrl: '/candidats/2',
        ),
        NotificationModel(
          id: '3',
          destinataireId: '1',
          type: 'nouvelle_candidature',
          titre: 'Nouvelle candidature',
          message: 'Claire Ndam a postulé pour "Stage Marketing Digital"',
          dateCreation: DateTime.now().subtract(const Duration(hours: 1)),
          actionUrl: '/candidatures/3',
        ),
      ];
    } catch (e) {
      print('Erreur lors du chargement des notifications: $e');
      _notifications = [];
    }
  }

  Future<List<NotificationModel>> getNotificationsByDestinataire(
    String destinataireId,
  ) async {
    await _loadNotifications();
    return _notifications
        .where((n) => n.destinataireId == destinataireId)
        .toList()
      ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  }

  Future<int> getNombreNotificationsNonLues(String destinataireId) async {
    await _loadNotifications();
    return _notifications
        .where((n) => n.destinataireId == destinataireId && !n.isLue)
        .length;
  }

  Future<void> marquerNotificationCommeLue(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isLue: true);
    }
  }

  // ========== STATISTIQUES ==========

  Future<Map<String, int>> getStatistiquesEntreprise(
    String entrepriseId,
  ) async {
    try {
      final stats = await ApiService.getStatistiquesOffres();
      if (stats != null) {
        return {
          'offres_actives': stats['offres_actives'] ?? 0,
          'candidats': stats['total_candidatures'] ?? 0,
          'candidatures': stats['total_candidatures'] ?? 0,
        };
      }
    } catch (e) {
      print('Erreur lors du chargement des statistiques: $e');
    }

    // Fallback sur les données locales
    final offresEntreprise = _offres
        .where((o) => o.entrepriseId == entrepriseId)
        .toList();
    final offresActives = offresEntreprise.where((o) => o.isActive).length;
    final totalCandidatures = offresEntreprise.fold(
      0,
      (sum, o) => sum + o.nombreCandidatures,
    );

    return {
      'offres_actives': offresActives,
      'candidats': totalCandidatures,
      'candidatures': totalCandidatures,
    };
  }
}
