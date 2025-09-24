import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/offer_status.dart';
import 'screens/offers_screen.dart';
import 'screens/applications_screen.dart';
import 'screens/my_applications_screen.dart';
import 'screens/training_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/companies_screen.dart';
import 'services/auth_service.dart';
import 'theme/theme_provider.dart';

class AppColors {
  static const Color blueDark = Color(0xFF1E88E5);
  static const Color blueLight = Color(0xFFE3F2FD);
  static const Color blueGradientEnd = Color(0xFF0D47A1);
  static const Color primaryText = Color(0xFF1C1B1F);
  static const Color secondaryText = Color(0xFF49454F);
  static const Color surfaceBg = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color greenDark = Color(0xFF4CAF50);
  static const Color dividerColor = Color(0xFFD3D3D3);

  // Quick action colors
  static const Color offersIconBg = Color(0xFFB2EBF2);
  static const Color offersIconColor = Color(0xFF00BCD4);
  static const Color candidatureIconBg = Color(0xFFBBDEFB);
  static const Color candidatureIconColor = Color(0xFF2196F3);
  static const Color formationIconBg = Color(0xFFE1BEE7);
  static const Color formationIconColor = Color(0xFF9C27B0);
  static const Color favorisIconBg = Color(0xFFFFECB3);
  static const Color favorisIconColor = Color(0xFFFFC107);

  // Activity colors
  static const Color activityViewedBg = Color(0xFFE3F2FD);
  static const Color activityAppliedBg = Color(0xFFE8F5E8);
  static const Color activityMatchedBg = Color(0xFFFFF3E0);
  static const Color orangeDark = Color(0xFFFF9800);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Accueil tab is active by default

  // Profile completion percentage - can be updated dynamically
  double profileCompletionPercentage = 0.0;
  String userName = 'Utilisateur';
  String userGreeting = 'Bonjour!';
  final AuthService _authService = AuthService();

  // Track favorite states for job cards
  Map<String, bool> favorites = {
    'Développeur Flutter Junior': true,
    'Stage Marketing Digital': false,
    'Analyste de Données': false,
  };

  @override
  void initState() {
    super.initState();
    // Reset to Accueil when dashboard is initialized
    _selectedIndex = 0;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('Dashboard: Chargement des données utilisateur...');
    print('Dashboard: Token disponible: ${_authService.token != null}');
    print(
      'Dashboard: Utilisateur actuel: ${_authService.currentUser?.username}',
    );

    final result = await _authService.getProfile();
    print('Dashboard: Résultat getProfile: $result');

    if (result['success'] && mounted) {
      setState(() {
        if (result['user'] != null) {
          final user = result['user'];
          // Utiliser first_name s'il existe, sinon username
          if (user.firstName?.isNotEmpty == true) {
            userName = user.firstName!;
            if (user.lastName?.isNotEmpty == true) {
              userName += ' ${user.lastName!}';
            }
          } else {
            userName = user.username;
          }
          userGreeting = 'Bonjour $userName!';
          print('Dashboard: Nom utilisateur mis à jour: $userName');
        }
        if (result['profile'] != null) {
          profileCompletionPercentage = result['profile'].completionPercentage;
          print(
            'Dashboard: Pourcentage de complétude: $profileCompletionPercentage',
          );
        }
      });
    } else {
      print('Dashboard: Erreur lors du chargement: ${result['message']}');
      // En cas d'erreur, garder les valeurs par défaut
      setState(() {
        userName = 'Utilisateur';
        userGreeting = 'Bonjour!';
        profileCompletionPercentage = 0.0;
      });
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different screens based on selected index
    switch (index) {
      case 0: // Accueil - already on dashboard
        // Reset index to ensure Accueil is highlighted
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 1: // Mes offres
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OffersScreen()),
        ).then((_) {
          // Reset to Accueil when returning from other screens
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 2: // Profil
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        ).then((_) {
          // Reset to Accueil when returning from other screens
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 3: // Paramètres
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        ).then((_) {
          // Reset to Accueil when returning from other screens
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
    }
  }

  void _toggleFavorite(String jobTitle) {
    setState(() {
      favorites[jobTitle] = !(favorites[jobTitle] ?? false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          favorites[jobTitle]!
              ? 'Offre ajoutée aux favoris'
              : 'Offre supprimée des favoris',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: favorites[jobTitle]!
            ? AppColors.greenDark
            : Colors.grey,
      ),
    );
  }

  void _showJobDetails(
    String title,
    String company,
    String location,
    String type,
    String time,
    String match,
    bool isJob, {
    String? salary,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        company,
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (salary != null) _buildDetailRow('Salaire', salary),
                      _buildLocationSection('Localisation', location),
                      _buildDetailRow('Type de contrat', type),
                      _buildDetailRow('Match', match),
                      _buildDetailRow('Publié', time),
                      _buildDetailRow(
                        'Description',
                        'Nous recherchons un professionnel passionné pour rejoindre notre équipe dynamique. Une excellente opportunité de développement professionnel vous attend.',
                      ),
                      _buildDetailRow(
                        'Compétences requises',
                        '• Flutter et Dart\n• Firebase\n• API REST\n• Git\n• Travail en équipe',
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showApplicationDialog(title, company);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueDark,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Postuler maintenant',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(String title, String location) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openGoogleMaps(location),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.blueDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.blueDark.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.blueDark,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Maps',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openGoogleMaps(String location) {
    // TODO: Implémenter l'ouverture de Google Maps avec la localisation
    // Cette méthode sera connectée au backend plus tard pour :
    // 1. Obtenir la position actuelle du candidat
    // 2. Obtenir les coordonnées précises de l'entreprise
    // 3. Ouvrir Google Maps avec les deux positions pour calculer l'itinéraire

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ouverture de Google Maps pour "$location" - Fonctionnalité à venir',
          style: GoogleFonts.roboto(),
        ),
        backgroundColor: AppColors.blueDark,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showApplicationDialog(String jobTitle, String company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Candidature envoyée !',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        content: Text(
          'Votre candidature pour le poste "$jobTitle" chez $company a été envoyée avec succès.',
          style: GoogleFonts.roboto(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.roboto(
                color: AppColors.blueDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Support Client',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Comment pouvons-nous vous aider ?',
              style: GoogleFonts.roboto(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.chat),
                label: const Text('Chat en direct'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueDark,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email envoyé à support@jobstage.cm'),
                    ),
                  );
                },
                icon: const Icon(Icons.email),
                label: const Text('Envoyer un email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenDark,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: GoogleFonts.roboto(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog() {
    final notifications = [
      {
        'title': 'Nouvelle offre correspondante',
        'subtitle': 'Développeur Mobile chez TechCorp',
        'time': '5 min',
        'icon': Icons.work,
        'color': AppColors.blueDark,
      },
      {
        'title': 'Profil consulté',
        'subtitle': 'Innovation Hub a consulté votre profil',
        'time': '1h',
        'icon': Icons.visibility,
        'color': AppColors.greenDark,
      },
      {
        'title': 'Message reçu',
        'subtitle': 'Nouveau message de DataCorp',
        'time': '3h',
        'icon': Icons.message,
        'color': AppColors.orangeDark,
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Notifications',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '3',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (notification['color'] as Color).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        notification['icon'] as IconData,
                        color: notification['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification['title'] as String,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                          Text(
                            notification['subtitle'] as String,
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      notification['time'] as String,
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les notifications marquées comme lues'),
                ),
              );
            },
            child: Text(
              'Tout marquer comme lu',
              style: GoogleFonts.roboto(
                color: AppColors.blueDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: GoogleFonts.roboto(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode
              ? const Color(0xFF000B1A)
              : AppColors.surfaceBg,
          body: SafeArea(
            child: Column(
              children: [
                // App Header with gradient
                _buildAppHeader(),
                // Main content with scrolling
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    child: Column(
                      children: [
                        // Profile completion card (below header)
                        _buildProfileCompletionCard(),
                        const SizedBox(height: 25),
                        _buildQuickActionsSection(),
                        const SizedBox(height: 25),
                        _buildRecommendedSection(),
                        const SizedBox(height: 25),
                        _buildRecentActivitySection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigation(),
        );
      },
    );
  }

  Widget _buildAppHeader() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: themeProvider.isDarkMode
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF00BCD4), // Cyan bleu
                      Color(0xFF2196F3), // Bleu
                      Color(0xFF4CAF50), // Vert
                    ],
                    stops: [0.0, 0.5, 1.0],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.blueDark, AppColors.blueGradientEnd],
                  ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              10,
            ), // Espace réduit pour un header plus compact
            child: Column(
              children: [
                // Header top row with logo and icons
                Transform.translate(
                  offset: const Offset(
                    0,
                    -5,
                  ), // Offset réduit pour éviter l'overflow
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/jobstage_logo.png',
                        height: 100, // Logo taille 100
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'JOBSTAGE',
                            style: GoogleFonts.roboto(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      // Icon group
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 0,
                        ), // Supprime l'espace au-dessus des icônes
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showSupportDialog(),
                              child: _buildHeaderIcon(Icons.support_agent, 0),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              ),
                              child: _buildHeaderIcon(Icons.person, 0),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _showNotificationsDialog(),
                              child: _buildHeaderIcon(Icons.notifications, 3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // User greeting - descendu légèrement pour un meilleur espacement
                Transform.translate(
                  offset: const Offset(
                    0,
                    -10,
                  ), // Offset réduit pour éviter l'overflow
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userGreeting,
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Trouvons votre prochain emploi',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Search bar - descendue légèrement pour un meilleur espacement
                Transform.translate(
                  offset: const Offset(
                    0,
                    -5,
                  ), // Offset réduit pour éviter l'overflow
                  child: _buildSearchBar(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderIcon(IconData icon, int badgeCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5722),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OffersScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          enabled: false,
          style: GoogleFonts.roboto(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Rechercher une offre d\'emploi ou un stage...',
            hintStyle: GoogleFonts.roboto(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 20, right: 15),
              child: Icon(
                Icons.search,
                color: AppColors.secondaryText,
                size: 24,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCompletionCard() {
    final completionText = '${(profileCompletionPercentage * 100).round()}%';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complétude du profil: $completionText',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: profileCompletionPercentage),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(profileCompletionPercentage),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 0.9) return AppColors.greenDark;
    if (percentage >= 0.7) return AppColors.favorisIconColor;
    if (percentage >= 0.5) return AppColors.orangeDark;
    return Colors.red;
  }

  String _getSalaryForJob(String jobTitle) {
    switch (jobTitle) {
      case 'Développeur Flutter Junior':
        return '400,000 - 600,000 FCFA';
      case 'Analyste de Données':
        return '500,000 - 800,000 FCFA';
      case 'Stage Marketing Digital':
        return '150,000 FCFA';
      default:
        return '350,000 - 500,000 FCFA';
    }
  }

  Widget _buildQuickActionsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Actions rapides',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              'Mes Candidatures',
              Icons.description,
              AppColors.candidatureIconBg,
              AppColors.candidatureIconColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyApplicationsScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Entreprises',
              Icons.business,
              AppColors.offersIconBg,
              AppColors.offersIconColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompaniesScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Formations',
              Icons.school,
              AppColors.formationIconBg,
              AppColors.formationIconColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrainingScreen()),
              ),
            ),
            _buildActionCard(
              'Mes Favoris',
              Icons.bookmark,
              AppColors.favorisIconBg,
              AppColors.favorisIconColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color iconBgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommandé pour vous',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OffersScreen()),
              ),
              child: Text(
                'Tout voir',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blueDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildJobCard(
          'Développeur Flutter Junior',
          'TechCorp Cameroun',
          'Yaoundé',
          'CDI',
          'Il y a 2h',
          '92%',
          AppColors.greenDark,
          isJob: true,
          status: 'En cours',
        ),
        const SizedBox(height: 10),
        _buildJobCard(
          'Analyste de Données',
          'DataCorp Solutions',
          'Yaoundé',
          'CDD 12 mois',
          'Il y a 1 jour',
          '89%',
          AppColors.greenDark,
          isJob: true,
          status: 'En pause',
        ),
        const SizedBox(height: 10),
        _buildJobCard(
          'Stage Marketing Digital',
          'Innovation Hub',
          'Douala',
          'Stage 6 mois',
          'Il y a 5h',
          '87%',
          AppColors.blueDark,
          isJob: false,
          status: 'Expirée',
        ),
      ],
    );
  }

  Widget _buildJobCard(
    String title,
    String company,
    String location,
    String type,
    String time,
    String matchScore,
    Color borderColor, {
    required bool isJob,
    String? status,
  }) {
    return GestureDetector(
      onTap: () => _showJobDetails(
        title,
        company,
        location,
        type,
        time,
        matchScore,
        isJob,
        salary: _getSalaryForJob(title),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border(left: BorderSide(color: borderColor, width: 5)),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (status != null) ...[
                        const SizedBox(height: 6),
                        _buildStatusBadge(status),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        company,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleFavorite(title),
                      child: Icon(
                        favorites[title] == true
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: favorites[title] == true
                            ? AppColors.favorisIconColor
                            : AppColors.secondaryText,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        matchScore,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pin_drop,
                        color: AppColors.orangeDark,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          location,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.description,
                        color: AppColors.blueDark,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          type,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule, color: Colors.grey, size: 18),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          time,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activité récente',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyApplicationsScreen(),
                ),
              ),
              child: Text(
                'Tout voir',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blueDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              _buildActivityItem(
                Icons.visibility,
                AppColors.activityViewedBg,
                AppColors.blueDark,
                'Profil consulté par MTN Cameroun',
                'Il y a 1 heure',
              ),
              _buildDivider(),
              _buildActivityItem(
                Icons.task_alt,
                AppColors.activityAppliedBg,
                AppColors.greenDark,
                'Candidature envoyée - Analyste Junior',
                'Il y a 3 heures',
              ),
              _buildDivider(),
              _buildActivityItem(
                Icons.star,
                AppColors.activityMatchedBg,
                AppColors.orangeDark,
                '3 nouveaux matches trouvés',
                'Il y a 1 jour',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    Color bgColor,
    Color iconColor,
    String title,
    String time, {
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: AppColors.dividerColor);
  }

  Widget _buildStatusBadge(String status) {
    OfferStatus offerStatus;
    switch (status.toLowerCase()) {
      case 'en cours':
      case 'active':
        offerStatus = OfferStatus.active;
        break;
      case 'en pause':
      case 'paused':
        offerStatus = OfferStatus.paused;
        break;
      case 'expirée':
      case 'expired':
        offerStatus = OfferStatus.expired;
        break;
      default:
        offerStatus = OfferStatus.active;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: OfferStatusHelper.getStatusBackgroundColor(offerStatus),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: OfferStatusHelper.getStatusColor(offerStatus),
          width: 1,
        ),
      ),
      child: Text(
        OfferStatusHelper.getStatusText(offerStatus),
        style: GoogleFonts.roboto(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: OfferStatusHelper.getStatusColor(offerStatus),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Accueil', 0),
          _buildNavItem(Icons.work, 'Mes offres', 1),
          _buildNavItem(Icons.person, 'Profil', 2),
          _buildNavItem(Icons.settings, 'Paramètres', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected ? AppColors.blueDark : Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.blueDark : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
