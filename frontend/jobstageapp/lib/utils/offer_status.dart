import 'package:flutter/material.dart';

enum OfferStatus {
  active, // En cours
  paused, // En pause
  expired, // Expirée
}

class OfferStatusHelper {
  static OfferStatus getOfferStatus(Map<String, dynamic> offer) {
    // Récupérer la date d'expiration et le statut de pause
    final String expirationDate = offer['expirationDate'] ?? '';
    final bool isPaused = offer['isPaused'] ?? false;

    // Si l'offre est en pause
    if (isPaused) {
      return OfferStatus.paused;
    }

    // Si on a une date d'expiration, vérifier si elle est dépassée
    if (expirationDate.isNotEmpty) {
      final DateTime now = DateTime.now();
      final DateTime expDate = DateTime.parse(expirationDate);

      if (now.isAfter(expDate)) {
        return OfferStatus.expired;
      }
    }

    // Par défaut, l'offre est active
    return OfferStatus.active;
  }

  static String getStatusText(OfferStatus status) {
    switch (status) {
      case OfferStatus.active:
        return 'En cours';
      case OfferStatus.paused:
        return 'En pause';
      case OfferStatus.expired:
        return 'Expirée';
    }
  }

  static Color getStatusColor(OfferStatus status) {
    switch (status) {
      case OfferStatus.active:
        return const Color(0xFF4CAF50); // Vert
      case OfferStatus.paused:
        return const Color(0xFFFF9800); // Orange
      case OfferStatus.expired:
        return const Color(0xFFF44336); // Rouge
    }
  }

  static Color getStatusBackgroundColor(OfferStatus status) {
    switch (status) {
      case OfferStatus.active:
        return const Color(0xFFE8F5E8); // Vert clair
      case OfferStatus.paused:
        return const Color(0xFFFFF3E0); // Orange clair
      case OfferStatus.expired:
        return const Color(0xFFFFEBEE); // Rouge clair
    }
  }
}
