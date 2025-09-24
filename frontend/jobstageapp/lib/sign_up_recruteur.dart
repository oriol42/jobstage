import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'theme/theme_provider.dart';
import 'loginscreen.dart';

class JobstageSignupScreen extends StatefulWidget {
  const JobstageSignupScreen({super.key});

  @override
  _JobstageSignupScreenState createState() => _JobstageSignupScreenState();
}

class _JobstageSignupScreenState extends State<JobstageSignupScreen> {
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nuiController = TextEditingController();
  final _phoneController = TextEditingController(text: '+237');
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _cenadiCertification = false;
  String _selectedSector = '';
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _register() async {
    // Validation des champs obligatoires
    if (_nuiController.text.trim().isEmpty) {
      _showErrorDialog('Veuillez saisir le NUI de l\'entreprise');
      return;
    }

    if (_companyNameController.text.trim().isEmpty) {
      _showErrorDialog('Veuillez saisir le nom de l\'entreprise');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('Veuillez saisir l\'adresse email de l\'entreprise');
      return;
    }

    // Validation de l'email
    if (!_isValidEmail(_emailController.text.trim())) {
      _showErrorDialog('Veuillez saisir une adresse email valide');
      return;
    }

    if (_phoneController.text.trim().isEmpty ||
        _phoneController.text.trim() == '+237') {
      _showErrorDialog('Veuillez saisir le numéro de téléphone');
      return;
    }

    // Validation du téléphone
    if (!_isValidPhone(_phoneController.text.trim())) {
      _showErrorDialog('Veuillez saisir un numéro de téléphone valide');
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      _showErrorDialog('Veuillez saisir l\'adresse de l\'entreprise');
      return;
    }

    if (_selectedSector.isEmpty) {
      _showErrorDialog('Veuillez sélectionner le secteur d\'activité');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorDialog('Veuillez saisir un mot de passe');
      return;
    }

    // Validation du mot de passe
    if (_passwordController.text.length < 8) {
      _showErrorDialog('Le mot de passe doit contenir au moins 8 caractères');
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      _showErrorDialog('Veuillez confirmer le mot de passe');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Les mots de passe ne correspondent pas');
      return;
    }

    if (!_acceptTerms) {
      _showErrorDialog('Veuillez accepter les conditions d\'utilisation');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.register(
        username: _companyNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        passwordConfirm: _confirmPasswordController.text,
        userType: 'recruteur',
        companyName: _companyNameController.text,
        companySector: _selectedSector,
        companyAddress: _addressController.text,
        companyWebsite: _websiteController.text,
      );

      if (result['success'] == true) {
        if (mounted) {
          _showSuccessDialog('Inscription réussie !');
          // Rediriger vers l'écran de connexion après inscription
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const JobstageLoginScreen(userType: 'recruteur'),
            ),
          );
        }
      } else {
        if (mounted) {
          _showErrorDialog(
            result['message'] ?? 'Erreur lors de l\'inscription',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Une erreur inattendue s\'est produite';

        if (e.toString().contains('SocketException')) {
          errorMessage =
              'Problème de connexion. Vérifiez votre connexion internet.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'La requête a pris trop de temps. Veuillez réessayer.';
        } else if (e.toString().contains('FormatException')) {
          errorMessage = 'Erreur de format des données. Veuillez réessayer.';
        } else {
          errorMessage = 'Erreur: ${e.toString()}';
        }

        _showErrorDialog(errorMessage);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Validation de l'email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validation du téléphone
  bool _isValidPhone(String phone) {
    // Supprimer les espaces et caractères spéciaux
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    // Vérifier que le numéro commence par +237 et contient au moins 13 caractères au total
    return cleanPhone.startsWith('+237') &&
        cleanPhone.length >= 13 &&
        cleanPhone.length <= 16;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(
                'Erreur',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text(
                'Succès',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode
              ? Colors.grey[900]
              : Color(0xFFF5F5F5),
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                // Header with logo
                Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 0),
                  child: Image.asset(
                    'assets/images/jobstage_logo.png',
                    width: 400,
                    height: 150,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'Jobstage',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      );
                    },
                  ),
                ),

                // Main content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3),

                      // Title
                      Center(
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Color(0xFF303F9F),
                          ),
                        ),
                      ),

                      SizedBox(height: 8),

                      // Subtitle
                      Center(
                        child: Text(
                          'creez votre compte entreprise',
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.isDarkMode
                                ? Colors.grey[400]
                                : Color(0xFF757575),
                          ),
                        ),
                      ),

                      SizedBox(height: 0),

                      // NUI
                      _buildFormField(
                        label: 'NUI*',
                        hintText: 'Numéro d\'identification unique',
                        controller: _nuiController,
                        themeProvider: themeProvider,
                      ),

                      SizedBox(height: 11),

                      // Company Name
                      _buildFormField(
                        label: 'Nom de l\'entreprise*',
                        hintText: 'Nom de votre entreprise',
                        controller: _companyNameController,
                        themeProvider: themeProvider,
                      ),

                      SizedBox(height: 11),

                      // Email
                      _buildFormField(
                        label: 'Email*',
                        hintText: 'contact@entreprise.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        themeProvider: themeProvider,
                      ),

                      SizedBox(height: 11),

                      // Phone
                      _buildFormField(
                        label: 'Téléphone*',
                        hintText: '6XX XX XX XX',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        themeProvider: themeProvider,
                      ),

                      SizedBox(height: 11),

                      // Website
                      _buildFormField(
                        label: 'Site web',
                        hintText: 'https://www.entreprise.com',
                        controller: _websiteController,
                        keyboardType: TextInputType.url,
                        themeProvider: themeProvider,
                      ),

                      SizedBox(height: 11),

                      // Address
                      _buildFormField(
                        label: 'Adresse*',
                        hintText: 'Adresse complète de l\'entreprise',
                        controller: _addressController,
                        maxLines: 2,
                        themeProvider: themeProvider,
                      ),

                      SizedBox(height: 11),

                      // Sector
                      _buildDropdownField(
                        label: 'Secteur d\'activité*',
                        hintText: 'Sélectionnez votre secteur',
                        value: _selectedSector,
                        onChanged: (value) {
                          setState(() {
                            _selectedSector = value ?? '';
                          });
                        },
                        themeProvider: themeProvider,
                      ),

                      SizedBox(height: 11),

                      // Password
                      _buildPasswordField(
                        label: 'Mot de passe*',
                        hintText: '8+ caractères',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onToggle: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        themeProvider: themeProvider,
                      ),

                      SizedBox(height: 11),

                      // Confirm Password
                      _buildPasswordField(
                        label: 'Confirmer le mot de passe*',
                        hintText: 'Confirmer le mot de passe',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        onToggle: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        themeProvider: themeProvider,
                      ),

                      SizedBox(height: 14),

                      // Terms and conditions
                      _buildCheckbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        text: "j'accepte les ",
                        linkText1: "conditions d'utilisation",
                        middleText: " et la ",
                        linkText2: "politique de confidentialité",
                        endText: " de JOBSTAGE",
                        themeProvider: themeProvider,
                      ),

                      SizedBox(height: 9),

                      // CENADI Certification
                      _buildCheckbox(
                        value: _cenadiCertification,
                        onChanged: (value) {
                          setState(() {
                            _cenadiCertification = value ?? false;
                          });
                        },
                        text: "J'ai une certification CENADI",
                        themeProvider: themeProvider,
                      ),

                      SizedBox(height: 9),

                      // Register button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF69F0AE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'ENREGISTRER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Lien vers la connexion
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Vous avez déjà un compte ? ",
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[400]
                                    : Color(0xFF757575),
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const JobstageLoginScreen(
                                          userType: 'recruteur',
                                        ),
                                  ),
                                );
                              },
                              child: Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: Color(0xFF2196F3),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),
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

  Widget _buildFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    required ThemeProvider themeProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? Colors.grey[600]!
                  : Color(0xFFE0E0E0),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            textInputAction: maxLines > 1
                ? TextInputAction.newline
                : TextInputAction.next,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.grey[400]
                    : Color(0xFF9E9E9E),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required ThemeProvider themeProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? Colors.grey[600]!
                  : Color(0xFFE0E0E0),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.grey[400]
                    : Color(0xFF9E9E9E),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF757575),
                ),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hintText,
    required String value,
    required ValueChanged<String?> onChanged,
    required ThemeProvider themeProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? Colors.grey[600]!
                  : Color(0xFFE0E0E0),
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value.isEmpty ? null : value,
            onChanged: onChanged,
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.grey[400]
                    : Color(0xFF9E9E9E),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items:
                [
                  'Technologie',
                  'Finance',
                  'Santé',
                  'Éducation',
                  'Commerce',
                  'Industrie',
                  'Services',
                  'Autre',
                ].map((String sector) {
                  return DropdownMenuItem<String>(
                    value: sector,
                    child: Text(
                      sector,
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: themeProvider.isDarkMode
                  ? Colors.grey[400]
                  : Color(0xFF757575),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    String? linkText1,
    String? middleText,
    String? linkText2,
    String? endText,
    required ThemeProvider themeProvider,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFF2196F3),
          checkColor: Colors.white,
          fillColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.selected)) {
              return Color(0xFF2196F3);
            }
            return Colors.transparent;
          }),
          side: BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.grey[400]
                    : Color(0xFF757575),
                fontSize: 14,
              ),
              children: [
                TextSpan(text: text),
                if (linkText1 != null)
                  TextSpan(
                    text: linkText1,
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                if (middleText != null) TextSpan(text: middleText),
                if (linkText2 != null)
                  TextSpan(
                    text: linkText2,
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                if (endText != null) TextSpan(text: endText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'Jobstage Signup',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: JobstageSignupScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
