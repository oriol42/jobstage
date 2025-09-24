import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../dashboard_screen.dart';
import 'job_preferences_screen.dart';
import 'favorites_screen.dart';
import 'applications_screen.dart';
import 'my_applications_screen.dart';
import 'cv_skills_screen.dart';
import '../services/auth_service.dart';
import '../services/network_config.dart';
import '../theme/theme_provider.dart';
import '../theme/adaptive_colors.dart';
import '../widgets/adaptive_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  bool isLoading = false;
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // CV and Skills data
  List<String> uploadedCVs = [];
  List<String> skills = [];
  final TextEditingController _skillController = TextEditingController();

  // Préférences d'emploi
  String selectedJobType = 'Temps plein';
  String selectedExperienceLevel = 'Junior (1-3 ans)';
  String selectedSalaryRange = '200K - 400K';
  String selectedWorkLocation = 'Yaoundé';
  bool remoteWork = false;
  List<String> preferredIndustries = ['Technologie', 'Finance'];

  // Photo de profil
  File? _profileImage;
  String? _profileImageUrl;
  final ImagePicker _imagePicker = ImagePicker();

  // Pourcentage de complétude du profil
  double profileCompletionPercentage = 0.0;

  // Paramètres de confidentialité
  bool profileVisible = true;
  bool showEmail = false;
  bool showPhone = false;
  bool allowRecruiterContact = true;
  bool shareDataWithPartners = false;

  // Liste des villes du Cameroun
  final List<String> cameroonCities = [
    'Yaoundé',
    'Douala',
    'Bafoussam',
    'Bamenda',
    'Garoua',
    'Maroua',
    'Ngaoundéré',
    'Bertoua',
    'Ebolowa',
    'Kribi',
    'Limbe',
    'Buea',
    'Kumba',
    'Foumban',
    'Dschang',
    'Mbouda',
    'Bandjoun',
    'Bafang',
    'Nkongsamba',
    'Loum',
    'Edéa',
    'Mbalmayo',
    'Sangmélima',
    'Abong-Mbang',
    'Batouri',
    'Yokadouma',
    'Kousséri',
    'Mora',
    'Mokolo',
    'Kaélé',
    'Guider',
    'Pitoa',
    'Lagdo',
    'Tibati',
    'Meiganga',
    'Tignère',
    'Banyo',
    'Mbé',
    'Touboro',
    'Rey-Bouba',
    'Tcholliré',
    'Fundong',
    'Wum',
    'Nkambe',
    'Kumbo',
    'Ndop',
    'Jakiri',
    'Bali',
    'Santa',
    'Bafut',
    'Tubah',
    'Mbengwi',
    'Muyuka',
    'Tiko',
    'Idenau',
    'Mamfe',
    'Eyumojock',
    'Mundemba',
    'Konye',
    'Lebialem',
    'Alou',
    'Bangem',
    'Tombel',
    'Nguti',
    'Melong',
    'Manjo',
    'Penja',
    'Njombé',
    'Kekem',
    'Foumbot',
    'Koutaba',
    'Kouoptamo',
    'Galim',
    'Massangam',
    'Magba',
    'Bangangté',
    'Tonga',
    'Bazou',
    'Baham',
    'Bamendjou',
    'Penka-Michel',
    'Baleveng',
    'Bangou',
    'Batié',
    'Fongo-Tongo',
    'Foto',
    'Santchou',
    'Lebialem',
    'Alou',
    'Bangem',
    'Tombel',
    'Nguti',
    'Kumba',
    'Mbonge',
    'Loum',
    'Penja',
    'Njombé',
    'Dibombari',
    'Yabassi',
    'Pouma',
    'Mouanko',
    'Edéa',
    'Dizangué',
    'Ngwei',
    'Massock-Songloulou',
    'Ndom',
    'Boumnyebel',
    'Makak',
    'Nguibassal',
    'Bangangté',
    'Tonga',
    'Bazou',
    'Baham',
    'Bamendjou',
  ];

  String? selectedLocation = 'Yaoundé';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('Profil: Chargement des données utilisateur...');
    print('Profil: Token disponible: ${_authService.token != null}');
    print('Profil: Utilisateur actuel: ${_authService.currentUser?.username}');

    setState(() {
      isLoading = true;
    });

    try {
      final result = await _authService.getProfile();
      print('Profil: Résultat getProfile: $result');

      if (result['success'] && mounted) {
        final user = result['user'];
        final profile = result['profile'];
        print('Profil: Données utilisateur: ${user.username}');
        print('Profil: Données profil: ${profile?.bio}');

        // Préparer l'URL de l'image en dehors du setState
        String? imageUrl;
        if (profile != null &&
            profile.profilePhoto != null &&
            profile.profilePhoto!.isNotEmpty) {
          if (profile.profilePhoto!.startsWith('http')) {
            imageUrl = profile.profilePhoto;
          } else {
            // Utiliser la détection automatique d'IP
            final imageBaseUrl = await NetworkConfig.getImageBaseUrl();
            imageUrl = '$imageBaseUrl${profile.profilePhoto}';
          }
        }

        setState(() {
          _nameController.text = user.firstName?.isNotEmpty == true
              ? '${user.firstName} ${user.lastName ?? ''}'.trim()
              : user.username;
          _emailController.text = user.email;
          _phoneController.text = user.phone ?? '';

          if (profile != null) {
            _bioController.text = profile.bio ?? '';
            selectedLocation = profile.location ?? 'Yaoundé';

            // Charger le pourcentage de complétude
            profileCompletionPercentage = profile.completionPercentage ?? 0.0;
            print(
              'Profil: Pourcentage de complétude chargé: $profileCompletionPercentage',
            );

            // Utiliser l'URL de l'image préparée
            _profileImageUrl = imageUrl;
            if (profile.skills != null && profile.skills!.isNotEmpty) {
              skills = profile.skills!
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .cast<String>()
                  .toList();
            }
            // Charger les CV existants
            if (profile.cvFile != null && profile.cvFile!.isNotEmpty) {
              uploadedCVs = [profile.cvFile!.split('/').last];
            }
          }

          isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Méthode pour générer les initiales à partir du nom
  String _getInitials() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      // Utiliser le nom de l'utilisateur actuel si disponible
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final userName = currentUser.firstName?.isNotEmpty == true
            ? '${currentUser.firstName} ${currentUser.lastName ?? ''}'.trim()
            : currentUser.username;
        return _generateInitialsFromName(userName);
      }
      return 'U'; // Utilisateur par défaut
    }

    return _generateInitialsFromName(name);
  }

  String _generateInitialsFromName(String name) {
    if (name.isEmpty) return 'U';

    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    } else {
      return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
          .toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (isLoading) {
          return Scaffold(
            backgroundColor: AdaptiveColors.getBackground(
              themeProvider.isDarkMode,
            ),
            appBar: AppBar(
              backgroundColor: AdaptiveColors.getPrimary(
                themeProvider.isDarkMode,
              ),
              foregroundColor: Colors.white,
              title: Text(
                'Mon Profil',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AdaptiveColors.getPrimary(themeProvider.isDarkMode),
                  ),
                  SizedBox(height: 16),
                  AdaptiveText(
                    'Chargement de votre profil...',
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AdaptiveColors.getBackground(
            themeProvider.isDarkMode,
          ),
          appBar: AppBar(
            backgroundColor: AdaptiveColors.getPrimary(
              themeProvider.isDarkMode,
            ),
            foregroundColor: Colors.white,
            title: Text(
              'Mon Profil',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () async {
                  if (isEditing) {
                    // Sauvegarder les modifications
                    await _saveProfile();
                  } else {
                    // Activer le mode édition
                    setState(() {
                      isEditing = true;
                    });
                  }
                },
                icon: Icon(isEditing ? Icons.check : Icons.edit),
                tooltip: isEditing ? 'Sauvegarder' : 'Modifier',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Enhanced Profile header with gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.blueDark, AppColors.blueGradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    children: [
                      // Profile picture with enhanced design
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 65,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.favorisIconColor,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : _profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : null,
                                child:
                                    (_profileImage == null &&
                                        _profileImageUrl == null)
                                    ? Text(
                                        _getInitials(),
                                        style: GoogleFonts.roboto(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          if (isEditing)
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.grey.shade100,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _showImagePickerOptions,
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.blueDark,
                                  ),
                                  tooltip: 'Changer la photo de profil',
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _nameController.text,
                        style: GoogleFonts.roboto(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.email, size: 16, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              _emailController.text.isNotEmpty
                                  ? _emailController.text
                                  : 'Email non renseigné',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildProfileBadge(
                            Icons.location_on,
                            selectedLocation ?? 'Yaoundé',
                          ),
                          const SizedBox(width: 16),
                          _buildProfileBadge(
                            Icons.phone,
                            _formatPhoneNumber(_phoneController.text),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Enhanced Profile completion with animations
                const SizedBox(
                  height: 20,
                ), // Espacement pour détacher du header
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                AppColors.surfaceBg.withValues(alpha: 0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 32,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.greenDark,
                                          AppColors.greenDark.withValues(
                                            alpha: 0.8,
                                          ),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.greenDark.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.trending_up,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Complétude du profil',
                                          style: GoogleFonts.roboto(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          profileCompletionPercentage >= 0.8
                                              ? 'Excellent progrès !'
                                              : profileCompletionPercentage >=
                                                    0.5
                                              ? 'Bon progrès !'
                                              : 'Continuez !',
                                          style: GoogleFonts.roboto(
                                            fontSize: 13,
                                            color:
                                                profileCompletionPercentage >=
                                                    0.8
                                                ? AppColors.greenDark
                                                : profileCompletionPercentage >=
                                                      0.5
                                                ? AppColors.orangeDark
                                                : AppColors.blueDark,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (profileCompletionPercentage >= 0.8
                                                  ? AppColors.greenDark
                                                  : profileCompletionPercentage >=
                                                        0.5
                                                  ? AppColors.orangeDark
                                                  : AppColors.blueDark)
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            (profileCompletionPercentage >= 0.8
                                                    ? AppColors.greenDark
                                                    : profileCompletionPercentage >=
                                                          0.5
                                                    ? AppColors.orangeDark
                                                    : AppColors.blueDark)
                                                .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      '${(profileCompletionPercentage * 100).round()}%',
                                      style: GoogleFonts.roboto(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color:
                                            profileCompletionPercentage >= 0.8
                                            ? AppColors.greenDark
                                            : profileCompletionPercentage >= 0.5
                                            ? AppColors.orangeDark
                                            : AppColors.blueDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: 0.0,
                                  end: profileCompletionPercentage,
                                ),
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
                                          profileCompletionPercentage >= 0.8
                                              ? AppColors.greenDark
                                              : profileCompletionPercentage >=
                                                    0.5
                                              ? AppColors.orangeDark
                                              : AppColors.blueDark,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.blueDark.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.blueDark.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.lightbulb_outline,
                                      color: AppColors.blueDark,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Complétez votre CV et vos compétences pour améliorer vos chances',
                                        style: GoogleFonts.roboto(
                                          fontSize: 13,
                                          color: AppColors.primaryText,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Profile sections
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildProfileSection('Informations personnelles', [
                        _buildProfileField(
                          'Nom complet',
                          _nameController,
                          Icons.person,
                        ),
                        _buildProfileField(
                          'Email',
                          _emailController,
                          Icons.email,
                        ),
                        _buildProfileField(
                          'Téléphone',
                          _phoneController,
                          Icons.phone,
                        ),
                        _buildLocationField(),
                      ]),
                      const SizedBox(height: 20),
                      _buildProfileSection('À propos', [
                        _buildProfileField(
                          'Bio',
                          _bioController,
                          Icons.description,
                          maxLines: 3,
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildStatsSection(),
                      const SizedBox(height: 20),
                      _buildActionsSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(String title, List<Widget> fields) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
          ),
          ...fields,
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: isEditing,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.secondaryText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.blueDark),
              ),
              filled: true,
              fillColor: isEditing ? Colors.white : AppColors.surfaceBg,
            ),
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Localisation',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedLocation,
            onChanged: isEditing
                ? (String? newValue) {
                    setState(() {
                      selectedLocation = newValue;
                    });
                  }
                : null,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.location_on,
                color: AppColors.secondaryText,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.blueDark),
              ),
              filled: true,
              fillColor: isEditing ? Colors.white : AppColors.surfaceBg,
            ),
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AppColors.primaryText,
            ),
            dropdownColor: Colors.white,
            items: cameroonCities.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.primaryText,
                  ),
                ),
              );
            }).toList(),
            hint: Text(
              'Sélectionnez votre ville',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: isEditing ? AppColors.blueDark : AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 20),
          // Utilisation de Flexible pour éviter l'overflow
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Candidatures',
                    '5',
                    AppColors.blueDark,
                    _showCandidatures,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Vues',
                    '12',
                    AppColors.greenDark,
                    _showProfileViews,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Favoris',
                    '3',
                    AppColors.orangeDark,
                    _showFavorites,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100, // Hauteur fixe pour tous les boutons
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Container(
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
        children: [
          _buildActionTile(
            'CV et Compétences',
            'Gérer votre CV et vos compétences',
            Icons.description,
            () => _showCVAndSkillsDialog(),
          ),
          const Divider(height: 1),
          _buildActionTile(
            'Préférences d\'emploi',
            'Définir vos critères de recherche',
            Icons.tune,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JobPreferencesScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.blueDark.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.blueDark),
      ),
      title: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.roboto(fontSize: 14, color: AppColors.secondaryText),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.secondaryText,
      ),
      onTap: onTap,
    );
  }

  void _showCVAndSkillsDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CVSkillsScreen()),
    );
  }

  Widget _buildCVSkillsPage() {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header avec barre de progrès (style HTML exact)
            _buildHTMLHeader(),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Section CV
                  _buildHTMLCVSection(),
                  const SizedBox(height: 30),

                  // Section Compétences
                  _buildHTMLSkillsSection(),
                  const SizedBox(height: 30),

                  // Bouton de sauvegarde
                  _buildHTMLSaveButton(),
                  const SizedBox(height: 30),

                  // Remarque informative en bas de page
                  _buildInfoRemark(),
                  const SizedBox(height: 100), // Espace pour le scroll
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Variables pour la nouvelle interface
  final List<String> _skillSuggestions = [
    'Flutter',
    'JavaScript',
    'Firebase',
    'Leadership',
    'Travail en équipe',
    'Marketing Digital',
    'Python',
    'React',
  ];
  final List<String> _experiences = [
    'Développeur Flutter Junior - TechCorp Solutions - 2023 - Présent',
    'Stage Développement Mobile - Innovation Hub - 2022 - 6 mois',
  ];

  void _uploadCV() async {
    // Version simplifiée pour le design HTML - ouvre directement le sélecteur de fichier
    await _pickFile();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        PlatformFile file = result.files.first;

        // Check file size (5MB limit)
        if (file.size > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Le fichier est trop volumineux. Taille maximale: 5MB',
                  style: GoogleFonts.roboto(),
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        setState(() {
          uploadedCVs.add(file.name);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'CV "${file.name}" ajouté avec succès !',
                      style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.greenDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la sélection du fichier',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteCV(String cvName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Supprimer le CV',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ce CV ?',
          style: GoogleFonts.roboto(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.roboto(color: AppColors.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                uploadedCVs.remove(cvName);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('CV supprimé', style: GoogleFonts.roboto()),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
              'Supprimer',
              style: GoogleFonts.roboto(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadCV(String cvName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Téléchargement de $cvName - Fonctionnalité à venir',
          style: GoogleFonts.roboto(),
        ),
        backgroundColor: AppColors.blueDark,
      ),
    );
  }

  void _addSkill() {
    String skillText = _skillController.text.trim();
    if (skillText.isNotEmpty && !skills.contains(skillText)) {
      setState(() {
        skills.add(skillText);
        _skillController.clear();
      });
      debugPrint(
        'Compétence ajoutée: $skillText, Total: ${skills.length}',
      ); // Debug
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Compétence "$skillText" ajoutée !',
                style: GoogleFonts.roboto(),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF28a745),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (skills.contains(skillText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cette compétence existe déjà',
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez saisir une compétence',
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: const Color(0xFFdc3545),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      skills.remove(skill);
    });
    debugPrint(
      'Compétence supprimée: $skill, Total: ${skills.length}',
    ); // Debug
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete, color: Colors.white),
            const SizedBox(width: 12),
            Text('Compétence "$skill" supprimée', style: GoogleFonts.roboto()),
          ],
        ),
        backgroundColor: const Color(0xFFdc3545),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildCVList() {
    return Column(
      children: uploadedCVs.map((cv) => _buildEnhancedCVItem(cv)).toList(),
    );
  }

  Widget _buildEnhancedCVItem(String cvName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, AppColors.blueDark.withValues(alpha: 0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.blueDark.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueDark.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _downloadCV(cvName),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cvName,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ajouté le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greenDark.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Prêt à l\'emploi',
                          style: GoogleFonts.roboto(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteCV(cvName);
                    } else if (value == 'download') {
                      _downloadCV(cvName);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(
                            Icons.download,
                            size: 18,
                            color: AppColors.blueDark,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Télécharger',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                          const SizedBox(width: 12),
                          Text(
                            'Supprimer',
                            style: GoogleFonts.roboto(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.secondaryText,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySkillsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceBg.withValues(alpha: 0.3),
            AppColors.surfaceBg.withValues(alpha: 0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.greenDark.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_outlined,
              size: 48,
              color: AppColors.greenDark.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune compétence ajoutée',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez vos compétences pour un meilleur\nmatching avec les offres d\'emploi',
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vos compétences (${skills.length})',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: skills
              .map((skill) => _buildEnhancedSkillChip(skill))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEnhancedSkillChip(String skill) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blueDark.withValues(alpha: 0.1),
            AppColors.greenDark.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.blueDark.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueDark.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _removeSkill(skill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.blueDark.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star, size: 12, color: AppColors.blueDark),
                ),
                const SizedBox(width: 10),
                Text(
                  skill,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCVStateModern() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          // Animated upload icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.bounceOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        const Color(0xFF1E40AF).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    size: 56,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Aucun CV ajouté',
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Téléchargez votre CV pour commencer\nà postuler aux meilleures offres',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: const Color(0xFF64748B),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Stylish upload button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _uploadCV,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.upload_file,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Uploader mon CV',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCVListModern() {
    return Column(
      children: uploadedCVs.asMap().entries.map((entry) {
        final index = entry.key;
        final cv = entry.value;
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildModernCVItem(cv),
        );
      }).toList(),
    );
  }

  Widget _buildModernCVItem(String cvName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFFBFCFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _downloadCV(cvName),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // PDF icon with animation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEF4444),
                        const Color(0xFFDC2626),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cvName,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Prêt',
                              style: GoogleFonts.roboto(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.circle,
                            size: 4,
                            color: const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ajouté aujourd\'hui',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteCV(cvName);
                    } else if (value == 'download') {
                      _downloadCV(cvName);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(
                            Icons.download,
                            size: 18,
                            color: const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Télécharger',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete,
                            size: 18,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Supprimer',
                            style: GoogleFonts.roboto(
                              color: const Color(0xFFEF4444),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF64748B),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySkillsStateModern() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.bounceOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981).withValues(alpha: 0.1),
                        const Color(0xFF059669).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology_outlined,
                    size: 56,
                    color: const Color(0xFF10B981),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Aucune compétence',
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Ajoutez vos compétences pour améliorer\nvotre matching avec les employeurs',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: const Color(0xFF64748B),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsListModern() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vos compétences (${skills.length})',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: skills.asMap().entries.map((entry) {
            final index = entry.key;
            final skill = entry.value;
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 50)),
              curve: Curves.easeOutBack,
              child: _buildModernSkillChip(skill),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModernSkillChip(String skill) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6).withValues(alpha: 0.1),
            const Color(0xFF10B981).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _removeSkill(skill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6),
                        const Color(0xFF1E40AF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, size: 10, color: Colors.white),
                ),
                const SizedBox(width: 10),

                Text(
                  skill,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Success Message

  // HTML Style CV Section

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1B1F),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: const Color(0xFF49454F),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentCV() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  uploadedCVs.first,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1B1F),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '2.3 MB',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: const Color(0xFF49454F),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Mis à jour il y a 2h',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: const Color(0xFF49454F),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '✓ Analysé par l\'IA',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: const Color(0xFF49454F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildActionButton(
                Icons.download,
                'Télécharger',
                () => _downloadCV(uploadedCVs.first),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                Icons.delete,
                'Supprimer',
                () => _deleteCV(uploadedCVs.first),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Icon(icon, size: 18, color: const Color(0xFF49454F)),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload,
                color: Color(0xFF1E88E5),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Téléversez votre CV',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C1B1F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Glissez-déposez votre fichier ici ou cliquez pour sélectionner',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: const Color(0xFF49454F),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file, size: 20),
              label: Text(
                'Choisir un fichier',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'PDF, DOC, DOCX jusqu\'à 5MB',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: const Color(0xFF49454F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HTML Style Skills Section

  Widget _buildSkillsInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _skillController,
              decoration: InputDecoration(
                hintText: 'Tapez une compétence (ex: Flutter, Leadership...)',
                hintStyle: GoogleFonts.roboto(color: const Color(0xFF49454F)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black),
              onSubmitted: (value) => _addSkill(),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            child: Material(
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _addSkill,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSuggestions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _skillSuggestions.map((suggestion) {
        return GestureDetector(
          onTap: () => _addSuggestedSkill(suggestion),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.transparent),
            ),
            child: Text(
              suggestion,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E88E5),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentSkills() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                skill,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _removeSkill(skill),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // HTML Style Experience Section

  Widget _buildExperienceItem(String experience) {
    final parts = experience.split(' - ');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parts[0],
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1B1F),
                  ),
                ),
                const SizedBox(height: 4),
                if (parts.length > 1)
                  Text(
                    parts[1],
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: const Color(0xFF1E88E5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (parts.length > 2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                parts[2],
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: const Color(0xFF49454F),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddExperienceButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.add, color: Color(0xFF49454F), size: 24),
          const SizedBox(height: 8),
          Text(
            'Ajouter une expérience',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color(0xFF49454F),
            ),
          ),
        ],
      ),
    );
  }

  void _addSuggestedSkill(String skill) {
    if (!skills.contains(skill)) {
      setState(() {
        skills.add(skill);
      });
    }
  }

  Widget _buildProfileBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Préférences d'emploi avec libellés et icônes

  // Paramètres de confidentialité

  // Widget helper pour les dropdowns compacts

  // Widget helper pour les dropdowns

  // Widget pour les cartes de préférences avec icônes

  // Dropdown compact pour éviter les overflows

  // Méthode pour formater le numéro de téléphone
  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return 'Téléphone non renseigné';

    // Si le numéro commence par 237, ajouter le + et l'espace
    if (phone.startsWith('237')) {
      return '+237 ${phone.substring(3)}';
    }
    // Si le numéro commence par +237, ajouter l'espace
    else if (phone.startsWith('+237')) {
      return '+237 ${phone.substring(4)}';
    }
    // Sinon, retourner tel quel
    return phone;
  }

  // Méthode pour sauvegarder le profil
  Future<void> _saveProfile() async {
    try {
      print('💾 Sauvegarde du profil...');

      // Extraire le prénom et nom du nom complet
      String fullName = _nameController.text.trim();
      String firstName = '';
      String lastName = '';

      if (fullName.isNotEmpty) {
        List<String> nameParts = fullName.split(' ');
        firstName = nameParts[0];
        if (nameParts.length > 1) {
          lastName = nameParts.sublist(1).join(' ');
        }
      }

      // Mettre à jour les informations utilisateur
      String phoneValue = _phoneController.text.trim();
      print('📞 Téléphone à sauvegarder: "$phoneValue"');

      final userResult = await _authService.updateUserInfo(
        firstName: firstName.isNotEmpty ? firstName : null,
        lastName: lastName.isNotEmpty ? lastName : null,
        phone: phoneValue.isNotEmpty ? phoneValue : null,
      );

      if (userResult['success']) {
        print('✅ Informations utilisateur mises à jour');
      } else {
        print('❌ Erreur mise à jour utilisateur: ${userResult['message']}');
      }

      // Mettre à jour le profil candidat
      final profileResult = await _authService.updateCandidateProfile(
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
        location: selectedLocation != 'Yaoundé' ? selectedLocation : null,
      );

      if (profileResult['success']) {
        print('✅ Profil candidat mis à jour');
      } else {
        print('❌ Erreur mise à jour profil: ${profileResult['message']}');
      }

      // Désactiver le mode édition
      setState(() {
        isEditing = false;
      });

      // Recharger les données pour s'assurer que tout est synchronisé
      await _loadUserData();

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profil mis à jour avec succès !',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: AppColors.greenDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('💥 Erreur sauvegarde profil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la sauvegarde: ${e.toString()}',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Méthode pour uploader la photo de profil
  Future<void> _uploadProfilePhoto(File photoFile) async {
    try {
      print('📸 Upload de la photo de profil...');
      final result = await _authService.uploadProfilePhoto(photoFile);

      if (result['success']) {
        print('✅ Photo uploadée avec succès: ${result['photo_url']}');
        setState(() {
          _profileImageUrl = result['photo_url'];
          // Garder aussi la référence locale pour l'affichage immédiat
          _profileImage = photoFile;
        });
      } else {
        print('❌ Erreur upload photo: ${result['message']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur lors de l\'upload: ${result['message']}',
                style: GoogleFonts.roboto(),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('💥 Erreur upload photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur de connexion lors de l\'upload',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Méthode pour afficher les options de photo de profil
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choisir une photo de profil',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageOption(
                    Icons.camera_alt,
                    'Prendre une photo',
                    () {
                      Navigator.pop(context);
                      _takeProfilePhoto();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageOption(Icons.photo_library, 'Galerie', () {
                    Navigator.pop(context);
                    _pickProfileImage();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_profileImage != null)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _profileImage = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Photo de profil supprimée',
                          style: GoogleFonts.roboto(),
                        ),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: Text(
                    'Supprimer la photo',
                    style: GoogleFonts.roboto(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.blueDark.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.blueDark.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.blueDark, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.blueDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour importer une photo de profil
  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });

        // Uploader la photo vers le backend
        await _uploadProfilePhoto(File(image.path));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Photo de profil mise à jour',
                style: GoogleFonts.roboto(),
              ),
              backgroundColor: AppColors.greenDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la sélection de l\'image',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Méthode pour prendre une photo avec la caméra
  Future<void> _takeProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });

        // Uploader la photo vers le backend
        await _uploadProfilePhoto(File(image.path));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Photo de profil prise avec succès',
                style: GoogleFonts.roboto(),
              ),
              backgroundColor: AppColors.greenDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la prise de photo',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Méthodes pour les éléments cliquables du conteneur statistique
  void _showCandidatures() {
    // Navigation vers la page des candidatures existante
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyApplicationsScreen()),
    );
  }

  void _showProfileViews() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.greenDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.visibility, color: AppColors.greenDark),
            ),
            const SizedBox(width: 12),
            Text(
              'Vues du profil',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewerItem('TechCorp', 'Il y a 2 heures', Icons.business),
              _buildViewerItem('StartupX', 'Il y a 1 jour', Icons.business),
              _buildViewerItem('Marie Dubois', 'Il y a 2 jours', Icons.person),
              _buildViewerItem('BigCorp', 'Il y a 3 jours', Icons.business),
              _buildViewerItem('Jean Martin', 'Il y a 1 semaine', Icons.person),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer', style: GoogleFonts.roboto()),
          ),
        ],
      ),
    );
  }

  void _showFavorites() {
    // Navigation vers la page des favoris existante
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritesScreen()),
    );
  }

  Widget _buildViewerItem(String nom, String temps, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blueDark, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nom,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            temps,
            style: GoogleFonts.roboto(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // =================== DESIGN HTML MATERIAL 3 ===================

  // Variables pour la progression et l'état
  double _calculateProgress() {
    double progress = 0.0;
    if (uploadedCVs.isNotEmpty) progress += 0.5; // 50% pour le CV
    if (skills.isNotEmpty) progress += 0.5; // 50% pour les compétences
    return progress;
  }

  // Header avec gradient bleu et barre de progression (comme HTML)
  Widget _buildHTMLHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF007bff), Color(0xFF0056b3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Bouton retour
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Titre centré
              Text(
                'Complétez votre profil',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Sous-titre
              Text(
                'Mettez toutes les chances de votre côté',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Barre de progression
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _calculateProgress(),
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section CV avec design HTML exact
  Widget _buildHTMLCVSection() {
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Barre colorée en haut (gradient HTML)
                  Container(
                    height: 4,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF007bff),
                          Color(0xFF28a745),
                          Color(0xFFffc107),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre de section avec icône emoji et style HTML
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF007bff),
                                    Color(0xFF0056b3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF007bff,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '📄',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              'Votre CV',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2c3e50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Zone d'upload ou fichier uploadé
                        if (uploadedCVs.isEmpty)
                          _buildHTMLUploadZone()
                        else
                          _buildHTMLUploadedFile(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Zone d'upload avec style HTML exact et animations
  Widget _buildHTMLUploadZone() {
    return GestureDetector(
      onTap: _uploadCV,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: const Color(0x000ffddd),
          strokeWidth: 2,
          dashWidth: 8,
          dashSpace: 4,
          borderRadius: 15,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [
                Color(0x0D007bff), // rgba(0, 123, 255, 0.05)
                Color(0x0D28a745), // rgba(40, 167, 69, 0.05)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // Icône avec animation bounce comme dans HTML
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -10 * (1 - value) * value),
                    child: const Text(
                      '📁',
                      style: TextStyle(fontSize: 48, color: Color(0xFF007bff)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              Text(
                'Cliquez pour ajouter votre CV',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0x000ff666),
                ),
              ),
              const SizedBox(height: 10),

              Text(
                'Formats acceptés: PDF, DOC, DOCX (max 5MB)',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: const Color(0x000ff999),
                ),
              ),
              const SizedBox(height: 20),

              // Bouton avec contour en traits discontinus pour indiquer l'import
              CustomPaint(
                painter: DashedBorderPainter(
                  color: const Color(0xFF007bff),
                  strokeWidth: 2,
                  dashWidth: 8,
                  dashSpace: 4,
                  borderRadius: 25,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    // Fond transparent avec léger gradient
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF007bff).withValues(alpha: 0.05),
                        const Color(0xFF0056b3).withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: _uploadCV,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.upload_file,
                              color: const Color(0xFF007bff),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ajouter votre CV',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF007bff),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Affichage du fichier uploadé avec style HTML
  Widget _buildHTMLUploadedFile() {
    final cvName = uploadedCVs.first;
    final fileExtension = cvName.split('.').last.toLowerCase();
    String fileIcon = '📄';
    if (fileExtension == 'pdf') fileIcon = '📄';
    if (fileExtension == 'doc' || fileExtension == 'docx') fileIcon = '📝';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8f9fa),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // Icône du fichier avec gradient vert
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF28a745), Color(0xFF218838)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(fileIcon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),

            // Infos du fichier
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cvName,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2.3 MB', // Taille simulée comme HTML
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: const Color(0x000ff666),
                    ),
                  ),
                ],
              ),
            ),

            // Bouton de suppression rouge rond
            GestureDetector(
              onTap: () => _deleteCV(cvName),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFdc3545),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    '×',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section compétences avec style HTML exact
  Widget _buildHTMLSkillsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre colorée en haut
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF007bff),
                  Color(0xFF28a745),
                  Color(0xFFffc107),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre avec icône emoji
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF007bff), Color(0xFF0056b3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF007bff,
                            ).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🎯', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Vos compétences',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2c3e50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Input avec bouton + intégré (style HTML exact)
                _buildHTMLSkillsInput(),
                const SizedBox(height: 20),

                // Affichage des compétences ou état vide
                _buildHTMLSkillsDisplay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Input des compétences avec design HTML exact
  Widget _buildHTMLSkillsInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: _skillController,
            decoration: InputDecoration(
              hintText: 'Tapez une compétence et appuyez sur Entrée',
              hintStyle: GoogleFonts.roboto(color: const Color(0x000ff999)),
              filled: true,
              fillColor: const Color(0xFFF8f9fa),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(
                  color: Color(0xFFe1e8ed),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(
                  color: Color(0xFFe1e8ed),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(
                  color: Color(0xFF007bff),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.fromLTRB(15, 15, 60, 15),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _addSkillHTML();
              }
            },
          ),

          // Bouton + avec gradient vert positionné à droite
          Positioned(
            right: 5,
            top: 5,
            bottom: 5,
            child: GestureDetector(
              onTap: _addSkillHTML,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF28a745), Color(0xFF218838)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF28a745).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Affichage des compétences avec style HTML
  Widget _buildHTMLSkillsDisplay() {
    debugPrint(
      '_buildHTMLSkillsDisplay appelée, skills.length: ${skills.length}',
    ); // Debug
    if (skills.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8f9fa),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x000ffddd), width: 2),
        ),
        child: Center(
          child: Text(
            'Ajoutez vos compétences pour attirer l\'attention des recruteurs',
            style: GoogleFonts.roboto(
              color: const Color(0x000ff666),
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: skills.map((skill) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF007bff), Color(0xFF0056b3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007bff).withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skill,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeSkillHTML(skill),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            '×',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Bouton de sauvegarde avec style HTML exact
  Widget _buildHTMLSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF28a745), Color(0xFF218838)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28a745).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => _saveHTMLProfile(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text(
                'Enregistrer mon profil',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Méthode de sauvegarde avec feedback HTML
  Future<void> _saveHTMLProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Séparer le nom complet en prénom et nom
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      // Mettre à jour les informations utilisateur de base
      final userResult = await _authService.updateUserInfo(
        firstName: firstName,
        lastName: lastName,
        phone: _phoneController.text.trim(),
      );

      if (!userResult['success']) {
        throw Exception(userResult['message']);
      }

      // Mettre à jour le profil candidat
      final profileResult = await _authService.updateCandidateProfile(
        bio: _bioController.text.trim(),
        location: selectedLocation,
        skills: skills.join(', '),
      );

      if (!profileResult['success']) {
        throw Exception(profileResult['message']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Profil sauvegardé avec succès! 🎉',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF28a745),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        setState(() {
          isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la sauvegarde: ${e.toString()}',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFFdc3545),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Upload simplifié comme dans HTML (méthode existante utilisée)

  // Méthode spécifique pour ajouter une compétence dans le design HTML
  void _addSkillHTML() {
    String skillText = _skillController.text.trim();
    debugPrint('Tentative d\'ajout de compétence: "$skillText"'); // Debug

    if (skillText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez saisir une compétence',
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: const Color(0xFFdc3545),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (skills.contains(skillText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cette compétence existe déjà',
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    debugPrint('Avant ajout - skills: $skills'); // Debug

    // Ajout avec setState pour forcer le refresh COMPLET
    setState(() {
      skills = List<String>.from(skills)
        ..add(skillText); // Créer une nouvelle liste
      _skillController.clear();
      debugPrint('Dans setState - skills: $skills'); // Debug
    });

    // Forcer un refresh supplémentaire après un court délai
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          // Force un rebuild complet
        });
      }
    });

    debugPrint(
      'Après setState - Compétence ajoutée: "$skillText", Total: ${skills.length}',
    ); // Debug

    // Message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Compétence "$skillText" ajoutée !',
              style: GoogleFonts.roboto(),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF28a745),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Remarque informative en bas de page
  Widget _buildInfoRemark() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8f9fa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF17a2b8).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17a2b8).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône d'information importante
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF17a2b8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF17a2b8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Texte de la remarque
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Information importante',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF17a2b8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tâchez de bien écrire vos compétences, cela pour faciliter la recherche de recruteurs appropriés pour vous.',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: const Color(0xFF495057),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Méthode spécifique pour supprimer une compétence dans le design HTML
  void _removeSkillHTML(String skill) {
    debugPrint('Tentative de suppression de compétence: "$skill"'); // Debug
    debugPrint('Avant suppression - skills: $skills'); // Debug

    setState(() {
      skills = List<String>.from(skills)
        ..remove(skill); // Créer une nouvelle liste
      debugPrint('Dans setState suppression - skills: $skills'); // Debug
    });

    // Forcer un refresh supplémentaire après un court délai
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          // Force un rebuild complet
        });
      }
    });

    debugPrint(
      'Après setState - Compétence supprimée: "$skill", Total: ${skills.length}',
    ); // Debug

    // Message de suppression
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text('Compétence "$skill" supprimée', style: GoogleFonts.roboto()),
          ],
        ),
        backgroundColor: const Color(0xFFdc3545),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Classe pour dessiner un contour en traits discontinus
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            strokeWidth / 2,
            strokeWidth / 2,
            size.width - strokeWidth,
            size.height - strokeWidth,
          ),
          Radius.circular(borderRadius),
        ),
      );

    // Dessiner les traits discontinus
    _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final end = distance + (draw ? dashWidth : dashSpace);
        if (draw) {
          final segment = metric.extractPath(
            distance,
            end.clamp(0.0, metric.length),
          );
          canvas.drawPath(segment, paint);
        }
        distance = end;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
