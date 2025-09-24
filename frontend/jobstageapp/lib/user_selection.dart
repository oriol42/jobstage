import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'loginscreen.dart';

void main() {
  runApp(const JobstageApp());
}

/// Application principale Jobstage
/// Cette classe configure l'application avec le thème Material Design 3
/// et les couleurs spécifiques au projet (bleu #2196F3 et vert #4CAF50)
class JobstageApp extends StatelessWidget {
  const JobstageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jobstage - Plateforme de mise en relation emploi et stage',
      debugShowCheckedModeBanner: false, // Cache la bannière de debug
      // Configuration du thème avec Material Design 3
      theme: ThemeData(
        useMaterial3: true, // Active Material Design 3
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3), // Bleu principal Jobstage
          brightness: Brightness.light,
        ),

        // Configuration des polices avec Google Fonts
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),

        // Configuration des cartes avec des coins arrondis
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Page d'accueil de l'application
      home: const JobstageHomePage(),
    );
  }
}

/// Page d'accueil principale de Jobstage
/// Cette page présente l'interface de sélection de rôle (Candidat/Recruteur)
/// avec des animations et un design responsive
class JobstageHomePage extends StatefulWidget {
  const JobstageHomePage({super.key});

  @override
  State<JobstageHomePage> createState() => _JobstageHomePageState();
}

class _JobstageHomePageState extends State<JobstageHomePage>
    with TickerProviderStateMixin {
  // Contrôleurs d'animation pour les effets de chargement
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  // Animations pour les effets visuels
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configuration des contrôleurs d'animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Configuration des animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Démarrage des animations au chargement de la page
    _startAnimations();
  }

  /// Démarre les animations de chargement de manière séquentielle
  void _startAnimations() {
    // Animation de fondu pour le logo et le titre
    _fadeController.forward();

    // Animation de glissement pour les boutons avec un délai
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    // Nettoyage des contrôleurs d'animation
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir la taille de l'écran pour l'adaptation mobile
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Fond crème/beige comme dans la maquette
      backgroundColor: const Color(0xFFF8F6F0),

      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
              ), // 6% de la largeur
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.02,
                  ), // 2% de la hauteur (réduit)
                  // Section Logo et Titre avec animation de fondu
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHeaderSection(screenHeight, screenWidth),
                  ),

                  SizedBox(
                    height: screenHeight * 0.025,
                  ), // 2.5% de la hauteur (remonté)
                  // Section de sélection de rôle avec animation de glissement
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildRoleSelectionSection(
                      screenHeight,
                      screenWidth,
                    ),
                  ),

                  SizedBox(
                    height: screenHeight * 0.06,
                  ), // 6% de la hauteur (descendu)
                  // Footer avec animation de fondu
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFooterSection(screenHeight, screenWidth),
                  ),

                  SizedBox(
                    height: screenHeight * 0.005,
                  ), // 0.5% de la hauteur (réduit)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construit la section header avec le logo et le titre
  Widget _buildHeaderSection(double screenHeight, double screenWidth) {
    return Column(
      children: [
        // Logo principal - essaie de charger l'image, sinon affiche un placeholder
        _buildLogo(screenHeight, screenWidth),

        SizedBox(
          height: screenHeight * 0.015,
        ), // 1.5% de la hauteur (réduit pour optimiser l'espace)
        // Titre principal "Jobstage" - Logo du nom
        Image.asset(
          'assets/images/jobstage_logo.png',
          height:
              screenHeight * 0.18, // 18% de la hauteur (augmenté de 12% à 18%)
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback si l'image ne se charge pas
            return Text(
              'JOBSTAGE',
              style: GoogleFonts.inter(
                fontSize: screenWidth * 0.06, // 6% de la largeur (réduit)
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
                letterSpacing: 2.0,
              ),
            );
          },
        ),

        SizedBox(height: screenHeight * 0.01), // 1% de la hauteur (quasi collé)
        // Sous-titre descriptif
        Text(
          'Plateforme de mise en relation emploi et stage',
          style: GoogleFonts.inter(
            fontSize: screenWidth * 0.035, // 3.5% de la largeur
            color: const Color(0xFF7F8C8D),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Construit le logo principal - essaie de charger l'image, sinon affiche un placeholder
  Widget _buildLogo(double screenHeight, double screenWidth) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale:
              0.8 + (_fadeAnimation.value * 0.3), // Animation de zoom élégante
          child: SizedBox(
            width: screenWidth * 0.50, // 35% de la largeur (encore plus réduit)
            height:
                screenHeight * 0.12, // 8% de la hauteur (encore plus réduit)
            child: _buildImageWidget(
              'assets/images/logoapp.png',
              fallback: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'JOBSTAGE',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2C3E50),
                      fontWeight: FontWeight.bold,
                      fontSize:
                          screenWidth *
                          0.05, // 4% de la largeur (encore plus réduit)
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construit un widget d'image avec fallback
  Widget _buildImageWidget(String imagePath, {required Widget fallback}) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover, // Permet au logo d'être plus grand
      errorBuilder: (context, error, stackTrace) {
        return fallback;
      },
    );
  }

  /// Construit une icône personnalisée avec fallback
  Widget _buildCustomIcon(
    String iconPath,
    IconData fallbackIcon,
    Color iconColor,
    double screenWidth,
  ) {
    return Image.asset(
      iconPath,
      width: screenWidth * 0.065, // 6.5% de la largeur (légèrement agrandi)
      height: screenWidth * 0.065, // 6.5% de la largeur (légèrement agrandi)
      color: iconColor, // Couleur sombre pour la visibilité
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          fallbackIcon,
          color: iconColor,
          size: screenWidth * 0.065, // 6.5% de la largeur (légèrement agrandi)
        );
      },
    );
  }

  /// Construit la section de sélection de rôle avec les deux boutons
  Widget _buildRoleSelectionSection(double screenHeight, double screenWidth) {
    return Column(
      children: [
        // Titre "Je suis..."
        Text(
          'Je suis...',
          style: GoogleFonts.inter(
            fontSize: screenWidth * 0.06, // 6% de la largeur
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),

        SizedBox(height: screenHeight * 0.02), // 2% de la hauteur (remonté)
        // Bouton Candidat
        _buildRoleCard(
          title: 'Candidat',
          subtitle: 'je recherche un emploi ou un stage',
          iconPath: 'assets/icons/icandidat.jpeg',
          fallbackIcon: Icons.person,
          backgroundColor: const Color(0xFFE3F2FD), // Bleu clair
          iconContainerColor: const Color(
            0xFFD6E4FF,
          ), // Bleu très clair pour le conteneur d'icône
          iconColor: const Color(0xFF2196F3), // Bleu
          textColor: const Color(0xFF1976D2), // Bleu foncé
          onTap: () => _navigateToCandidatPage(),
          screenHeight: screenHeight,
          screenWidth: screenWidth,
        ),

        SizedBox(height: screenHeight * 0.02), // 2% de la hauteur (réduit)
        // Bouton Recruteur
        _buildRoleCard(
          title: 'Recruteur',
          subtitle: 'je propose des offres d\'emploi ou de stage',
          iconPath: 'assets/icons/ientreprise.jpeg',
          fallbackIcon: Icons.business,
          backgroundColor: const Color(0xFFE8F5E8), // Vert clair
          iconContainerColor: const Color(
            0xFFCCF5D3,
          ), // Vert très clair pour le conteneur d'icône
          iconColor: const Color(
            0xFF2C3E50,
          ), // Couleur sombre pour la visibilité
          textColor: const Color(0xFF388E3C), // Vert foncé
          onTap: () => _navigateToRecruteurPage(),
          screenHeight: screenHeight,
          screenWidth: screenWidth,
        ),
      ],
    );
  }

  /// Construit une carte de rôle avec animation et effets
  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required String iconPath,
    required IconData fallbackIcon,
    required Color backgroundColor,
    required Color iconContainerColor,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
    required double screenHeight,
    required double screenWidth,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleController.isAnimating ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) {
              _scaleController.reverse();
              onTap();
            },
            onTapCancel: () => _scaleController.reverse(),

            // Effet de hover pour le web
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  screenWidth * 0.05,
                ), // 5% de la largeur (légèrement agrandi)
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icône dans un conteneur coloré arrondi
                    Container(
                      width:
                          screenWidth *
                          0.11, // 11% de la largeur (légèrement agrandi)
                      height:
                          screenWidth *
                          0.11, // 11% de la largeur (légèrement agrandi)
                      decoration: BoxDecoration(
                        color: iconContainerColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _buildCustomIcon(
                          iconPath,
                          fallbackIcon,
                          iconColor,
                          screenWidth,
                        ),
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.05), // 5% de la largeur
                    // Texte principal et secondaire
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize:
                                  screenWidth * 0.045, // 4.5% de la largeur
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ), // 1% de la hauteur
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              fontSize:
                                  screenWidth * 0.035, // 3.5% de la largeur
                              color: textColor.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Flèche de navigation
                    Icon(
                      Icons.arrow_forward_ios,
                      color: textColor.withValues(alpha: 0.6),
                      size: screenWidth * 0.04, // 4% de la largeur
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construit la section footer avec le lien CENADI et le copyright
  Widget _buildFooterSection(double screenHeight, double screenWidth) {
    return Column(
      children: [
        // Lien "À propos de CENADI"
        GestureDetector(
          onTap: _openCenadiWebsite,
          child: Text(
            'À propos de CENADI',
            style: GoogleFonts.inter(
              fontSize: screenWidth * 0.035, // 3.5% de la largeur
              color: const Color(0xFF2196F3),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.02), // 2% de la hauteur
        // Copyright
        Text(
          '© 2024 CENADI - Tous droits réservés',
          style: GoogleFonts.inter(
            fontSize: screenWidth * 0.03, // 3% de la largeur
            color: const Color(0xFF7F8C8D),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Navigation vers la page Candidat avec Hero animation
  void _navigateToCandidatPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const JobstageLoginScreen(userType: 'candidat'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Hero animation pour une transition fluide
          return Hero(
            tag: 'candidat_page',
            child: FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                    ),
                child: child,
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Navigation vers la page Recruteur avec Hero animation
  void _navigateToRecruteurPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const JobstageLoginScreen(userType: 'recruteur'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Hero animation pour une transition fluide
          return Hero(
            tag: 'recruteur_page',
            child: FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                    ),
                child: child,
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Ouvre le site officiel du CENADI
  Future<void> _openCenadiWebsite() async {
    const url = 'https://www.cenadi.cm/'; // URL du site officiel CENADI
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Si l'URL ne peut pas être ouverte, afficher une boîte de dialogue d'information
        _showCenadiInfo();
      }
    } catch (e) {
      // En cas d'erreur, afficher une boîte de dialogue d'information
      _showCenadiInfo();
    }
  }

  /// Affiche une boîte de dialogue d'information sur CENADI (fallback)
  void _showCenadiInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'À propos de CENADI',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF7F8C8D),
            ),
            children: [
              const TextSpan(
                text:
                    "Le CENADI (Centre National de Développement Informatique) est l'institution publique camerounaise chargée de la modernisation numérique de l'administration et des services publics.\n\n"
                    'Jobstage est notre plateforme innovante qui utilise l\'intelligence artificielle pour faciliter la mise en relation entre candidats et recruteurs.\n\n'
                    'Site web: ',
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () async {
                    const url = 'https://www.cenadi.cm/';
                    final uri = Uri.parse(url);
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.platformDefault);
                      } else {
                        // Fallback: essayer avec un mode différent
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    } catch (e) {
                      // Afficher un message d'erreur à l'utilisateur
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Impossible d\'ouvrir le lien: $url'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'https://www.cenadi.cm/',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF2196F3),
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF2196F3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fermer',
              style: GoogleFonts.inter(
                color: const Color(0xFF2196F3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Page Candidat - Page de destination pour les candidats
/// Cette page est actuellement vide mais prête pour le développement futur
class CandidatPage extends StatelessWidget {
  const CandidatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        title: Text(
          'Espace Candidat',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        backgroundColor: const Color(0xFFE3F2FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: const Color(0xFF2196F3).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Espace Candidat',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Cette page sera développée prochainement',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page Recruteur - Page de destination pour les recruteurs
/// Cette page est actuellement vide mais prête pour le développement futur
class RecruteurPage extends StatelessWidget {
  const RecruteurPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        title: Text(
          'Espace Recruteur',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        backgroundColor: const Color(0xFFE8F5E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: 80,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Espace Recruteur',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Cette page sera développée prochainement',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
=== SUGGESTIONS D'AMÉLIORATION FUTURE ===

1. SÉPARATION DU CODE :
   - Créer des fichiers séparés pour chaque page (candidat_page.dart, recruteur_page.dart)
   - Créer un dossier 'widgets' pour les composants réutilisables
   - Créer un dossier 'constants' pour les couleurs et styles
   - Créer un dossier 'animations' pour les contrôleurs d'animation

2. GESTION D'ÉTAT :
   - Implémenter Provider ou Bloc pour la gestion d'état
   - Créer des modèles de données pour les utilisateurs
   - Ajouter la persistance des préférences utilisateur

3. THÈME ET PERSONNALISATION :
   - Créer un ThemeData personnalisé dans un fichier séparé
   - Ajouter le support du mode sombre
   - Créer des constantes pour les couleurs et tailles

4. NAVIGATION :
   - Implémenter une navigation plus complexe avec BottomNavigationBar
   - Ajouter des routes nommées pour une meilleure organisation
   - Créer un système de navigation avec des guards d'authentification

5. RESPONSIVE DESIGN :
   - Ajouter des breakpoints pour tablettes
   - Optimiser l'affichage pour différentes tailles d'écran
   - Implémenter des layouts adaptatifs

6. ACCESSIBILITÉ :
   - Ajouter des labels sémantiques
   - Implémenter le support des lecteurs d'écran
   - Ajouter des indicateurs de focus pour la navigation clavier

7. PERFORMANCE :
   - Optimiser les animations pour de meilleures performances
   - Implémenter le lazy loading pour les listes
   - Ajouter la mise en cache des images et données

8. INTERNATIONALISATION :
   - Ajouter le support multilingue avec flutter_localizations
   - Créer des fichiers de traduction
   - Implémenter la détection automatique de la langue

9. TESTS :
   - Ajouter des tests unitaires pour la logique métier
   - Créer des tests d'intégration pour les flux utilisateur
   - Implémenter des tests de widgets pour l'interface

10. CI/CD :
    - Configurer GitHub Actions pour les tests automatiques
    - Implémenter la génération automatique d'APK/IPA
    - Ajouter la distribution automatique sur les stores
*/
