import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import '../../../services/auth_service.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _secteurController = TextEditingController();
  final _siteWebController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  String _companyName = 'Entreprise';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Charger les données de l'utilisateur connecté
    final result = await _authService.getProfile();
    if (result['success'] && mounted) {
      setState(() {
        if (result['user'] != null) {
          final user = result['user'];
          _companyName = user.username;
          _nomController.text = user.username;
          _emailController.text = user.email;
          _telephoneController.text = user.phone ?? '';
        }
      });
    }

    // Initialiser les champs avec des valeurs vides par défaut
    _adresseController.text = ''; // Vide par défaut
    _descriptionController.text = ''; // Vide par défaut
    _secteurController.text = ''; // Vide par défaut
    _siteWebController.text = ''; // Vide par défaut
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      appBar: AppBar(
        title: const Text('Profil Entreprise'),
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Vérifier si on peut faire un retour normal
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // Si on ne peut pas faire pop, rediriger vers les paramètres
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
                (route) => false,
              );
            }
          },
        ),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Enregistrer',
                      style: TextStyle(color: Colors.white),
                    ),
            )
          else
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildFormSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: RecruiterTheme.primaryColor.withOpacity(0.1),
            child: Text(
              _companyName.isNotEmpty
                  ? _companyName.substring(0, 2).toUpperCase()
                  : 'EN',
              style: RecruiterTheme.headlineLarge.copyWith(
                color: RecruiterTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _companyName,
            style: RecruiterTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _emailController.text,
            style: RecruiterTheme.bodyMedium.copyWith(
              color: RecruiterTheme.customColors['secondary_text'],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Vérifiée CENADI',
                  style: RecruiterTheme.labelSmall.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de l\'entreprise',
            style: RecruiterTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nomController,
            label: 'Nom de l\'entreprise',
            enabled: _isEditing,
            validator: (value) =>
                value?.isEmpty == true ? 'Le nom est requis' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value?.isEmpty == true ? 'L\'email est requis' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _telephoneController,
            label: 'Téléphone',
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
            validator: (value) =>
                value?.isEmpty == true ? 'Le téléphone est requis' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _adresseController,
            label: 'Adresse',
            enabled: _isEditing,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _secteurController,
            label: 'Secteur d\'activité',
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _siteWebController,
            label: 'Site web',
            enabled: _isEditing,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            enabled: _isEditing,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: RecruiterTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: RecruiterTheme.customColors['primary_text'],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Entrez $label',
            hintStyle: RecruiterTheme.bodyMedium.copyWith(
              color:
                  RecruiterTheme.customColors['secondary_text'] ?? Colors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: RecruiterTheme.customColors['border'] ?? Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: RecruiterTheme.customColors['border'] ?? Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: RecruiterTheme.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Mettre à jour les informations de base de l'utilisateur
        final result = await _authService.updateUserInfo(
          firstName: _nomController.text,
          phone: _telephoneController.text,
        );

        if (result['success'] && mounted) {
          setState(() {
            _isEditing = false;
            _companyName = _nomController.text;
          });

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profil mis à jour avec succès'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'Erreur lors de la mise à jour',
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
