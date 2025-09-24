import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/offre.dart';
import '../services/application_service.dart';
import '../services/auth_service.dart';

class SimpleApplyDialog extends StatefulWidget {
  final Offre offre;

  const SimpleApplyDialog({super.key, required this.offre});

  @override
  State<SimpleApplyDialog> createState() => _SimpleApplyDialogState();
}

class _SimpleApplyDialogState extends State<SimpleApplyDialog> {
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
          _showMessage(
            'Erreur',
            'Le fichier est trop volumineux. Taille maximum: 10MB',
            Colors.red,
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

        _showMessage('Succès', 'Fichier sélectionné avec succès', Colors.green);
      }
    } catch (e) {
      print('❌ Erreur sélection fichier: $e');
      _showMessage(
        'Erreur',
        'Erreur lors de la sélection du fichier',
        Colors.red,
      );
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_cvFile == null && _lettreMotivationFile == null) {
      _showMessage(
        'Erreur',
        'Veuillez sélectionner au moins un fichier (CV ou lettre de motivation)',
        Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Envoyer directement les fichiers via ApplicationService
      final result = await ApplicationService.applyToJob(
        offreId: widget.offre.id,
        cvPath: _cvFile?.path,
        lettreMotivationPath: _lettreMotivationFile?.path,
        messagePersonnalise: _messageController.text.trim().isNotEmpty
            ? _messageController.text.trim()
            : null,
      );

      if (result != null) {
        _showSuccessDialog();
      } else {
        _showMessage(
          'Erreur',
          'Erreur lors de l\'envoi de la candidature',
          Colors.red,
        );
      }
    } catch (e) {
      print('❌ Erreur candidature: $e');
      _showMessage(
        'Erreur',
        'Erreur lors de l\'envoi de la candidature: $e',
        Colors.red,
      );
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
            Expanded(child: Text('Candidature envoyée !')),
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

  void _showMessage(String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              color == Colors.red ? Icons.error : Icons.check_circle,
              color: color,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasAlreadyApplied) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Expanded(child: Text('Candidature déjà envoyée')),
          ],
        ),
        content: Text(
          'Vous avez déjà postulé à cette offre. Vous recevrez une notification dès que le recruteur aura examiné votre dossier.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
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
                      Icon(Icons.send, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Postuler à cette offre',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
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

                  SizedBox(height: 20),

                  // Section CV
                  _buildFileSection(
                    title: 'CV *',
                    subtitle: 'Votre CV au format PDF, DOC ou DOCX (max 10MB)',
                    file: _cvFile,
                    onPick: () => _pickFile('cv'),
                    icon: Icons.description,
                  ),

                  SizedBox(height: 16),

                  // Section Lettre de motivation
                  _buildFileSection(
                    title: 'Lettre de motivation',
                    subtitle:
                        'Lettre de motivation au format PDF, DOC ou DOCX (max 10MB)',
                    file: _lettreMotivationFile,
                    onPick: () => _pickFile('lettre'),
                    icon: Icons.mail,
                  ),

                  SizedBox(height: 16),

                  // Message personnalisé
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Message personnalisé (optionnel)',
                      hintText: 'Ajoutez un message pour le recruteur...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),

                  SizedBox(height: 24),

                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text('Annuler'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitApplication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
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
                              : Text('Envoyer'),
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
            SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 8),

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
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file.path.split('/').last,
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                  icon: Icon(Icons.close, color: Colors.red),
                ),
              ],
            ),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: onPick,
            icon: Icon(Icons.upload_file),
            label: Text('Sélectionner un fichier'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: BorderSide(color: Colors.blue),
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
