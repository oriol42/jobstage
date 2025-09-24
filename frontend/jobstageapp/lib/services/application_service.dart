import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/candidature.dart';
import 'auth_service.dart';

class ApplicationService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  /// Postuler à une offre
  static Future<Map<String, dynamic>?> applyToJob({
    required String offreId,
    String? cvPath,
    String? lettreMotivationPath,
    String? messagePersonnalise,
  }) async {
    try {
      print('📝 ApplicationService: Candidature à l\'offre $offreId');

      final authService = AuthService();
      await authService.initialize();

      if (!authService.isLoggedIn) {
        throw Exception('Utilisateur non connecté');
      }

      // Créer une requête multipart pour envoyer les fichiers
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/jobs/candidatures/'),
      );

      // Ajouter les headers d'authentification
      final headers = await _getHeaders();
      request.headers.addAll(headers);

      // Ajouter l'ID de l'offre
      request.fields['offre'] = offreId;

      // Ajouter le CV si fourni (obligatoire)
      if (cvPath != null && cvPath.isNotEmpty) {
        final cvFile = File(cvPath);
        if (await cvFile.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('cv_path', cvPath),
          );
          print('📝 CV ajouté: $cvPath');
        } else {
          print('❌ Fichier CV introuvable: $cvPath');
          return null;
        }
      } else {
        print('❌ Aucun CV fourni');
        return null;
      }

      // Ajouter la lettre de motivation si fournie (optionnelle)
      if (lettreMotivationPath != null && lettreMotivationPath.isNotEmpty) {
        final lettreFile = File(lettreMotivationPath);
        if (await lettreFile.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'lettre_motivation_path',
              lettreMotivationPath,
            ),
          );
          print('📝 Lettre de motivation ajoutée: $lettreMotivationPath');
        } else {
          print('❌ Fichier lettre introuvable: $lettreMotivationPath');
        }
      }

      print('📝 Envoi de la candidature...');
      print('📝 Offre ID: $offreId');
      print('📝 CV Path: $cvPath');
      print('📝 Lettre Path: $lettreMotivationPath');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📝 Status: ${response.statusCode}');
      print('📝 Response: $responseBody');

      if (response.statusCode == 201) {
        final data = json.decode(responseBody);
        print('✅ Candidature envoyée avec succès');
        return data;
      } else {
        print('❌ Erreur candidature: ${response.statusCode} - $responseBody');
        return null;
      }
    } catch (e) {
      print('❌ Erreur lors de la candidature: $e');
      return null;
    }
  }

  /// Récupérer les candidatures d'un candidat
  static Future<List<Candidature>> getMyApplications() async {
    try {
      print('📝 Récupération des candidatures du candidat...');

      final response = await http.get(
        Uri.parse('$baseUrl/jobs/candidatures/'),
        headers: await _getHeaders(),
      );

      print('📝 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> candidaturesList;

        if (data is List) {
          candidaturesList = data;
        } else if (data is Map && data.containsKey('results')) {
          candidaturesList = data['results'] ?? [];
        } else {
          candidaturesList = [];
        }

        final candidatures = candidaturesList
            .map((json) => Candidature.fromJson(json))
            .toList();

        print('✅ ${candidatures.length} candidatures récupérées');
        return candidatures;
      } else {
        print('❌ Erreur récupération candidatures: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des candidatures: $e');
      return [];
    }
  }

  /// Récupérer les candidatures d'un recruteur
  static Future<List<Candidature>> getRecruiterApplications() async {
    try {
      print('📝 Récupération des candidatures du recruteur...');

      final response = await http.get(
        Uri.parse('$baseUrl/jobs/candidatures/'),
        headers: await _getHeaders(),
      );

      print('📝 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> candidaturesList;

        if (data is List) {
          candidaturesList = data;
        } else if (data is Map && data.containsKey('results')) {
          candidaturesList = data['results'] ?? [];
        } else {
          candidaturesList = [];
        }

        final candidatures = candidaturesList
            .map((json) => Candidature.fromJson(json))
            .toList();

        print('✅ ${candidatures.length} candidatures récupérées');
        return candidatures;
      } else {
        print('❌ Erreur récupération candidatures: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des candidatures: $e');
      return [];
    }
  }

  /// Mettre à jour le statut d'une candidature
  static Future<bool> updateApplicationStatus({
    required String candidatureId,
    required String nouveauStatut,
    String? messageRecruteur,
  }) async {
    try {
      print('📝 Mise à jour du statut: $candidatureId -> $nouveauStatut');

      final updateData = {
        'statut': nouveauStatut,
        'date_reponse': DateTime.now().toIso8601String(),
      };

      if (messageRecruteur != null) {
        updateData['message_recruteur'] = messageRecruteur;
      }

      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json';
      
      final response = await http.patch(
        Uri.parse('$baseUrl/jobs/candidatures/$candidatureId/'),
        headers: headers,
        body: json.encode(updateData),
      );

      print('📝 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Statut mis à jour avec succès');
        return true;
      } else {
        print('❌ Erreur mise à jour statut: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du statut: $e');
      return false;
    }
  }

  /// Vérifier si un candidat a déjà postulé à une offre
  static Future<bool> hasAlreadyApplied(String offreId) async {
    try {
      final candidatures = await getMyApplications();
      return candidatures.any((c) => c.offreId == offreId);
    } catch (e) {
      print('❌ Erreur vérification candidature existante: $e');
      return false;
    }
  }

  /// Obtenir les headers avec authentification
  static Future<Map<String, String>> _getHeaders() async {
    final authService = AuthService();
    await authService.initialize();
    final token = authService.token;

    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }

    return headers;
  }
}
