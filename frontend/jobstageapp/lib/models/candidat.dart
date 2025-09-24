class Candidat {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String localisation;
  final String domaineEtude;
  final String niveauEtude;
  final int anneeDiplome;
  final String universite;
  final List<String> competences;
  final List<String> experiences;
  final String cvPath;
  final String lettreMotivationPath;
  final String photo;
  final DateTime dateInscription;
  final bool isActif;
  final bool disponible;
  final Map<String, dynamic> preferences;
  final double scoreMatching;

  Candidat({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.localisation,
    required this.domaineEtude,
    required this.niveauEtude,
    required this.anneeDiplome,
    required this.universite,
    this.competences = const [],
    this.experiences = const [],
    this.cvPath = '',
    this.lettreMotivationPath = '',
    this.photo = '',
    required this.dateInscription,
    this.isActif = true,
    this.disponible = true,
    this.preferences = const {},
    this.scoreMatching = 0.0,
  });

  factory Candidat.fromJson(Map<String, dynamic> json) {
    return Candidat(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'],
      localisation: json['localisation'],
      domaineEtude: json['domaine_etude'],
      niveauEtude: json['niveau_etude'],
      anneeDiplome: json['annee_diplome'],
      universite: json['universite'],
      competences: List<String>.from(json['competences'] ?? []),
      experiences: List<String>.from(json['experiences'] ?? []),
      cvPath: json['cv_path'] ?? '',
      lettreMotivationPath: json['lettre_motivation_path'] ?? '',
      photo: json['photo'] ?? '',
      dateInscription: DateTime.parse(json['date_inscription']),
      isActif: json['is_actif'] ?? true,
      disponible: json['disponible'] ?? true,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      scoreMatching: (json['score_matching'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'localisation': localisation,
      'domaine_etude': domaineEtude,
      'niveau_etude': niveauEtude,
      'annee_diplome': anneeDiplome,
      'universite': universite,
      'competences': competences,
      'experiences': experiences,
      'cv_path': cvPath,
      'lettre_motivation_path': lettreMotivationPath,
      'photo': photo,
      'date_inscription': dateInscription.toIso8601String(),
      'is_actif': isActif,
      'disponible': disponible,
      'preferences': preferences,
      'score_matching': scoreMatching,
    };
  }

  String get nomComplet {
    String prenomTrimmed = prenom.trim();
    String nomTrimmed = nom.trim();

    if (prenomTrimmed.isEmpty && nomTrimmed.isEmpty) {
      // Utiliser l'email si disponible, sinon "Candidat"
      return email.isNotEmpty ? email : 'Candidat';
    } else if (prenomTrimmed.isEmpty) {
      return nomTrimmed;
    } else if (nomTrimmed.isEmpty) {
      return prenomTrimmed;
    } else {
      return '$prenomTrimmed $nomTrimmed';
    }
  }

  String get niveauEtudeAffichage {
    switch (niveauEtude) {
      case 'Bac':
        return 'Baccalauréat';
      case 'Bac+2':
        return 'Bac+2 (BTS/DUT)';
      case 'Bac+3':
        return 'Bac+3 (Licence)';
      case 'Bac+5':
        return 'Bac+5 (Master)';
      case 'Doctorat':
        return 'Doctorat';
      default:
        return niveauEtude;
    }
  }

  String get experienceAffichage {
    if (experiences.isEmpty) {
      return 'Aucune expérience';
    }
    return '${experiences.length} expérience${experiences.length > 1 ? 's' : ''}';
  }

  Candidat copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? localisation,
    String? domaineEtude,
    String? niveauEtude,
    int? anneeDiplome,
    String? universite,
    List<String>? competences,
    List<String>? experiences,
    String? cvPath,
    String? lettreMotivationPath,
    String? photo,
    DateTime? dateInscription,
    bool? isActif,
    Map<String, dynamic>? preferences,
    double? scoreMatching,
  }) {
    return Candidat(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      localisation: localisation ?? this.localisation,
      domaineEtude: domaineEtude ?? this.domaineEtude,
      niveauEtude: niveauEtude ?? this.niveauEtude,
      anneeDiplome: anneeDiplome ?? this.anneeDiplome,
      universite: universite ?? this.universite,
      competences: competences ?? this.competences,
      experiences: experiences ?? this.experiences,
      cvPath: cvPath ?? this.cvPath,
      lettreMotivationPath: lettreMotivationPath ?? this.lettreMotivationPath,
      photo: photo ?? this.photo,
      dateInscription: dateInscription ?? this.dateInscription,
      isActif: isActif ?? this.isActif,
      preferences: preferences ?? this.preferences,
      scoreMatching: scoreMatching ?? this.scoreMatching,
    );
  }
}
