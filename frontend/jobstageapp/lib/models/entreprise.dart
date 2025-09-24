class Entreprise {
  final String id;
  final String nom;
  final String description;
  final String secteurActivite;
  final List<String> localisations; // Changé pour supporter plusieurs villes
  final String adresse;
  final String telephone;
  final String email;
  final String siteWeb;
  final String logo;
  final String positionGoogleMaps; // Nouveau champ pour position Google Maps
  final String numeroServiceClient; // Nouveau champ pour numéro service client
  final bool isVerified;
  final DateTime dateCreation;
  final DateTime dateValidation;
  final String statutValidation; // 'en_attente', 'valide', 'rejete'
  final String administrateurId;

  Entreprise({
    required this.id,
    required this.nom,
    required this.description,
    required this.secteurActivite,
    this.localisations = const [],
    required this.adresse,
    required this.telephone,
    required this.email,
    this.siteWeb = '',
    this.logo = '',
    this.positionGoogleMaps = '',
    this.numeroServiceClient = '',
    this.isVerified = false,
    required this.dateCreation,
    required this.dateValidation,
    this.statutValidation = 'en_attente',
    required this.administrateurId,
  });

  factory Entreprise.fromJson(Map<String, dynamic> json) {
    return Entreprise(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      secteurActivite: json['secteur_activite'],
      localisations: List<String>.from(json['localisations'] ?? []),
      adresse: json['adresse'],
      telephone: json['telephone'],
      email: json['email'],
      siteWeb: json['site_web'] ?? '',
      logo: json['logo'] ?? '',
      positionGoogleMaps: json['position_google_maps'] ?? '',
      numeroServiceClient: json['numero_service_client'] ?? '',
      isVerified: json['is_verified'] ?? false,
      dateCreation: DateTime.parse(json['date_creation']),
      dateValidation: DateTime.parse(json['date_validation']),
      statutValidation: json['statut_validation'] ?? 'en_attente',
      administrateurId: json['administrateur_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'secteur_activite': secteurActivite,
      'localisations': localisations,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      'site_web': siteWeb,
      'logo': logo,
      'position_google_maps': positionGoogleMaps,
      'numero_service_client': numeroServiceClient,
      'is_verified': isVerified,
      'date_creation': dateCreation.toIso8601String(),
      'date_validation': dateValidation.toIso8601String(),
      'statut_validation': statutValidation,
      'administrateur_id': administrateurId,
    };
  }

  Entreprise copyWith({
    String? id,
    String? nom,
    String? description,
    String? secteurActivite,
    List<String>? localisations,
    String? adresse,
    String? telephone,
    String? email,
    String? siteWeb,
    String? logo,
    String? positionGoogleMaps,
    String? numeroServiceClient,
    bool? isVerified,
    DateTime? dateCreation,
    DateTime? dateValidation,
    String? statutValidation,
    String? administrateurId,
  }) {
    return Entreprise(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      secteurActivite: secteurActivite ?? this.secteurActivite,
      localisations: localisations ?? this.localisations,
      adresse: adresse ?? this.adresse,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      siteWeb: siteWeb ?? this.siteWeb,
      logo: logo ?? this.logo,
      positionGoogleMaps: positionGoogleMaps ?? this.positionGoogleMaps,
      numeroServiceClient: numeroServiceClient ?? this.numeroServiceClient,
      isVerified: isVerified ?? this.isVerified,
      dateCreation: dateCreation ?? this.dateCreation,
      dateValidation: dateValidation ?? this.dateValidation,
      statutValidation: statutValidation ?? this.statutValidation,
      administrateurId: administrateurId ?? this.administrateurId,
    );
  }
}
