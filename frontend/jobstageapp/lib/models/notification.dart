class NotificationModel {
  final String id;
  final String destinataireId;
  final String
  type; // 'nouvelle_candidature', 'candidat_match', 'offre_expiree', 'validation_profil'
  final String titre;
  final String message;
  final DateTime dateCreation;
  final bool isLue;
  final Map<String, dynamic> donnees;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.destinataireId,
    required this.type,
    required this.titre,
    required this.message,
    required this.dateCreation,
    this.isLue = false,
    this.donnees = const {},
    this.actionUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      destinataireId: json['destinataire_id'],
      type: json['type'],
      titre: json['titre'],
      message: json['message'],
      dateCreation: DateTime.parse(json['date_creation']),
      isLue: json['is_lue'] ?? false,
      donnees: Map<String, dynamic>.from(json['donnees'] ?? {}),
      actionUrl: json['action_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinataire_id': destinataireId,
      'type': type,
      'titre': titre,
      'message': message,
      'date_creation': dateCreation.toIso8601String(),
      'is_lue': isLue,
      'donnees': donnees,
      'action_url': actionUrl,
    };
  }

  String get tempsEcoule {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(dateCreation);

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

  NotificationModel copyWith({
    String? id,
    String? destinataireId,
    String? type,
    String? titre,
    String? message,
    DateTime? dateCreation,
    bool? isLue,
    Map<String, dynamic>? donnees,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      destinataireId: destinataireId ?? this.destinataireId,
      type: type ?? this.type,
      titre: titre ?? this.titre,
      message: message ?? this.message,
      dateCreation: dateCreation ?? this.dateCreation,
      isLue: isLue ?? this.isLue,
      donnees: donnees ?? this.donnees,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}
