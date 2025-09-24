import 'package:flutter/material.dart';
import 'user_selection.dart';
import 'services/auth_service.dart';
import 'dashboard_screen.dart';
import 'screens/recruiter/recruiter_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
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

    // Contrôleur pour le logo - plus rapide
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Contrôleur pour l'effet de révélation du texte - plus rapide
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2200),
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

    // Démarrer les animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Démarrer l'animation du logo
    _logoController.forward();

    // Démarrer l'animation de flottement du logo
    _logoFloatController.repeat(reverse: true);

    // Attendre que le logo finisse puis démarrer le texte
    await Future.delayed(const Duration(milliseconds: 1800));
    _textController.forward();

    // Attendre que le texte finisse puis démarrer le slogan
    await Future.delayed(const Duration(milliseconds: 2200));
    _sloganController.forward();

    // Le texte JOBSTAGE reste statique - pas d'animation

    // Attendre que toutes les animations soient terminées
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // Durée de l'animation du slogan

    // Attendre 2 secondes supplémentaires après la fin de toutes les animations
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      print('🚀 SplashScreen: Redirection vers JobstageHomePage');
      print(
        '🚀 SplashScreen: Mode développement - toujours rediriger vers sélection',
      );

      // En mode développement, toujours rediriger vers l'écran de sélection
      // pour permettre de tester login/signup facilement
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf5f5f5), // Gris clair sobre
              Color(0xFFf0f0f0), // Légère variation pour la profondeur
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Logo - positionné plus bas et plus grand - responsive
            Positioned(
              top:
                  MediaQuery.of(context).size.height *
                  0.12, // 12% de la hauteur d'écran (réduit de 15% à 12%)
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _logoController,
                  _logoFloatController,
                ]),
                builder: (context, child) {
                  final logoOffset =
                      5 * (1 - _logoScaleAnimation.value) +
                      8 * _logoFloatAnimation.value;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ombre petite et profonde sous le logo
                      Transform.translate(
                        offset: Offset(
                          0,
                          logoOffset +
                              120, // 120px sous le logo (20px plus bas au total)
                        ),
                        child: Opacity(
                          opacity: _logoFloatAnimation.value < 0
                              ? 0.2 +
                                    (0.6 *
                                        (-_logoFloatAnimation
                                            .value)) // Apparaît progressivement quand descend
                              : 0.0, // Disparaît totalement quand le logo remonte
                          child: Container(
                            width:
                                30 +
                                (15 *
                                    (-_logoFloatAnimation.value).clamp(
                                      0.0,
                                      1.0,
                                    )),
                            height:
                                8 +
                                (4 *
                                    (-_logoFloatAnimation.value).clamp(
                                      0.0,
                                      1.0,
                                    )),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                // Ombre principale - très profonde
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    0.4 +
                                        (0.5 *
                                            (-_logoFloatAnimation.value).clamp(
                                              0.0,
                                              1.0,
                                            )),
                                  ),
                                  offset: Offset(
                                    0,
                                    3 +
                                        (2 *
                                            (-_logoFloatAnimation.value).clamp(
                                              0.0,
                                              1.0,
                                            )),
                                  ),
                                  blurRadius:
                                      8 +
                                      (6 *
                                          (-_logoFloatAnimation.value).clamp(
                                            0.0,
                                            1.0,
                                          )),
                                  spreadRadius:
                                      1 +
                                      (2 *
                                          (-_logoFloatAnimation.value).clamp(
                                            0.0,
                                            1.0,
                                          )),
                                ),
                                // Ombre secondaire pour la profondeur
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    0.2 +
                                        (0.3 *
                                            (-_logoFloatAnimation.value).clamp(
                                              0.0,
                                              1.0,
                                            )),
                                  ),
                                  offset: Offset(
                                    0,
                                    6 +
                                        (4 *
                                            (-_logoFloatAnimation.value).clamp(
                                              0.0,
                                              1.0,
                                            )),
                                  ),
                                  blurRadius:
                                      15 +
                                      (10 *
                                          (-_logoFloatAnimation.value).clamp(
                                            0.0,
                                            1.0,
                                          )),
                                  spreadRadius:
                                      0 +
                                      (1 *
                                          (-_logoFloatAnimation.value).clamp(
                                            0.0,
                                            1.0,
                                          )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Logo principal
                      Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Opacity(
                          opacity: _logoOpacityAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, logoOffset),
                            child: Image.asset(
                              'assets/images/logoapp.png',
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.8, // 80% de la largeur d'écran
                              height:
                                  MediaQuery.of(context).size.width *
                                  0.8, // 80% de la largeur d'écran
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Texte JobStage au centre avec effet de perspective
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top:
                      MediaQuery.of(context).size.height *
                      0.18, // 18% de la hauteur d'écran (augmenté de 12% à 18%)
                ), // Espacement responsive pour éviter le chevauchement avec le logo
                child: AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Perspective
                        ..rotateX(0.1), // Légère rotation pour l'effet 3D
                      child: _buildSpectacularText(),
                    );
                  },
                ),
              ),
            ),

            // Slogan en bas - responsive
            Positioned(
              bottom:
                  MediaQuery.of(context).size.height *
                  0.08, // 8% de la hauteur d'écran
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _sloganController,
                builder: (context, child) {
                  return _buildSlogan();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpectacularText() {
    return AnimatedBuilder(
      animation: _textRevealAnimation,
      builder: (context, child) {
        return _buildRevealedText();
      },
    );
  }

  Widget _buildRevealedText() {
    const text = 'JOBSTAGE';
    final progress = _textRevealAnimation.value;

    // Obtenir les dimensions de l'écran pour le responsive
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculer combien de lettres sont révélées avec un effet plus progressif
    final totalLetters = text.length;
    final revealedLetters = (totalLetters * progress).floor();
    final currentLetterProgress = (progress * totalLetters) - revealedLetters;

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (int i = 0; i < totalLetters; i++)
          AnimatedBuilder(
            animation: _textRevealAnimation,
            builder: (context, child) {
              final isFullyVisible = i < revealedLetters;
              final isCurrentLetter = i == revealedLetters;

              double scale, opacity, translateY;

              if (isFullyVisible) {
                // Lettre complètement visible
                scale = 1.0;
                opacity = 1.0;
                translateY = 0.0;
              } else if (isCurrentLetter) {
                // Lettre en cours d'apparition
                scale = 0.3 + (currentLetterProgress * 0.7);
                opacity = currentLetterProgress;
                translateY = (1 - currentLetterProgress) * 30;
              } else {
                // Lettre cachée
                scale = 0.0;
                opacity = 0.0;
                translateY = 30.0;
              }

              // Le J et le S sont plus grands - tailles responsive
              final isSpecialLetter = i == 0 || i == 3; // J et S
              final letterScale = isSpecialLetter ? 1.2 : 1.0;
              // Tailles responsive basées sur la largeur de l'écran
              final baseFontSize =
                  screenWidth * 0.167; // 16.7% de la largeur d'écran pour 60px
              final letterFontSize = isSpecialLetter
                  ? baseFontSize *
                        1.27 // 76px pour J et S
                  : baseFontSize; // 60px pour les autres lettres

              return Transform.scale(
                scale: scale * letterScale,
                child: Transform.translate(
                  offset: Offset(0, translateY),
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.005,
                      ), // 0.5% de la largeur d'écran
                      child: Text(
                        text[i],
                        style: TextStyle(
                          fontSize: letterFontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: const Color(0xFF2980b9),
                          shadows: [
                            Shadow(
                              color: const Color(0xFF27ae60).withOpacity(0.9),
                              offset: const Offset(0, 0),
                              blurRadius: 25,
                            ),
                            Shadow(
                              color: const Color(0xFF27ae60).withOpacity(0.5),
                              offset: const Offset(0, 0),
                              blurRadius: 40,
                            ),
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              offset: const Offset(0, 0),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSlogan() {
    // Obtenir les dimensions de l'écran pour le responsive
    final screenWidth = MediaQuery.of(context).size.width;

    return Transform.scale(
      scale: _sloganAnimation.value,
      child: Opacity(
        opacity: _sloganAnimation.value,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Votre carrière, notre passion',
              style: TextStyle(
                fontSize: screenWidth * 0.045, // 4.5% de la largeur d'écran
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF2980b9).withOpacity(0.8),
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: const Color(0xFF27ae60).withOpacity(0.3),
                    offset: const Offset(0, 0),
                    blurRadius: 8,
                  ),
                  Shadow(
                    color: Colors.white.withOpacity(0.2),
                    offset: const Offset(0, 0),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: screenWidth * 0.15, // 15% de la largeur d'écran
              height: screenWidth * 0.005, // 0.5% de la largeur d'écran
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF27ae60), Color(0xFF2980b9)],
                ),
                borderRadius: BorderRadius.circular(1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF27ae60).withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
