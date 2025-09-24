import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'dashboard_screen.dart';
import 'sign_up_candidat.dart' as candidat;
import 'sign_up_recruteur.dart';
import 'theme/theme_provider.dart';
import 'screens/recruiter/recruiter_navigation.dart';

class JobstageLoginScreen extends StatefulWidget {
  final String? userType; // 'candidat' ou 'recruteur'

  const JobstageLoginScreen({super.key, this.userType});

  @override
  _JobstageLoginScreenState createState() => _JobstageLoginScreenState();
}

class _JobstageLoginScreenState extends State<JobstageLoginScreen> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _keepSignedIn = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _login() async {
    print('=== DÉBUT DE LA CONNEXION ===');
    print('Email/Phone: ${_emailOrPhoneController.text}');
    print('Password: ${_passwordController.text}');

    if (_emailOrPhoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      print('Champs vides détectés');
      _showErrorDialog('Veuillez remplir tous les champs');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Tentative de connexion...');
      final result = await _authService.login(
        email: _emailOrPhoneController.text,
        password: _passwordController.text,
      );

      print('Résultat de la connexion: $result');

      if (result['success'] == true) {
        print('Connexion réussie !');
        if (mounted) {
          _showSuccessDialog('Connexion réussie !');

          // Rediriger vers le bon dashboard selon le type d'utilisateur
          final userType = result['user_type'] ?? 'candidat';
          print('Type d\'utilisateur: $userType');

          if (userType == 'recruteur') {
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
        }
      } else {
        print('Échec de la connexion: ${result['message']}');
        if (mounted) {
          _showErrorDialog(result['message'] ?? 'Erreur lors de la connexion');
        }
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      if (mounted) {
        _showErrorDialog('Erreur: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
          title: Text('Succès'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir la taille de l'écran
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode
              ? Colors.grey[900]
              : Colors.white,
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Column(
                children: [
                  // Header with logo - adapté pour mobile
                  SizedBox(
                    height: screenHeight * 0.25, // 25% de la hauteur d'écran
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.05),
                        child: Image.asset(
                          'assets/images/jobstage_logo.png',
                          width: screenWidth * 0.6, // 60% de la largeur d'écran
                          height:
                              screenHeight * 0.15, // 15% de la hauteur d'écran
                          fit: BoxFit.contain,
                          colorBlendMode: BlendMode.dstOver,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback si l'image n'existe pas
                            return Text(
                              'Jobstage',
                              style: TextStyle(
                                fontSize:
                                    screenWidth *
                                    0.08, // 8% de la largeur d'écran
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Main content - adapté pour mobile
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                    ), // 6% de la largeur
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: screenHeight * 0.02,
                        ), // 2% de la hauteur
                        // Welcome text
                        Center(
                          child: Text(
                            'Bienvenue !',
                            style: TextStyle(
                              fontSize: screenWidth * 0.08, // 8% de la largeur
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.01,
                        ), // 1% de la hauteur

                        Center(
                          child: Text(
                            'Connectez-vous à votre compte',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04, // 4% de la largeur
                              color: themeProvider.isDarkMode
                                  ? Colors.grey[400]
                                  : Color(0xFF757575),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.03,
                        ), // 3% de la hauteur
                        // Email field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: themeProvider.isDarkMode
                                  ? Colors.grey[600]!
                                  : Color(0xFFE0E0E0),
                            ),
                          ),
                          child: TextField(
                            controller: _emailOrPhoneController,
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: screenWidth * 0.035,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Email ou Téléphone',
                              hintStyle: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[400]
                                    : Color(0xFF9E9E9E),
                                fontSize:
                                    screenWidth * 0.035, // 3.5% de la largeur
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal:
                                    screenWidth * 0.05, // 5% de la largeur
                                vertical:
                                    screenHeight * 0.02, // 2% de la hauteur
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.015,
                        ), // 1.5% de la hauteur
                        // Password field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: themeProvider.isDarkMode
                                  ? Colors.grey[600]!
                                  : Color(0xFFE0E0E0),
                            ),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: screenWidth * 0.035,
                            ),
                            decoration: InputDecoration(
                              hintText: 'password',
                              hintStyle: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[400]
                                    : Color(0xFF9E9E9E),
                                fontSize:
                                    screenWidth * 0.035, // 3.5% de la largeur
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal:
                                    screenWidth * 0.05, // 5% de la largeur
                                vertical:
                                    screenHeight * 0.02, // 2% de la hauteur
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Color(0xFF757575),
                                  size: screenWidth * 0.05, // 5% de la largeur
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.02,
                        ), // 2% de la hauteur
                        // Keep signed in checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _keepSignedIn,
                              onChanged: (value) {
                                setState(() {
                                  _keepSignedIn = value ?? false;
                                });
                              },
                              activeColor: Color(0xFF2196F3),
                              checkColor: Colors.white,
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Color(0xFF2196F3);
                                  }
                                  return Colors.transparent;
                                },
                              ),
                              side: BorderSide(
                                color: Color(0xFF2196F3),
                                width: 2,
                              ),
                            ),
                            Text(
                              'Se souvenir de moi',
                              style: TextStyle(
                                fontSize:
                                    screenWidth * 0.035, // 3.5% de la largeur
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[400]
                                    : Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: screenHeight * 0.02,
                        ), // 2% de la hauteur
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.06, // 6% de la hauteur
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF69F0AE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width:
                                        screenWidth * 0.05, // 5% de la largeur
                                    height:
                                        screenWidth * 0.05, // 5% de la largeur
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'SE CONNECTER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          screenWidth *
                                          0.04, // 4% de la largeur
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.02,
                        ), // 2% de la hauteur
                        // Forgot password
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Handle forgot password
                            },
                            child: Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                color: Color(0xFF2196F3),
                                fontSize:
                                    screenWidth * 0.035, // 3.5% de la largeur
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.02,
                        ), // 2% de la hauteur
                        // Separator
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[600]
                                    : Color(0xFFE0E0E0),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                              ),
                              child: Text(
                                'ou',
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.grey[400]
                                      : Color(0xFF757575),
                                  fontSize:
                                      screenWidth * 0.035, // 3.5% de la largeur
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[600]
                                    : Color(0xFFE0E0E0),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: screenHeight * 0.02,
                        ), // 2% de la hauteur
                        // Google button
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.06, // 6% de la hauteur
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle Google sign in
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: themeProvider.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                              side: BorderSide(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[600]!
                                    : Color(0xFFE0E0E0),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo Google
                                Image.asset(
                                  'assets/images/google_logo.png',
                                  width: screenWidth * 0.05, // 5% de la largeur
                                  height:
                                      screenWidth * 0.05, // 5% de la largeur
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width:
                                          screenWidth *
                                          0.05, // 5% de la largeur
                                      height:
                                          screenWidth *
                                          0.05, // 5% de la largeur
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF4285F4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'G',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                screenWidth *
                                                0.03, // 3% de la largeur
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: screenWidth * 0.02,
                                ), // 2% de la largeur
                                Text(
                                  'Continuer avec Google',
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Color(0xFF212121),
                                    fontSize:
                                        screenWidth *
                                        0.035, // 3.5% de la largeur
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.02,
                        ), // 2% de la hauteur
                        // Facebook button
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.06, // 6% de la hauteur
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle Facebook sign in
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: themeProvider.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                              side: BorderSide(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[600]!
                                    : Color(0xFFE0E0E0),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo Facebook
                                Image.asset(
                                  'assets/images/facebook_logo.png',
                                  width: screenWidth * 0.05, // 5% de la largeur
                                  height:
                                      screenWidth * 0.05, // 5% de la largeur
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width:
                                          screenWidth *
                                          0.05, // 5% de la largeur
                                      height:
                                          screenWidth *
                                          0.05, // 5% de la largeur
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF1877F2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'f',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                screenWidth *
                                                0.03, // 3% de la largeur
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: screenWidth * 0.02,
                                ), // 2% de la largeur
                                Text(
                                  'Continuer avec Facebook',
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Color(0xFF212121),
                                    fontSize:
                                        screenWidth *
                                        0.035, // 3.5% de la largeur
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.03,
                        ), // 3% de la hauteur
                        // Footer
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Vous n'avez pas de compte ? ",
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.grey[400]
                                      : Color(0xFF757575),
                                  fontSize:
                                      screenWidth * 0.035, // 3.5% de la largeur
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Rediriger vers la bonne inscription selon le type d'utilisateur
                                  if (widget.userType == 'recruteur') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const JobstageSignupScreen(),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const candidat.JobstageSignupScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  'S\'inscrire',
                                  style: TextStyle(
                                    color: Color(0xFF2196F3),
                                    fontSize:
                                        screenWidth *
                                        0.035, // 3.5% de la largeur
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.01,
                        ), // 1% de la hauteur
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
}
