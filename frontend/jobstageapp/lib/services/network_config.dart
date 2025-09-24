import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkConfig {
  static String? _cachedBaseUrl;
  static DateTime? _lastCacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  /// Détecte automatiquement l'URL de base selon l'environnement
  static Future<String> getBaseUrl() async {
    // URL de développement local (qui fonctionne)
    String baseUrl = 'http://10.0.2.2:8000/api';

    print('🌐 URL de base (Développement): $baseUrl');
    return baseUrl;
  }

  /// Détecte l'URL de base pour Android
  static Future<String> _detectAndroidBaseUrl() async {
    // Liste des IPs possibles à tester (plus complète)
    final List<String> possibleIPs = [
      '192.168.1.167', // IP actuelle de l'ordinateur (priorité)
      '10.0.2.2', // Émulateur Android
      '192.168.0.100', // Autres IPs courantes
      '192.168.1.100',
      '192.168.0.167',
      '192.168.1.1', // Routeur commun
      '192.168.0.1', // Routeur commun
      '192.168.43.1', // Hotspot mobile
      '10.0.0.1', // Autre réseau privé
    ];

    // Tester chaque IP avec un timeout plus court
    for (String ip in possibleIPs) {
      try {
        final url = 'http://$ip:8000/api/auth/login/';
        print('🔍 Test de connexion à: $url');

        final response = await http
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: '{"username":"test","password":"test"}',
            )
            .timeout(const Duration(seconds: 2));

        // Si on reçoit une réponse (même une erreur), le serveur est accessible
        if (response.statusCode == 200 ||
            response.statusCode == 400 ||
            response.statusCode == 404) {
          print('✅ Serveur trouvé à: $ip');
          return 'http://$ip:8000/api';
        }
      } catch (e) {
        print('❌ Échec de connexion à $ip: $e');
        continue;
      }
    }

    // Si aucune IP ne fonctionne, essayer de détecter l'IP du réseau local
    try {
      final detectedIP = await _detectLocalIP();
      if (detectedIP != null) {
        print('🔍 Test de l\'IP détectée: $detectedIP');
        final url = 'http://$detectedIP:8000/api/auth/login/';
        final response = await http
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: '{"username":"test","password":"test"}',
            )
            .timeout(const Duration(seconds: 2));

        if (response.statusCode == 200 ||
            response.statusCode == 400 ||
            response.statusCode == 404) {
          print('✅ Serveur trouvé à l\'IP détectée: $detectedIP');
          return 'http://$detectedIP:8000/api';
        }
      }
    } catch (e) {
      print('❌ Échec de détection IP locale: $e');
    }

    // Si aucune IP ne fonctionne, utiliser l'émulateur par défaut
    print('⚠️ Aucun serveur trouvé, utilisation de l\'émulateur par défaut');
    return 'http://10.0.2.2:8000/api';
  }

  /// Détecte l'IP locale du réseau
  static Future<String?> _detectLocalIP() async {
    try {
      // Essayer de se connecter à un serveur externe pour obtenir l'IP locale
      final socket = await Socket.connect(
        '8.8.8.8',
        53,
        timeout: const Duration(seconds: 2),
      );
      final localAddress = socket.address.address;
      socket.destroy();

      // Vérifier que c'est une IP privée
      if (localAddress.startsWith('192.168.') ||
          localAddress.startsWith('10.') ||
          localAddress.startsWith('172.')) {
        return localAddress;
      }
    } catch (e) {
      print('❌ Impossible de détecter l\'IP locale: $e');
    }
    return null;
  }

  /// Force la détection d'une nouvelle IP
  static Future<String> refreshBaseUrl() async {
    _cachedBaseUrl = null;
    _lastCacheTime = null;
    return await getBaseUrl();
  }

  /// Obtient l'URL de base pour les images
  static Future<String> getImageBaseUrl() async {
    final baseUrl = await getBaseUrl();
    return baseUrl.replaceAll('/api', '');
  }
}
