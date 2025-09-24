import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../theme/theme_provider.dart';
import '../theme/adaptive_colors.dart';
import '../widgets/adaptive_card.dart';

class CVSkillsScreen extends StatefulWidget {
  const CVSkillsScreen({super.key});

  @override
  State<CVSkillsScreen> createState() => _CVSkillsScreenState();
}

class _CVSkillsScreenState extends State<CVSkillsScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // CV data - Un seul CV par candidat
  Map<String, dynamic>? _currentCV;
  File? _selectedCVFile;

  // Skills data
  List<String> _skills = [];
  final TextEditingController _skillController = TextEditingController();

  // Skill suggestions
  final List<String> _skillSuggestions = [
    'Flutter',
    'Dart',
    'JavaScript',
    'Python',
    'Java',
    'C++',
    'React',
    'Vue.js',
    'Node.js',
    'Express',
    'MongoDB',
    'PostgreSQL',
    'Firebase',
    'AWS',
    'Docker',
    'Git',
    'Leadership',
    'Travail en équipe',
    'Communication',
    'Gestion de projet',
    'Marketing Digital',
    'Design UX/UI',
    'Analyse de données',
    'Machine Learning',
    'DevOps',
    'Agile',
    'Scrum',
    'Anglais',
    'Français',
    'Espagnol',
  ];

  @override
  void initState() {
    super.initState();
    _loadCVAndSkills();
  }

  Future<void> _loadCVAndSkills() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger les compétences depuis le profil
      final profile = await _authService.getCandidateProfile();
      if (profile != null) {
        setState(() {
          _skills = profile.skillsAsList;
        });
      }

      // Charger le CV depuis le backend
      final cvsResult = await _authService.getCVs();
      if (cvsResult['success']) {
        final cvs = cvsResult['cvs'] as List;
        if (cvs.isNotEmpty) {
          final cv = cvs.first;
          setState(() {
            _currentCV = {
              'id': cv['id'],
              'name': cv['name'],
              'date': cv['uploaded_at'].split('T')[0],
              'size': '${(cv['size'] / 1024 / 1024).toStringAsFixed(1)} MB',
              'url': cv['url'],
            };
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        PlatformFile file = result.files.first;

        // Vérifier la taille du fichier (limite 5MB)
        if (file.size > 5 * 1024 * 1024) {
          _showSnackBar(
            'Le fichier est trop volumineux. Taille maximale: 5MB',
            Colors.orange,
          );
          return;
        }

        setState(() {
          _selectedCVFile = File(file.path!);
        });

        // Upload vers le backend
        await _uploadCVToBackend();
      }
    } catch (e) {
      _showSnackBar(
        'Erreur lors de la sélection du fichier: ${e.toString()}',
        Colors.red,
      );
    }
  }

  Future<void> _uploadCVToBackend() async {
    if (_selectedCVFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.uploadCV(_selectedCVFile!);

      if (result['success']) {
        // Recharger les CVs pour obtenir le vrai ID
        await _loadCVAndSkills();
        _selectedCVFile = null;
        _showSnackBar('CV uploadé avec succès!', Colors.green);
      } else {
        _showSnackBar(
          result['message'] ?? 'Erreur lors de l\'upload',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar('Erreur lors de l\'upload: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
      _saveSkills();
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
    _saveSkills();
  }

  void _addSkillFromSuggestion(String skill) {
    if (!_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
      });
      _saveSkills();
    }
  }

  Future<void> _saveSkills() async {
    try {
      // Sauvegarder les compétences dans le backend
      await _authService.updateSkills(_skills);
      _showSnackBar('Compétences sauvegardées!', Colors.green);
    } catch (e) {
      _showSnackBar(
        'Erreur lors de la sauvegarde: ${e.toString()}',
        Colors.red,
      );
    }
  }

  Future<void> _deleteCV(String cvId) async {
    try {
      final result = await _authService.deleteCV(cvId);

      if (result['success']) {
        setState(() {
          _currentCV = null;
        });
        _showSnackBar('CV supprimé avec succès!', Colors.green);
      } else {
        _showSnackBar(
          result['message'] ?? 'Erreur lors de la suppression',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar(
        'Erreur lors de la suppression: ${e.toString()}',
        Colors.red,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.roboto()),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AdaptiveColors.getBackground(
            themeProvider.isDarkMode,
          ),
          appBar: AppBar(
            backgroundColor: AdaptiveColors.getBackground(
              themeProvider.isDarkMode,
            ),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AdaptiveColors.getOnSurface(themeProvider.isDarkMode),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'CV & Compétences',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AdaptiveColors.getOnSurface(themeProvider.isDarkMode),
              ),
            ),
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AdaptiveColors.getPrimary(themeProvider.isDarkMode),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section CV
                      _buildCVSection(themeProvider),
                      const SizedBox(height: 30),

                      // Section Compétences
                      _buildSkillsSection(themeProvider),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCVSection(ThemeProvider themeProvider) {
    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: AdaptiveColors.getPrimary(themeProvider.isDarkMode),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Mes CVs',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AdaptiveColors.getOnSurface(
                      themeProvider.isDarkMode,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Zone d'upload
            _buildUploadZone(themeProvider),
            const SizedBox(height: 20),

            // CV uploadé
            if (_currentCV != null) ...[
              Text(
                'CV actuel',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AdaptiveColors.getOnSurface(themeProvider.isDarkMode),
                ),
              ),
              const SizedBox(height: 12),
              _buildCVItem(_currentCV!, themeProvider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadZone(ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdaptiveColors.getCard(themeProvider.isDarkMode),
        border: Border.all(
          color: AdaptiveColors.getPrimary(
            themeProvider.isDarkMode,
          ).withOpacity(0.3),
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload,
            size: 48,
            color: AdaptiveColors.getPrimary(themeProvider.isDarkMode),
          ),
          const SizedBox(height: 12),
          Text(
            'Glissez votre CV ici ou cliquez pour sélectionner',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AdaptiveColors.getOnSurface(themeProvider.isDarkMode),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'PDF, DOC, DOCX jusqu\'à 5MB',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AdaptiveColors.getOnSurface(
                themeProvider.isDarkMode,
              ).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _uploadCV,
            icon: const Icon(Icons.add),
            label: const Text('Sélectionner un fichier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdaptiveColors.getPrimary(
                themeProvider.isDarkMode,
              ),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCVItem(Map<String, dynamic> cv, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdaptiveColors.getCard(themeProvider.isDarkMode),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AdaptiveColors.getOnSurface(
            themeProvider.isDarkMode,
          ).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description,
            color: AdaptiveColors.getPrimary(themeProvider.isDarkMode),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cv['name'],
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AdaptiveColors.getOnSurface(
                      themeProvider.isDarkMode,
                    ),
                  ),
                ),
                Text(
                  '${cv['date']} • ${cv['size']}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AdaptiveColors.getOnSurface(
                      themeProvider.isDarkMode,
                    ).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteCV(cv['id'].toString()),
            icon: Icon(Icons.delete, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(ThemeProvider themeProvider) {
    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: AdaptiveColors.getPrimary(themeProvider.isDarkMode),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Mes Compétences',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AdaptiveColors.getOnSurface(
                      themeProvider.isDarkMode,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Zone d'ajout de compétences
            _buildSkillInput(themeProvider),
            const SizedBox(height: 16),

            // Suggestions de compétences
            _buildSkillSuggestions(themeProvider),
            const SizedBox(height: 20),

            // Liste des compétences
            if (_skills.isNotEmpty) ...[
              Text(
                'Compétences ajoutées (${_skills.length})',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AdaptiveColors.getOnSurface(themeProvider.isDarkMode),
                ),
              ),
              const SizedBox(height: 12),
              _buildSkillsList(themeProvider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSkillInput(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AdaptiveColors.getCard(themeProvider.isDarkMode),
        border: Border.all(
          color: AdaptiveColors.getOnSurface(
            themeProvider.isDarkMode,
          ).withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _skillController,
              decoration: InputDecoration(
                hintText: 'Tapez une compétence (ex: Flutter, Leadership...)',
                hintStyle: GoogleFonts.roboto(
                  color: AdaptiveColors.getOnSurface(
                    themeProvider.isDarkMode,
                  ).withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: AdaptiveColors.getOnSurface(themeProvider.isDarkMode),
              ),
              onSubmitted: (value) => _addSkill(),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            child: Material(
              color: AdaptiveColors.getPrimary(themeProvider.isDarkMode),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _addSkill,
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillSuggestions(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions populaires:',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AdaptiveColors.getOnSurface(themeProvider.isDarkMode),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skillSuggestions.take(8).map((skill) {
            final isSelected = _skills.contains(skill);
            return GestureDetector(
              onTap: () => _addSkillFromSuggestion(skill),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AdaptiveColors.getPrimary(themeProvider.isDarkMode)
                      : AdaptiveColors.getCard(themeProvider.isDarkMode),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AdaptiveColors.getPrimary(
                      themeProvider.isDarkMode,
                    ).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  skill,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white
                        : AdaptiveColors.getOnSurface(themeProvider.isDarkMode),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillsList(ThemeProvider themeProvider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AdaptiveColors.getPrimary(
              themeProvider.isDarkMode,
            ).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AdaptiveColors.getPrimary(
                themeProvider.isDarkMode,
              ).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                skill,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AdaptiveColors.getOnSurface(themeProvider.isDarkMode),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _removeSkill(skill),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AdaptiveColors.getOnSurface(
                    themeProvider.isDarkMode,
                  ).withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
