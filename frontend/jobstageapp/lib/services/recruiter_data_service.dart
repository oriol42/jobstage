import '../models/entreprise.dart';
import '../models/offre.dart';
import '../models/candidature.dart';
import '../models/candidat.dart';
import '../models/notification.dart';

class RecruiterDataService {
  static final RecruiterDataService _instance =
      RecruiterDataService._internal();
  factory RecruiterDataService() => _instance;
  RecruiterDataService._internal();

  // Données en mémoire pour la démonstration
  final List<Entreprise> _entreprises = [
    Entreprise(
      id: '1',
      nom: 'TechCorp Cameroun',
      description:
          'Entreprise spécialisée dans le développement de solutions technologiques innovantes pour le marché camerounais et africain. Nous développons des applications mobiles, des solutions web et des systèmes de gestion d\'entreprise.',
      secteurActivite: 'Technologie de l\'information',
      localisations: ['Yaoundé', 'Douala', 'Bafoussam'],
      adresse: 'Bastos, Yaoundé - Cameroun',
      telephone: '+237 6XX XX XX XX',
      email: 'contact@techcorp.cm',
      siteWeb: 'www.techcorp.cm',
      logo: 'assets/logos/techcorp.png',
      positionGoogleMaps: 'https://maps.google.com/?q=Bastos+Yaoundé+Cameroun',
      numeroServiceClient: '+237 6XX XX XX XX',
      isVerified: true,
      dateCreation: DateTime.now().subtract(const Duration(days: 30)),
      dateValidation: DateTime.now().subtract(const Duration(days: 25)),
      statutValidation: 'valide',
      administrateurId: 'admin1',
    ),
  ];

  final List<Offre> _offres = [
    Offre(
      id: '1',
      entrepriseId: '1',
      titre: 'Développeur Flutter Senior',
      description:
          'Nous recherchons un développeur Flutter expérimenté pour rejoindre notre équipe de développement mobile.',
      secteurActivite: 'Technologie',
      competencesRequises: ['Flutter', 'Dart', 'Firebase', 'Git', 'API REST'],
      localisation: 'Yaoundé',
      typeContrat: 'CDI',
      niveauEtudes: 'Bac+5',
      experienceRequise: 3,
      datePublication: DateTime.now().subtract(const Duration(hours: 1)),
      dateExpiration: DateTime.now().add(const Duration(days: 30)),
      statut: 'active',
      nombreCandidats: 12,
      nombreCandidatures: 8,
      avantages: [
        'Assurance santé',
        'Formation continue',
        'Télétravail partiel',
      ],
      processusRecrutement: 'Entretien technique + Entretien RH',
      contactEmail: 'recrutement@techcorp.cm',
      contactTelephone: '+237 6XX XX XX XX',
      entreprise: 'TechCorp Cameroun',
      lieu: 'Yaoundé',
      salaire: '800 000 - 1 200 000 FCFA',
      niveauExperience: 'Expérimenté',
    ),
    Offre(
      id: '2',
      entrepriseId: '1',
      titre: 'Stage Marketing Digital',
      description:
          'Stage de 6 mois en marketing digital pour un étudiant motivé.',
      secteurActivite: 'Marketing',
      competencesRequises: [
        'Marketing Digital',
        'Social Media',
        'Google Ads',
        'Analytics',
      ],
      localisation: 'Douala',
      typeContrat: 'Stage',
      typeStage: 'Stage long',
      dureeMois: 6,
      niveauEtudes: 'Bac+3',
      experienceRequise: 0,
      datePublication: DateTime.now().subtract(const Duration(hours: 5)),
      dateExpiration: DateTime.now().add(const Duration(days: 45)),
      statut: 'active',
      nombreCandidats: 8,
      nombreCandidatures: 5,
      avantages: ['Indemnité de stage', 'Formation', 'Encadrement'],
      processusRecrutement: 'CV + Lettre de motivation + Entretien',
      contactEmail: 'stage@techcorp.cm',
      contactTelephone: '+237 6XX XX XX XX',
      entreprise: 'TechCorp Cameroun',
      lieu: 'Douala',
      salaire: '150 000 - 250 000 FCFA',
      niveauExperience: 'Débutant',
    ),
  ];

  final List<Candidat> _candidats = [
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

  final List<Candidature> _candidatures = [
    Candidature(
      id: '1',
      candidatId: '1',
      offreId: '1',
      cvPath: 'assets/cvs/marie_kouam.pdf',
      lettreMotivationPath: 'assets/lettres/marie_kouam.pdf',
      dateCandidature: DateTime.now().subtract(const Duration(hours: 2)),
      statut: 'envoyee',
      scoreMatching: 96.0,
    ),
    Candidature(
      id: '2',
      candidatId: '2',
      offreId: '1',
      cvPath: 'assets/cvs/jean_mbarga.pdf',
      lettreMotivationPath: 'assets/lettres/jean_mbarga.pdf',
      dateCandidature: DateTime.now().subtract(const Duration(hours: 4)),
      statut: 'vue',
      scoreMatching: 92.0,
    ),
    Candidature(
      id: '3',
      candidatId: '3',
      offreId: '2',
      cvPath: 'assets/cvs/claire_ndam.pdf',
      lettreMotivationPath: 'assets/lettres/claire_ndam.pdf',
      dateCandidature: DateTime.now().subtract(const Duration(hours: 1)),
      statut: 'envoyee',
      scoreMatching: 89.0,
    ),
  ];

  final List<NotificationModel> _notifications = [
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

  // Getters pour les données
  List<Entreprise> get entreprises => _entreprises;
  List<Offre> get offres => _offres;
  List<Candidat> get candidats => _candidats;
  List<Candidature> get candidatures => _candidatures;
  List<NotificationModel> get notifications => _notifications;

  // Méthodes pour récupérer les données
  Entreprise? getEntrepriseById(String id) {
    try {
      return _entreprises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Offre> getOffresByEntreprise(String entrepriseId) {
    return _offres.where((o) => o.entrepriseId == entrepriseId).toList();
  }

  List<Candidature> getCandidaturesByOffre(String offreId) {
    return _candidatures.where((c) => c.offreId == offreId).toList();
  }

  List<Candidat> getCandidatsRecommandes(String offreId) {
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

  List<NotificationModel> getNotificationsByDestinataire(
    String destinataireId,
  ) {
    return _notifications
        .where((n) => n.destinataireId == destinataireId)
        .toList()
      ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  }

  int getNombreNotificationsNonLues(String destinataireId) {
    return _notifications
        .where((n) => n.destinataireId == destinataireId && !n.isLue)
        .length;
  }

  // Méthodes pour modifier les données
  void ajouterOffre(Offre offre) {
    _offres.add(offre);
  }

  void addOffre(Offre offre) {
    _offres.add(offre);
  }

  void modifierOffre(Offre offre) {
    final index = _offres.indexWhere((o) => o.id == offre.id);
    if (index != -1) {
      _offres[index] = offre;
    }
  }

  void supprimerOffre(String offreId) {
    _offres.removeWhere((o) => o.id == offreId);
  }

  void modifierStatutCandidature(String candidatureId, String nouveauStatut) {
    final index = _candidatures.indexWhere((c) => c.id == candidatureId);
    if (index != -1) {
      _candidatures[index] = _candidatures[index].copyWith(
        statut: nouveauStatut,
        dateVue: nouveauStatut != 'envoyee' ? DateTime.now() : null,
      );
    }
  }

  void marquerNotificationCommeLue(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isLue: true);
    }
  }

  // Statistiques
  Map<String, int> getStatistiquesEntreprise(String entrepriseId) {
    final offresEntreprise = getOffresByEntreprise(entrepriseId);
    final offresActives = offresEntreprise.where((o) => o.isActive).length;
    final totalCandidats = offresEntreprise.fold(
      0,
      (sum, o) => sum + o.nombreCandidats,
    );
    final totalCandidatures = offresEntreprise.fold(
      0,
      (sum, o) => sum + o.nombreCandidatures,
    );

    return {
      'offres_actives': offresActives,
      'candidats': totalCandidats,
      'candidatures': totalCandidatures,
    };
  }
}
