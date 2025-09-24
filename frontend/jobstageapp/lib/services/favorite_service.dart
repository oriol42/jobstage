import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FavoriteService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  /// Récupérer les favoris de l'utilisateur
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      print('⭐ Récupération des favoris...');

      final response = await http.get(
        Uri.parse('$baseUrl/jobs/favoris/'),
        headers: await _getHeaders(),
      );

      print('⭐ Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> favoritesList;

        if (data is List) {
          favoritesList = data;
        } else if (data is Map && data.containsKey('results')) {
          favoritesList = data['results'];
        } else {
          favoritesList = [];
        }

        print('✅ ${favoritesList.length} favoris récupérés');
        return favoritesList.cast<Map<String, dynamic>>();
      } else {
        print('❌ Erreur récupération favoris: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erreur récupération favoris: $e');
      return [];
    }
  }

  /// Ajouter une offre aux favoris
  static Future<bool> addToFavorites(int offreId) async {
    try {
      print('⭐ Ajout aux favoris: offre $offreId');

      final response = await http.post(
        Uri.parse('$baseUrl/jobs/favoris/'),
        headers: await _getHeaders(),
        body: json.encode({'offre': offreId}),
      );

      print('⭐ Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        print('✅ Offre ajoutée aux favoris');
        return true;
      } else {
        print('❌ Erreur ajout favori: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur ajout favori: $e');
      return false;
    }
  }

  /// Retirer une offre des favoris
  static Future<bool> removeFromFavorites(int offreId) async {
    try {
      print('⭐ Retrait des favoris: offre $offreId');

      final response = await http.delete(
        Uri.parse('$baseUrl/jobs/favoris/$offreId/'),
        headers: await _getHeaders(),
      );

      print('⭐ Status: ${response.statusCode}');

      if (response.statusCode == 204) {
        print('✅ Offre retirée des favoris');
        return true;
      } else {
        print('❌ Erreur retrait favori: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur retrait favori: $e');
      return false;
    }
  }

  /// Vérifier si une offre est dans les favoris
  static Future<bool> isFavorite(int offreId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((favorite) => favorite['offre']['id'] == offreId);
    } catch (e) {
      print('❌ Erreur vérification favori: $e');
      return false;
    }
  }

  /// Toggle favori (ajouter ou retirer)
  static Future<bool> toggleFavorite(int offreId) async {
    try {
      final isFav = await isFavorite(offreId);
      if (isFav) {
        return await removeFromFavorites(offreId);
      } else {
        return await addToFavorites(offreId);
      }
    } catch (e) {
      print('❌ Erreur toggle favori: $e');
      return false;
    }
  }

  /// Récupérer les headers d'authentification
  static Future<Map<String, String>> _getHeaders() async {
    final authService = AuthService();
    await authService.initialize();
    final token = authService.token;
    return {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };
  }
}
