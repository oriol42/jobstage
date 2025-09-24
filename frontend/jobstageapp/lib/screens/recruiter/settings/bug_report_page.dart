import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import 'settings_page.dart';
import '../../../utils/navigation_helper.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({super.key});

  @override
  State<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();
  String _selectedSeverity = 'Moyen';
  String _selectedCategory = 'Interface utilisateur';

  final List<String> _severities = ['Critique', 'Élevé', 'Moyen', 'Faible'];

  final List<String> _categories = [
    'Interface utilisateur',
    'Performance',
    'Fonctionnalité',
    'Sécurité',
    'Autre',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      appBar: NavigationHelper.createAppBar(
        context,
        title: 'Signaler un problème',
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        fallbackScreen: const SettingsPage(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildBugReportForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Icon(Icons.bug_report, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Aidez-nous à améliorer l\'application',
            style: RecruiterTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Signalez les bugs et problèmes que vous rencontrez pour que nous puissions les corriger rapidement.',
            style: RecruiterTheme.bodyMedium.copyWith(
              color: RecruiterTheme.customColors['secondary_text'],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBugReportForm() {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails du problème',
              style: RecruiterTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _titleController,
              label: 'Titre du problème',
              hint: 'Ex: L\'application se ferme lors de la création d\'offre',
              validator: (value) =>
                  value?.isEmpty == true ? 'Le titre est requis' : null,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Catégorie',
              value: _selectedCategory,
              items: _categories,
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Gravité',
              value: _selectedSeverity,
              items: _severities,
              onChanged: (value) => setState(() => _selectedSeverity = value!),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description du problème',
              hint: 'Décrivez le problème en détail...',
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty == true ? 'La description est requise' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _stepsController,
              label: 'Étapes pour reproduire',
              hint:
                  '1. Ouvrir l\'application\n2. Aller dans...\n3. Cliquer sur...',
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBugReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Envoyer le rapport'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
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
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint ?? 'Entrez $label',
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
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: RecruiterTheme.customColors['border'] ?? Colors.grey,
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _submitBugReport() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport de bug envoyé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      _titleController.clear();
      _descriptionController.clear();
      _stepsController.clear();
    }
  }
}
