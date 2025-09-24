import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String jobsUrl = 'http://10.0.2.2:8000/api/jobs';
  static const String authUrl = 'http://10.0.2.2:8000/api/auth';

  static String? _token;

  // Initialiser le token depuis le stockage local
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    // Si pas de token dans le stockage, essayer de le récupérer depuis AuthService
    if (_token == null) {
      final authService = AuthService();
      await authService.initialize();
      _token = authService.token;
    }
  }

  // Sauvegarder le token
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Supprimer le token
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Headers avec authentification
  static Map<String, String> get _headers {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    // Récupérer le token depuis le stockage local
    if (_token != null) {
      headers['Authorization'] = 'Token $_token';
      print('🔑 Token ajouté aux headers: ${_token!.substring(0, 10)}...');
    } else {
      print('⚠️ Aucun token disponible pour l\'authentification');
    }
    return headers;
  }

  // Gestion des erreurs HTTP avec détails
  static void _handleHttpError(http.Response response) {
    String errorMessage = 'Erreur inconnue';
    String errorDetails = '';

    try {
      // Essayer de parser la réponse JSON pour obtenir les détails
      final errorData = json.decode(response.body);
      if (errorData is Map<String, dynamic>) {
        // Récupérer le message d'erreur principal
        if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'].toString();
        } else if (errorData.containsKey('message')) {
          errorMessage = errorData['message'].toString();
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'].toString();
        }

        // Récupérer les détails des erreurs de validation
        if (errorData.containsKey('errors')) {
          final errors = errorData['errors'];
          if (errors is Map<String, dynamic>) {
            final errorList = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorList.add('$key: ${value.join(', ')}');
              } else {
                errorList.add('$key: $value');
              }
            });
            errorDetails = errorList.join('\n');
          }
        }
      }
    } catch (e) {
      // Si on ne peut pas parser le JSON, utiliser le body brut
      errorDetails = response.body;
    }

    // Construire le message d'erreur final
    String finalMessage = errorMessage;
    if (errorDetails.isNotEmpty) {
      finalMessage += '\n\nDétails:\n$errorDetails';
    }

    switch (response.statusCode) {
      case 400:
        throw Exception('Requête invalide (400)\n$finalMessage');
      case 401:
        throw Exception('Non autorisé (401)\n$finalMessage');
      case 403:
        throw Exception('Accès interdit (403)\n$finalMessage');
      case 404:
        throw Exception('Ressource non trouvée (404)\n$finalMessage');
      case 500:
        throw Exception('Erreur serveur (500)\n$finalMessage');
      default:
        throw Exception('Erreur ${response.statusCode}\n$finalMessage');
    }
  }

  // ========== AUTHENTIFICATION ==========

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$authUrl/login/'),
      headers: _headers,
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      _handleHttpError(response);
      return {};
    }
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
  ) async {
    final response = await http.post(
      Uri.parse('$authUrl/register/'),
      headers: _headers,
      body: json.encode(userData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      _handleHttpError(response);
      return {};
    }
  }

  // ========== OFFRES ==========

  // Récupérer toutes les offres (endpoint public)
  static Future<List<Map<String, dynamic>>> getOffres({
    String? search,
    String? typeContrat,
    String? niveauExperience,
    String? localisation,
    int? salaireMin,
    int? salaireMax,
  }) async {
    String url = '$jobsUrl/offres/public/';
    print('🔍 getOffres - URL: $url');
    print('🔍 getOffres - baseUrl: $baseUrl');
    List<String> params = [];

    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (typeContrat != null) params.add('type_contrat=$typeContrat');
    if (niveauExperience != null) {
      params.add('niveau_experience=$niveauExperience');
    }
    if (localisation != null) params.add('localisation=$localisation');
    if (salaireMin != null) params.add('salaire_min=$salaireMin');
    if (salaireMax != null) params.add('salaire_max=$salaireMax');

    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final response = await http.get(Uri.parse(url), headers: _headers);

    print('🔍 getOffres - Status: ${response.statusCode}');
    print('🔍 getOffres - Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('🔍 getOffres - Data: $data');
      print('🔍 getOffres - Results: ${data['results']}');

      if (data['results'] != null) {
        return List<Map<String, dynamic>>.from(data['results']);
      } else if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('❌ getOffres - Format de données inattendu: $data');
        return [];
      }
    } else {
      _handleHttpError(response);
      return [];
    }
  }

  // Récupérer une offre par ID
  static Future<Map<String, dynamic>?> getOffre(int id) async {
    final response = await http.get(
      Uri.parse('$jobsUrl/offres/$id/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      _handleHttpError(response);
      return null;
    }
  }

  // Créer une nouvelle offre avec capture d'erreurs détaillée
  static Future<Map<String, dynamic>?> createOffre(
    Map<String, dynamic> offreData,
  ) async {
    try {
      print('🌐 Envoi de la requête POST vers: $jobsUrl/offres/');
      print('📤 Headers: $_headers');
      print('📦 Données: ${json.encode(offreData)}');

      // Vérifier la connectivité d'abord
      try {
        final connectivityTest = await http
            .get(
              Uri.parse('$baseUrl/jobs/offres/public/'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(Duration(seconds: 5));
        print(
          '✅ Test de connectivité réussi - Status: ${connectivityTest.statusCode}',
        );
      } catch (e) {
        print('❌ Problème de connectivité: $e');
        throw Exception(
          'Impossible de se connecter au serveur. Vérifiez votre connexion internet et que le serveur est démarré.',
        );
      }

      // Vérifier l'authentification
      if (_token == null) {
        print('❌ Aucun token d\'authentification trouvé');
        throw Exception(
          'Vous n\'êtes pas connecté. Veuillez vous reconnecter.',
        );
      }

      final response = await http
          .post(
            Uri.parse('$jobsUrl/offres/'),
            headers: _headers,
            body: json.encode(offreData),
          )
          .timeout(Duration(seconds: 30));

      print('📥 Réponse reçue:');
      print('   - Status: ${response.statusCode}');
      print('   - Headers: ${response.headers}');
      print('   - Body: ${response.body}');

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        print('✅ Offre créée avec succès: $result');
        return result;
      } else {
        print('❌ Erreur HTTP ${response.statusCode}: ${response.body}');

        // Capturer les détails de l'erreur
        String errorMessage = 'Erreur lors de la création de l\'offre';
        String errorDetails = '';

        try {
          final errorData = json.decode(response.body);
          if (errorData is Map<String, dynamic>) {
            if (errorData.containsKey('detail')) {
              errorMessage = errorData['detail'].toString();
            } else if (errorData.containsKey('message')) {
              errorMessage = errorData['message'].toString();
            }

            // Capturer les erreurs de validation
            if (errorData.containsKey('errors')) {
              final errors = errorData['errors'];
              if (errors is Map<String, dynamic>) {
                final errorList = <String>[];
                errors.forEach((key, value) {
                  if (value is List) {
                    errorList.add('$key: ${value.join(', ')}');
                  } else {
                    errorList.add('$key: $value');
                  }
                });
                errorDetails = errorList.join('\n');
              }
            }
          }
        } catch (e) {
          errorDetails = response.body;
        }

        final fullErrorMessage =
            errorMessage +
            (errorDetails.isNotEmpty ? '\n\nDétails:\n$errorDetails' : '');
        throw Exception(fullErrorMessage);
      }
    } catch (e, stackTrace) {
      print('❌ Exception lors de la création d\'offre:');
      print('   Erreur: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Modifier une offre
  static Future<Map<String, dynamic>?> updateOffre(
    int id,
    Map<String, dynamic> offreData,
  ) async {
    final response = await http.put(
      Uri.parse('$jobsUrl/offres/$id/'),
      headers: _headers,
      body: json.encode(offreData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleHttpError(response);
      return null;
    }
  }

  // Supprimer une offre
  static Future<bool> deleteOffre(int id) async {
    final response = await http.delete(
      Uri.parse('$jobsUrl/offres/$id/'),
      headers: _headers,
    );

    return response.statusCode == 204;
  }

  // Récupérer les offres d'un recruteur
  static Future<List<Map<String, dynamic>>> getOffresRecruteur() async {
    final response = await http.get(
      Uri.parse('$jobsUrl/recruteur/offres/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results'] ?? data);
    } else {
      _handleHttpError(response);
      return [];
    }
  }

  // Récupérer les offres recommandées
  static Future<List<Map<String, dynamic>>> getOffresRecommandees() async {
    final response = await http.get(
      Uri.parse('$jobsUrl/offres/recommandees/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      _handleHttpError(response);
      return [];
    }
  }

  // ========== CANDIDATS ==========

  // Récupérer les candidats
  static Future<List<Map<String, dynamic>>> getCandidats() async {
    try {
      final response = await http
          .get(Uri.parse('$authUrl/candidats/'), headers: _headers)
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 getCandidats - Data: $data');

        if (data['results'] != null) {
          return List<Map<String, dynamic>>.from(data['results']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          print('❌ getCandidats - Format de données inattendu: $data');
          return [];
        }
      } else {
        print('❌ getCandidats - Erreur HTTP: ${response.statusCode}');
        _handleHttpError(response);
        return [];
      }
    } catch (e) {
      print('❌ getCandidats - Exception: $e');
      return [];
    }
  }

  // ========== CANDIDATURES ==========

  // Récupérer les candidatures
  static Future<List<Map<String, dynamic>>> getCandidatures() async {
    final response = await http.get(
      Uri.parse('$jobsUrl/candidatures/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results'] ?? data);
    } else {
      _handleHttpError(response);
      return [];
    }
  }

  // Postuler à une offre
  static Future<Map<String, dynamic>?> postulerOffre(
    int offreId,
    Map<String, dynamic> candidatureData,
  ) async {
    final response = await http.post(
      Uri.parse('$jobsUrl/candidatures/'),
      headers: _headers,
      body: json.encode({'offre': offreId, ...candidatureData}),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleHttpError(response);
      return null;
    }
  }

  // ========== FAVORIS ==========

  // Récupérer les favoris
  static Future<List<Map<String, dynamic>>> getFavoris() async {
    final response = await http.get(
      Uri.parse('$jobsUrl/favoris/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results'] ?? data);
    } else {
      _handleHttpError(response);
      return [];
    }
  }

  // Ajouter/Retirer des favoris
  static Future<bool> toggleFavori(int offreId) async {
    final response = await http.post(
      Uri.parse('$jobsUrl/favoris/$offreId/'),
      headers: _headers,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ========== STATISTIQUES ==========

  // Récupérer les statistiques des offres
  static Future<Map<String, dynamic>?> getStatistiquesOffres() async {
    final response = await http.get(
      Uri.parse('$jobsUrl/recruteur/statistiques/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleHttpError(response);
      return null;
    }
  }
}
