import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/candidate_profile.dart';
import 'network_config.dart';

class AuthService {
  // Détection automatique de l'environnement
  static Future<String> get baseUrl async => await NetworkConfig.getBaseUrl();

  // URL de test hardcodée pour débogage (dépréciée, utiliser baseUrl)
  static Future<String> get testBaseUrl async =>
      await NetworkConfig.getBaseUrl();

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  User? _currentUser;

  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null && _currentUser != null;

  // Initialize auth service with stored data
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(tokenKey);
    final userData = prefs.getString(userKey);

    if (userData != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userData));
      } catch (e) {
        print('Error parsing stored user data: $e');
        await logout();
      }
    }
  }

  // Register a new user
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
    required String userType,
    String? companyName,
    String? companySector,
    String? companyAddress,
    String? companyWebsite,
  }) async {
    try {
      final baseUrl = await AuthService.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirm': passwordConfirm,
          'user_type': userType,
          if (companyName != null) 'company_name': companyName,
          if (companySector != null) 'company_sector': companySector,
          if (companyAddress != null) 'company_address': companyAddress,
          if (companyWebsite != null) 'company_website': companyWebsite,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Registration successful
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);

        // Store token and user data
        final prefs = await SharedPreferences.getInstance();
        if (_token != null) {
          await prefs.setString(tokenKey, _token!);
        }
        await prefs.setString(userKey, jsonEncode(data['user']));

        return {
          'success': true,
          'message': data['message'],
          'user': _currentUser,
        };
      } else {
        // Registration failed - Parse specific error messages
        String errorMessage = 'Erreur lors de l\'inscription';

        if (data.containsKey('email') && data['email'] is List) {
          if (data['email'].contains(
            'Un utilisateur avec cet email existe déjà.',
          )) {
            errorMessage =
                'Cet email est déjà utilisé. Veuillez utiliser un autre email.';
          } else if (data['email'].contains(
            'Saisissez une adresse e-mail valide.',
          )) {
            errorMessage = 'Veuillez saisir une adresse email valide.';
          } else {
            errorMessage = data['email'][0] ?? errorMessage;
          }
        } else if (data.containsKey('username') && data['username'] is List) {
          if (data['username'].contains(
            'Un utilisateur avec ce nom d\'utilisateur existe déjà.',
          )) {
            errorMessage =
                'Ce nom d\'utilisateur est déjà utilisé. Veuillez en choisir un autre.';
          } else {
            errorMessage = data['username'][0] ?? errorMessage;
          }
        } else if (data.containsKey('phone') && data['phone'] is List) {
          errorMessage = data['phone'][0] ?? errorMessage;
        } else if (data.containsKey('password') && data['password'] is List) {
          if (data['password'].contains(
            'Ce mot de passe est trop court. Il doit contenir au moins 8 caractères.',
          )) {
            errorMessage =
                'Le mot de passe doit contenir au moins 8 caractères.';
          } else if (data['password'].contains(
            'Ce mot de passe est trop commun.',
          )) {
            errorMessage =
                'Ce mot de passe est trop commun. Veuillez en choisir un autre.';
          } else {
            errorMessage = data['password'][0] ?? errorMessage;
          }
        } else if (data.containsKey('password_confirm') &&
            data['password_confirm'] is List) {
          errorMessage = 'Les mots de passe ne correspondent pas.';
        } else if (data.containsKey('non_field_errors') &&
            data['non_field_errors'] is List) {
          errorMessage = data['non_field_errors'][0] ?? errorMessage;
        } else if (data.containsKey('message')) {
          errorMessage = data['message'];
        }

        return {'success': false, 'message': errorMessage, 'errors': data};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final baseUrl = await AuthService.baseUrl;
      final loginUrl = '$baseUrl/auth/login/';
      print('Tentative de connexion avec: $email');
      print('URL de connexion: $loginUrl');
      print('Base URL: $baseUrl');

      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': password}),
      );

      print('Réponse du serveur: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Login successful
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);

        // Store token and user data
        final prefs = await SharedPreferences.getInstance();
        if (_token != null) {
          await prefs.setString(tokenKey, _token!);
        }
        await prefs.setString(userKey, jsonEncode(data['user']));

        return {
          'success': true,
          'message': data['message'],
          'user': _currentUser,
          'user_type': data['user_type'] ?? 'candidat',
        };
      } else {
        // Login failed
        return {
          'success': false,
          'message': data['message'] ?? 'Identifiants invalides',
          'errors': data,
        };
      }
    } catch (e) {
      print('❌ Erreur de connexion réseau: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    if (_token != null) {
      try {
        final baseUrl = await AuthService.baseUrl;
        await http.post(
          Uri.parse('$baseUrl/auth/logout/'),
          headers: {
            'Authorization': 'Token $_token',
            'Content-Type': 'application/json',
          },
        );
      } catch (e) {
        print('Error during logout: $e');
      }
    }

    // Clear local data
    _token = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    if (_token == null) {
      return {'success': false, 'message': 'Non connecté'};
    }

    try {
      final baseUrl = await AuthService.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password/'),
        headers: {
          'Authorization': 'Token $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirm': newPasswordConfirm,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors du changement de mot de passe',
          'errors': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  // Méthodes pour gérer le profil candidat
  Future<Map<String, dynamic>> getProfile() async {
    if (_token == null) {
      return {'success': false, 'message': 'Non connecté'};
    }

    try {
      final baseUrl = await AuthService.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: {
          'Authorization': 'Token $_token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        User user = User.fromJson(data['user']);
        CandidateProfile? profile;
        if (data['profile'] != null) {
          profile = CandidateProfile.fromJson(data['profile']);
        }
        return {'success': true, 'user': user, 'profile': profile};
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors de la récupération du profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateUserInfo({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    if (_token == null) {
      return {'success': false, 'message': 'Non connecté'};
    }

    try {
      final baseUrl = await AuthService.baseUrl;
      Map<String, dynamic> requestData = {};
      if (firstName != null) requestData['first_name'] = firstName;
      if (lastName != null) requestData['last_name'] = lastName;
      if (phone != null) requestData['phone'] = phone;

      print('📤 Envoi des données utilisateur: $requestData');

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile/update-user/'),
        headers: {
          'Authorization': 'Token $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profil mis à jour avec succès',
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la mise à jour',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateCandidateProfile({
    String? bio,
    String? location,
    String? skills,
    String? jobTitle,
    int? experienceYears,
    double? expectedSalary,
    String? contractType,
  }) async {
    if (_token == null) {
      return {'success': false, 'message': 'Non connecté'};
    }

    final baseUrl = await AuthService.baseUrl;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile/update-candidate/'),
        headers: {
          'Authorization': 'Token $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (bio != null) 'bio': bio,
          if (location != null) 'location': location,
          if (skills != null) 'skills': skills,
          if (jobTitle != null) 'job_title': jobTitle,
          if (experienceYears != null) 'experience_years': experienceYears,
          if (expectedSalary != null) 'expected_salary': expectedSalary,
          if (contractType != null) 'contract_type': contractType,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              data['message'] ?? 'Profil candidat mis à jour avec succès',
          'profile': CandidateProfile.fromJson(data['profile']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la mise à jour',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> uploadProfilePhoto(File photoFile) async {
    if (_token == null) {
      return {'success': false, 'message': 'Non connecté'};
    }

    try {
      final baseUrl = await NetworkConfig.getBaseUrl();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/profile/upload-photo/'),
      );

      request.headers['Authorization'] = 'Token $_token';
      request.files.add(
        await http.MultipartFile.fromPath('photo', photoFile.path),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'photo_url': data['photo_url'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'upload de la photo',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> uploadCV(File cvFile) async {
    if (_token == null) {
      return {'success': false, 'message': 'Non connecté'};
    }

    try {
      final baseUrl = await NetworkConfig.getBaseUrl();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/profile/upload-cv/'),
      );

      request.headers['Authorization'] = 'Token $_token';
      request.files.add(await http.MultipartFile.fromPath('cv', cvFile.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'cv_url': data['cv_url'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'upload du CV',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateJobPreferences({
    String? preferredJobType,
    String? experienceLevel,
    int? salaryRangeMin,
    int? salaryRangeMax,
    String? preferredWorkLocation,
    bool? remoteWork,
    String? preferredIndustries,
  }) async {
    if (_token == null) {
      return {
        'success': false,
        'message': 'Token d\'authentification manquant',
      };
    }

    try {
      Map<String, dynamic> requestData = {};
      if (preferredJobType != null) {
        requestData['preferred_job_type'] = preferredJobType;
      }
      if (experienceLevel != null) {
        requestData['experience_level'] = experienceLevel;
      }
      if (salaryRangeMin != null) {
        requestData['salary_range_min'] = salaryRangeMin;
      }
      if (salaryRangeMax != null) {
        requestData['salary_range_max'] = salaryRangeMax;
      }
      if (preferredWorkLocation != null) {
        requestData['preferred_work_location'] = preferredWorkLocation;
      }
      if (remoteWork != null) requestData['remote_work'] = remoteWork;
      if (preferredIndustries != null) {
        requestData['preferred_industries'] = preferredIndustries;
      }

      print('📤 Envoi des préférences d\'emploi: $requestData');

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile/update-candidate/'),
        headers: {
          'Authorization': 'Token $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Préférences d\'emploi mises à jour avec succès',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ??
              'Erreur lors de la mise à jour des préférences',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateSkills(List<String> skills) async {
    if (_token == null) {
      return {
        'success': false,
        'message': 'Token d\'authentification manquant',
      };
    }

    try {
      // Convertir la liste en chaîne séparée par des virgules
      final skillsString = skills.join(', ');
      final requestData = {'skills': skillsString};

      print('📤 Envoi des compétences: $requestData');

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile/update-candidate/'),
        headers: {
          'Authorization': 'Token $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Compétences mises à jour avec succès',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ??
              'Erreur lors de la mise à jour des compétences',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getCVs() async {
    if (_token == null) {
      return {
        'success': false,
        'message': 'Token d\'authentification manquant',
      };
    }

    final baseUrl = await AuthService.baseUrl;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/cvs/'),
        headers: {
          'Authorization': 'Token $_token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'cvs': data['cvs'] ?? []};
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors de la récupération des CVs',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteCV(String cvId) async {
    if (_token == null) {
      return {
        'success': false,
        'message': 'Token d\'authentification manquant',
      };
    }

    final baseUrl = await AuthService.baseUrl;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/profile/cvs/$cvId/'),
        headers: {
          'Authorization': 'Token $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'CV supprimé avec succès'};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la suppression du CV',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  Future<CandidateProfile?> getCandidateProfile() async {
    if (_token == null) {
      return null;
    }

    final baseUrl = await AuthService.baseUrl;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: {
          'Authorization': 'Token $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['profile'] != null) {
          return CandidateProfile.fromJson(data['profile']);
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du profil: $e');
      return null;
    }
  }
}
