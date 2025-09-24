import 'package:flutter/material.dart';
import 'loginscreen.dart';
import 'services/auth_service.dart';

class JobstageSignupScreen extends StatefulWidget {
  const JobstageSignupScreen({super.key});

  @override
  _JobstageSignupScreenState createState() => _JobstageSignupScreenState();
}

class _JobstageSignupScreenState extends State<JobstageSignupScreen> {
  final TextEditingController _nuiController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(
    text: '+237',
  );
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _register() async {
    // Validation des champs obligatoires
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Veuillez saisir votre nom complet');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('Veuillez saisir votre adresse email');
      return;
    }

    // Validation de l'email
    if (!_isValidEmail(_emailController.text.trim())) {
      _showErrorDialog('Veuillez saisir une adresse email valide');
      return;
    }

    if (_phoneController.text.trim().isEmpty ||
        _phoneController.text.trim() == '+237') {
      _showErrorDialog('Veuillez saisir votre numéro de téléphone');
      return;
    }

    // Validation du téléphone
    if (!_isValidPhone(_phoneController.text.trim())) {
      _showErrorDialog('Veuillez saisir un numéro de téléphone valide');
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
      _showErrorDialog('Veuillez confirmer votre mot de passe');
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
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirm: _confirmPasswordController.text,
        userType: 'candidat',
      );

      if (result['success']) {
        if (mounted) {
          _showSuccessDialog(
            'Inscription réussie ! Vous pouvez maintenant vous connecter.',
          );
          // Naviguer vers l'écran de connexion
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const JobstageLoginScreen(),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with logo
            Padding(
              padding: EdgeInsets.only(top: 22, bottom: 0),
              child: Image.asset(
                'assets/images/jobstage_logo.png',
                width: 350,
                height: 110,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'Jobstage',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF303F9F),
                      ),
                    ),
                  ),

                  SizedBox(height: 5),

                  // Subtitle
                  Center(
                    child: Text(
                      'creez votre compte candidat',
                      style: TextStyle(fontSize: 15, color: Color(0xFF757575)),
                    ),
                  ),

                  SizedBox(height: 22),

                  // Name field
                  _buildFormField(
                    label: 'Nom*',
                    hintText: 'Nom complet',
                    controller: _nameController,
                  ),

                  SizedBox(height: 11),

                  // Email field
                  _buildFormField(
                    label: 'Email*',
                    hintText: 'nom@service.com',
                    controller: _emailController,
                  ),

                  SizedBox(height: 11),

                  // NUI field
                  _buildFormField(
                    label: 'NUI',
                    hintText: 'Numéro d\'identification unique (optionnel)',
                    controller: _nuiController,
                  ),

                  SizedBox(height: 11),

                  // Phone field
                  _buildFormField(
                    label: 'Téléphone*',
                    hintText: '6XX XX XX XX',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  SizedBox(height: 11),

                  // Password field
                  _buildPasswordField(
                    label: 'Mot de passe*',
                    hintText: '8+ caracteres',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onToggle: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),

                  SizedBox(height: 11),

                  // Confirm Password field
                  _buildPasswordField(
                    label: 'confirmer le mot de passe*',
                    hintText: 'Confirmer le mot de passe',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    onToggle: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),

                  SizedBox(height: 14),

                  // Terms and conditions
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
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
                              color: Color(0xFF757575),
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(text: "j'accepte les "),
                              TextSpan(
                                text: "conditions d'utilisation",
                                style: TextStyle(color: Color(0xFF2196F3)),
                              ),
                              TextSpan(text: " et la "),
                              TextSpan(
                                text: "politique de confidentialite",
                                style: TextStyle(color: Color(0xFF2196F3)),
                              ),
                              TextSpan(text: " de JOBSTAGE"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 9),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
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
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 9),

                  // Separator
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Color(0xFFE0E0E0), thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 13),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: Color(0xFFE0E0E0),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Color(0xFFE0E0E0), thickness: 1),
                      ),
                    ],
                  ),

                  SizedBox(height: 9),

                  // Google button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle Google sign in
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Color(0xFFE0E0E0)),
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
                            width: 19,
                            height: 19,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 19,
                                height: 19,
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
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 9),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: Color(0xFF212121),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 7),

                  // Facebook button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle Facebook sign in
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Color(0xFFE0E0E0)),
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
                            width: 19,
                            height: 19,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 19,
                                height: 19,
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
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 9),
                          Text(
                            'Continue with Facebook',
                            style: TextStyle(
                              color: Color(0xFF212121),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  // Footer
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "vous avez deja un compte ? ",
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const JobstageLoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              color: Color(0xFF2196F3),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 16, color: Colors.black),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 15),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 11,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(fontSize: 16, color: Colors.black),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 15),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 11,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Color(0xFF757575),
                  size: 19,
                ),
                onPressed: onToggle,
              ),
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
      home: JobstageSignupScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
