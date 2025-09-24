import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../loginscreen.dart';
import '../dashboard_screen.dart';
import '../screens/recruiter/recruiter_navigation.dart';

/// Helper class pour gérer la navigation de manière cohérente
class NavigationHelper {
  /// Retourne à l'écran précédent ou à un écran de fallback approprié
  static void handleBackNavigation(
    BuildContext context, {
    Widget? fallbackScreen,
    bool checkAuth = true,
  }) {
    print('🔙 NavigationHelper.handleBackNavigation appelé');
    print('   - checkAuth: $checkAuth');
    print('   - fallbackScreen: ${fallbackScreen?.runtimeType}');

    // Vérifier l'authentification si demandé
    if (checkAuth) {
      final authService = AuthService();
      print('   - isLoggedIn: ${authService.isLoggedIn}');
      print('   - currentUser: ${authService.currentUser?.userType}');

      if (!authService.isLoggedIn) {
        print('   - ❌ Utilisateur non authentifié, redirection vers login');
        _redirectToLogin(context);
        return;
      }
    }

    // Essayer de faire un retour normal
    final canPop = Navigator.of(context).canPop();
    print('   - canPop: $canPop');

    if (canPop) {
      print('   - ✅ Retour normal avec pop()');
      Navigator.of(context).pop();
    } else {
      print('   - ⚠️ Pas d\'écran précédent, redirection vers fallback');
      _redirectToAppropriateScreen(context, fallbackScreen);
    }
  }

  /// Redirige vers l'écran de login
  static void _redirectToLogin(BuildContext context) {
    print('   - 🔄 Redirection vers login');
    print(
      '   - 🚨 ATTENTION: Cette redirection ne devrait PAS se produire si l\'utilisateur est connecté !',
    );
    print('   - 🔍 Stack trace:');
    print(StackTrace.current);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const JobstageLoginScreen()),
      (route) => false,
    );
  }

  /// Redirige vers l'écran approprié selon le contexte
  static void _redirectToAppropriateScreen(
    BuildContext context,
    Widget? fallbackScreen,
  ) {
    print('   - 🎯 _redirectToAppropriateScreen appelé');
    print('   - fallbackScreen: ${fallbackScreen?.runtimeType}');

    // Si un écran de fallback est fourni, l'utiliser
    if (fallbackScreen != null) {
      print('   - ✅ Utilisation du fallback: ${fallbackScreen.runtimeType}');

      // Si le fallback est RecruiterNavigation, utiliser pushReplacement pour préserver la barre de navigation
      if (fallbackScreen.runtimeType.toString().contains(
        'RecruiterNavigation',
      )) {
        print(
          '   - 🔄 Utilisation de pushReplacement pour RecruiterNavigation',
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => fallbackScreen),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => fallbackScreen),
          (route) => false,
        );
      }
      return;
    }

    // Sinon, déterminer l'écran approprié selon l'utilisateur connecté
    final authService = AuthService();
    print('   - isLoggedIn: ${authService.isLoggedIn}');

    if (authService.isLoggedIn) {
      final user = authService.currentUser;
      print('   - user: ${user?.userType}');

      if (user != null) {
        // Déterminer le type d'utilisateur et rediriger vers le bon dashboard
        if (user.userType == 'recruteur') {
          print('   - 🔄 Redirection vers RecruiterNavigation');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const RecruiterNavigation(),
            ),
          );
        } else {
          print('   - 🔄 Redirection vers DashboardScreen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        print('   - ❌ User null, redirection vers login');
        _redirectToLogin(context);
      }
    } else {
      print('   - ❌ Non connecté, redirection vers login');
      _redirectToLogin(context);
    }
  }

  /// Crée un AppBar avec une gestion de retour cohérente
  static AppBar createAppBar(
    BuildContext context, {
    required String title,
    Widget? fallbackScreen,
    bool checkAuth = true,
    Color? backgroundColor,
    Color? foregroundColor,
    List<Widget>? actions,
  }) {
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      actions: actions,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => handleBackNavigation(
          context,
          fallbackScreen: fallbackScreen,
          checkAuth: checkAuth,
        ),
      ),
    );
  }

  /// Vérifie l'authentification et redirige si nécessaire
  static bool checkAuthentication(BuildContext context) {
    final authService = AuthService();
    if (!authService.isLoggedIn) {
      _redirectToLogin(context);
      return false;
    }
    return true;
  }

  /// Navigue vers un écran avec vérification d'authentification
  static Future<T?> navigateWithAuth<T extends Object?>(
    BuildContext context,
    Widget destination, {
    bool checkAuth = true,
  }) {
    if (checkAuth && !checkAuthentication(context)) {
      return Future.value(null);
    }

    return Navigator.of(
      context,
    ).push<T>(MaterialPageRoute(builder: (context) => destination));
  }

  /// Navigue et remplace avec vérification d'authentification
  static Future<T?> navigateReplacementWithAuth<T extends Object?>(
    BuildContext context,
    Widget destination, {
    bool checkAuth = true,
  }) {
    if (checkAuth && !checkAuthentication(context)) {
      return Future.value(null);
    }

    return Navigator.of(context).pushReplacement<T, dynamic>(
      MaterialPageRoute(builder: (context) => destination),
    );
  }
}
