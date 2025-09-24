import 'package:flutter/material.dart';
import 'user_selection.dart';
import 'services/auth_service.dart';
import 'dashboard_screen.dart';
import 'screens/recruiter/recruiter_navigation.dart';

/// Version de production du SplashScreen qui vérifie l'authentification
class SplashScreenProduction extends StatefulWidget {
  const SplashScreenProduction({super.key});

  @override
  State<SplashScreenProduction> createState() => _SplashScreenProductionState();
}

class _SplashScreenProductionState extends State<SplashScreenProduction>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _sloganController;
  late AnimationController _logoFloatController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textRevealAnimation;
  late Animation<double> _sloganAnimation;
  late Animation<double> _logoFloatAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Contrôleur pour le logo - animation principale
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Contrôleur pour le texte - commence après le logo
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Contrôleur pour le slogan - plus rapide
    _sloganController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Contrôleur pour l'animation de flottement du logo - plus lent et naturel
    _logoFloatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animations du logo - commence petit puis grossit, plus petit final
    _logoScaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Animation de révélation du texte - plus fluide
    _textRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    // Animation du slogan
    _sloganAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sloganController, curve: Curves.easeInOut),
    );

    // Animation de flottement du logo - plus ample
    _logoFloatAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoFloatController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    // Démarrer l'animation du logo immédiatement
    _logoController.forward();

    // Démarrer l'animation de flottement en boucle
    _logoFloatController.repeat(reverse: true);

    // Attendre que l'animation du logo soit à 60% pour commencer le texte
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      _textController.forward();
    }

    // Attendre que l'animation du texte soit à 50% pour commencer le slogan
    await Future.delayed(const Duration(milliseconds: 750));

    if (mounted) {
      _sloganController.forward();
    }

    // Le texte JOBSTAGE reste statique - pas d'animation

    // Attendre que toutes les animations soient terminées
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // Durée de l'animation du slogan

    // Attendre 2 secondes supplémentaires après la fin de toutes les animations
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      print(
        '🚀 SplashScreenProduction: Vérification de l\'authentification...',
      );

      // Vérifier l'authentification avant de rediriger
      final authService = AuthService();
      print('🚀 SplashScreenProduction: isLoggedIn: ${authService.isLoggedIn}');
      print(
        '🚀 SplashScreenProduction: currentUser: ${authService.currentUser?.userType}',
      );

      if (authService.isLoggedIn) {
        final user = authService.currentUser;
        if (user != null) {
          print(
            '🚀 SplashScreenProduction: Utilisateur connecté, redirection vers dashboard approprié',
          );
          if (user.userType == 'recruteur') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RecruiterNavigation(),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
          return;
        }
      }

      print(
        '🚀 SplashScreenProduction: Utilisateur non connecté, redirection vers sélection',
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const JobstageHomePage()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _sloganController.dispose();
    _logoFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo avec animations
            AnimatedBuilder(
              animation: Listenable.merge([
                _logoScaleAnimation,
                _logoOpacityAnimation,
                _logoFloatAnimation,
              ]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _logoFloatAnimation.value * 3),
                  child: Opacity(
                    opacity: _logoOpacityAnimation.value,
                    child: Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4A90E2).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'JS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Texte JOBSTAGE avec animation de révélation
            AnimatedBuilder(
              animation: _textRevealAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textRevealAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _textRevealAnimation.value)),
                    child: const Text(
                      'JOBSTAGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Slogan avec animation
            AnimatedBuilder(
              animation: _sloganAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _sloganAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 15 * (1 - _sloganAnimation.value)),
                    child: const Text(
                      'Votre carrière commence ici',
                      style: TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
