import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CompanyService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  /// Récupérer toutes les entreprises
  static Future<List<Map<String, dynamic>>> getCompanies() async {
    try {
      print('🏢 Récupération des entreprises...');

      final response = await http.get(
        Uri.parse('$baseUrl/accounts/entreprises/'),
        headers: await _getHeaders(),
      );

      print('🏢 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> companiesList;

        if (data is List) {
          companiesList = data;
        } else if (data is Map && data.containsKey('results')) {
          companiesList = data['results'];
        } else {
          companiesList = [];
        }

        print('✅ ${companiesList.length} entreprises récupérées');
        return companiesList.cast<Map<String, dynamic>>();
      } else {
        print('❌ Erreur récupération entreprises: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erreur récupération entreprises: $e');
      return [];
    }
  }

  /// Récupérer les détails d'une entreprise
  static Future<Map<String, dynamic>?> getCompanyDetails(int companyId) async {
    try {
      print('🏢 Récupération détails entreprise $companyId...');

      final response = await http.get(
        Uri.parse('$baseUrl/accounts/entreprises/$companyId/'),
        headers: await _getHeaders(),
      );

      print('🏢 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Détails entreprise récupérés');
        return data;
      } else {
        print(
          '❌ Erreur récupération détails entreprise: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Erreur récupération détails entreprise: $e');
      return null;
    }
  }

  /// Récupérer les offres d'une entreprise
  static Future<List<Map<String, dynamic>>> getCompanyOffers(
    int companyId,
  ) async {
    try {
      print('🏢 Récupération offres entreprise $companyId...');

      final response = await http.get(
        Uri.parse('$baseUrl/jobs/offres/entreprise/$companyId/'),
        headers: await _getHeaders(),
      );

      print('🏢 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> offersList;

        if (data is List) {
          offersList = data;
        } else if (data is Map && data.containsKey('results')) {
          offersList = data['results'];
        } else {
          offersList = [];
        }

        print('✅ ${offersList.length} offres récupérées pour l\'entreprise');
        return offersList.cast<Map<String, dynamic>>();
      } else {
        print(
          '❌ Erreur récupération offres entreprise: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Erreur récupération offres entreprise: $e');
      return [];
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
