import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/offre.dart';
import '../services/application_service.dart';
import '../services/auth_service.dart';

class ApplyJobDialog extends StatefulWidget {
  final Offre offre;

  const ApplyJobDialog({super.key, required this.offre});

  @override
  State<ApplyJobDialog> createState() => _ApplyJobDialogState();
}

class _ApplyJobDialogState extends State<ApplyJobDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  File? _cvFile;
  File? _lettreMotivationFile;
  bool _isLoading = false;
  bool _hasAlreadyApplied = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyApplied();
  }

  Future<void> _checkIfAlreadyApplied() async {
    try {
      final hasApplied = await ApplicationService.hasAlreadyApplied(
        widget.offre.id,
      );
      if (mounted) {
        setState(() {
          _hasAlreadyApplied = hasApplied;
        });
      }
    } catch (e) {
      print('❌ Erreur vérification candidature: $e');
    }
  }

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        final file = File(result.files.first.path!);

        // Vérifier la taille du fichier (max 10MB)
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);
        if (fileSizeMB > 10) {
          _showErrorSnackBar(
            'Le fichier est trop volumineux. Taille maximum: 10MB',
          );
          return;
        }

        setState(() {
          if (type == 'cv') {
            _cvFile = file;
          } else {
            _lettreMotivationFile = file;
          }
        });

        _showSuccessSnackBar('Fichier sélectionné avec succès');
      }
    } catch (e) {
      print('❌ Erreur sélection fichier: $e');
      _showErrorSnackBar('Erreur lors de la sélection du fichier');
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_cvFile == null && _lettreMotivationFile == null) {
      _showErrorSnackBar(
        'Veuillez sélectionner au moins un fichier (CV ou lettre de motivation)',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload des fichiers si fournis
      String? cvPath;
      String? lettreMotivationPath;

      if (_cvFile != null) {
        final authService = AuthService();
        await authService.initialize();

        final cvResult = await authService.uploadCV(_cvFile!);
        if (cvResult['success']) {
          cvPath = cvResult['cv_url'];
        } else {
          _showErrorSnackBar('Erreur upload CV: ${cvResult['message']}');
          return;
        }
      }

      if (_lettreMotivationFile != null) {
        // Pour la lettre de motivation, on peut utiliser la même méthode ou créer une nouvelle
        // Pour l'instant, on va juste stocker le chemin local
        lettreMotivationPath = _lettreMotivationFile!.path;
      }

      final result = await ApplicationService.applyToJob(
        offreId: widget.offre.id,
        cvPath: cvPath,
        lettreMotivationPath: lettreMotivationPath,
        messagePersonnalise: _messageController.text.trim().isNotEmpty
            ? _messageController.text.trim()
            : null,
      );

      if (result != null) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar('Erreur lors de l\'envoi de la candidature');
      }
    } catch (e) {
      print('❌ Erreur candidature: $e');
      _showErrorSnackBar('Erreur lors de l\'envoi de la candidature: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Candidature envoyée !'),
          ],
        ),
        content: Text(
          'Votre candidature a été envoyée avec succès. Vous recevrez une notification dès que le recruteur aura examiné votre dossier.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer la dialog de succès
              Navigator.of(context).pop(); // Fermer la dialog de candidature
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      _showSimpleDialog('Erreur', message, Colors.red);
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      _showSimpleDialog('Succès', message, Colors.green);
    }
  }

  void _showSimpleDialog(String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              color == Colors.red ? Icons.error : Icons.check_circle,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasAlreadyApplied) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Candidature déjà envoyée'),
          ],
        ),
        content: const Text(
          'Vous avez déjà postulé à cette offre. Vous recevrez une notification dès que le recruteur aura examiné votre dossier.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.send, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Postuler à cette offre',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Informations sur l'offre
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.offre.titre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.offre.entreprise,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section CV
                  _buildFileSection(
                    title: 'CV *',
                    subtitle: 'Votre CV au format PDF, DOC ou DOCX (max 10MB)',
                    file: _cvFile,
                    onPick: () => _pickFile('cv'),
                    icon: Icons.description,
                  ),

                  const SizedBox(height: 16),

                  // Section Lettre de motivation
                  _buildFileSection(
                    title: 'Lettre de motivation',
                    subtitle:
                        'Lettre de motivation au format PDF, DOC ou DOCX (max 10MB)',
                    file: _lettreMotivationFile,
                    onPick: () => _pickFile('lettre'),
                    icon: Icons.mail,
                  ),

                  const SizedBox(height: 16),

                  // Message personnalisé
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message personnalisé (optionnel)',
                      hintText: 'Ajoutez un message pour le recruteur...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),

                  const SizedBox(height: 24),

                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitApplication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Envoyer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileSection({
    required String title,
    required String subtitle,
    required File? file,
    required VoidCallback onPick,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 8),

        if (file != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file.path.split('/').last,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (title.contains('CV')) {
                        _cvFile = null;
                      } else {
                        _lettreMotivationFile = null;
                      }
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
              ],
            ),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload_file),
            label: const Text('Sélectionner un fichier'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
