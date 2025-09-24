import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import '../../../services/recruiter_api_service.dart';
import '../../../services/api_service.dart';
import '../../../utils/navigation_helper.dart';
import 'offers_list_page.dart';

class CreateOfferPage extends StatefulWidget {
  final dynamic offreToEdit;

  const CreateOfferPage({super.key, this.offreToEdit});

  @override
  State<CreateOfferPage> createState() => _CreateOfferPageState();
}

class _CreateOfferPageState extends State<CreateOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final _dataService = RecruiterApiService();

  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _secteurActiviteController = TextEditingController();
  final _salaireMinController = TextEditingController();
  final _salaireMaxController = TextEditingController();
  final _salaireTextController = TextEditingController();
  final _competencesController = TextEditingController();
  final _processusController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactTelephoneController = TextEditingController();

  String _selectedTypeContrat = 'CDI';
  String _selectedTypeStage = 'Stage court';
  String _selectedNiveauEtudes = 'Bac+3';
  String _selectedNiveauExperience = 'Débutant';
  int _dureeMois = 6;
  int _experienceRequise = 0;
  List<String> _selectedVilles = [];
  List<String> _competencesRequises = [];
  List<String> _avantages = [];
  bool _isActive = true;

  // Liste des villes du Cameroun
  final List<String> _villesCameroun = [
    'Douala',
    'Yaoundé',
    'Bafoussam',
    'Bamenda',
    'Garoua',
    'Maroua',
    'Ngaoundéré',
    'Bertoua',
    'Ebolowa',
    'Kumba',
    'Limbe',
    'Buea',
    'Dschang',
    'Foumban',
    'Kribi',
    'Edea',
    'Mbalmayo',
    'Sangmélima',
    'Nkongsamba',
    'Foumbot',
    'Mbouda',
    'Bangangté',
    'Mfou',
    'Obala',
    'Mokolo',
    'Kousseri',
    'Wum',
    'Fundong',
    'Kumbo',
    'Nkambe',
    'Tiko',
    'Muyuka',
    'Idenau',
    'Mamfe',
    'Akwaya',
    'Eyumodjock',
    'Tombel',
    'Loum',
    'Penja',
    'Pouma',
    'Bonabéri',
    'Bonapriso',
    'Akwa',
    'Deido',
    'New Bell',
    'Bali',
    'Bamendouka',
    'Bamunka',
    'Bamessing',
    'Bamunka',
    'Bamunka',
    'Bamunka',
    'Bamunka',
    'Bamunka',
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser le formulaire après que les contrôleurs soient prêts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() {
    if (widget.offreToEdit != null) {
      setState(() {
        _titreController.text = widget.offreToEdit.titre;
        _descriptionController.text = widget.offreToEdit.description;
        _secteurActiviteController.text = widget.offreToEdit.secteurActivite;
        _salaireMinController.text = widget.offreToEdit.salaireMin.toString();
        _salaireMaxController.text = widget.offreToEdit.salaireMax.toString();
        _salaireTextController.text = widget.offreToEdit.salaireText;
        _processusController.text = widget.offreToEdit.processusRecrutement;
        _contactEmailController.text = widget.offreToEdit.contactEmail;
        _contactTelephoneController.text = widget.offreToEdit.contactTelephone;

        _selectedTypeContrat = widget.offreToEdit.typeContrat;
        _selectedTypeStage = widget.offreToEdit.typeStage;
        _selectedNiveauEtudes = widget.offreToEdit.niveauEtudes;
        _selectedNiveauExperience = widget.offreToEdit.niveauExperience;
        _dureeMois = widget.offreToEdit.dureeMois;
        _experienceRequise = widget.offreToEdit.experienceRequise;
        _isActive = widget.offreToEdit.isActive;

        // Initialiser les villes sélectionnées
        if (widget.offreToEdit.localisation.isNotEmpty) {
          _selectedVilles = widget.offreToEdit.localisation
              .split(', ')
              .where((ville) => ville.isNotEmpty)
              .toList();
        }

        // Initialiser les compétences requises
        _competencesRequises = List<String>.from(
          widget.offreToEdit.competencesRequises,
        );

        // Initialiser les avantages
        _avantages = List<String>.from(widget.offreToEdit.avantages);
      });
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _secteurActiviteController.dispose();
    _salaireMinController.dispose();
    _salaireMaxController.dispose();
    _salaireTextController.dispose();
    _competencesController.dispose();
    _processusController.dispose();
    _contactEmailController.dispose();
    _contactTelephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      appBar: NavigationHelper.createAppBar(
        context,
        title: widget.offreToEdit != null
            ? 'Modifier l\'offre'
            : 'Créer une offre',
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        fallbackScreen: const OffersListPage(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informations générales'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _titreController,
                label: 'Titre du poste',
                hint: 'Ex: Développeur Flutter Senior',
                validator: (value) =>
                    value?.isEmpty == true ? 'Le titre est requis' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Décrivez le poste et les responsabilités...',
                maxLines: 4,
                validator: (value) => value?.isEmpty == true
                    ? 'La description est requise'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _secteurActiviteController,
                label: 'Secteur d\'activité',
                hint: 'Ex: Technologie, Finance, Santé...',
                validator: (value) => value?.isEmpty == true
                    ? 'Le secteur d\'activité est requis'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildVillesSelection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Détails du poste'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _salaireMinController,
                      label: 'Salaire min (FCFA)',
                      hint: '500000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _salaireMaxController,
                      label: 'Salaire max (FCFA)',
                      hint: '800000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _salaireTextController,
                label: 'Salaire (texte libre)',
                hint: 'Ex: Selon profil, Négociable, etc.',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Type de contrat',
                value: _selectedTypeContrat,
                items: ['CDI', 'CDD', 'Stage', 'Freelance', 'Temps partiel'],
                onChanged: (value) =>
                    setState(() => _selectedTypeContrat = value!),
              ),
              const SizedBox(height: 16),
              if (_selectedTypeContrat == 'Stage') ...[
                _buildDropdown(
                  label: 'Type de stage',
                  value: _selectedTypeStage,
                  items: ['Stage court', 'Stage long', 'PFE'],
                  onChanged: (value) =>
                      setState(() => _selectedTypeStage = value!),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: TextEditingController(
                    text: _dureeMois.toString(),
                  ),
                  label: 'Durée (mois)',
                  hint: '6',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _dureeMois = int.tryParse(value) ?? 6;
                  },
                ),
                const SizedBox(height: 16),
              ],
              _buildDropdown(
                label: 'Niveau d\'études',
                value: _selectedNiveauEtudes,
                items: ['Bac', 'Bac+2', 'Bac+3', 'Bac+5', 'Doctorat'],
                onChanged: (value) =>
                    setState(() => _selectedNiveauEtudes = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Niveau d\'expérience',
                value: _selectedNiveauExperience,
                items: [
                  'Sans expérience',
                  'Débutant',
                  'Intermédiaire',
                  'Expérimenté',
                  'Senior',
                  'Expert',
                ],
                onChanged: (value) =>
                    setState(() => _selectedNiveauExperience = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: TextEditingController(
                  text: _experienceRequise.toString(),
                ),
                label: 'Expérience requise (années)',
                hint: '0',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _experienceRequise = int.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 16),
              _buildCompetencesSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Informations de contact'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _contactEmailController,
                label: 'Email de contact',
                hint: 'contact@entreprise.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value?.isEmpty == true
                    ? 'L\'email de contact est requis'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _contactTelephoneController,
                label: 'Téléphone de contact',
                hint: '+237 6XX XXX XXX',
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty == true
                    ? 'Le téléphone de contact est requis'
                    : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Processus de recrutement'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _processusController,
                label: 'Processus de recrutement',
                hint: 'CV + Entretien technique + Entretien RH',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Paramètres'),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Offre active'),
                subtitle: const Text('L\'offre sera visible par les candidats'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeThumbColor: RecruiterTheme.primaryColor,
              ),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: RecruiterTheme.headlineSmall.copyWith(
        color: RecruiterTheme.customColors['primary_text'],
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
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
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _buildVillesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Villes',
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
          child: Column(
            children: [
              InkWell(
                onTap: _showVillesDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedVilles.isEmpty
                              ? 'Sélectionner les villes'
                              : '${_selectedVilles.length} ville(s) sélectionnée(s)',
                          style: TextStyle(
                            color: _selectedVilles.isEmpty
                                ? RecruiterTheme.customColors['secondary_text']
                                : RecruiterTheme.customColors['primary_text'],
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              if (_selectedVilles.isNotEmpty) ...[
                const Divider(height: 1),
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedVilles.map((ville) {
                      return Chip(
                        label: Text(ville),
                        onDeleted: () {
                          setState(() {
                            _selectedVilles.remove(ville);
                          });
                        },
                        deleteIcon: const Icon(Icons.close, size: 18),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: RecruiterTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: RecruiterTheme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: InkWell(
            onTap: _openMaps,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: RecruiterTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Position sur la carte',
                          style: RecruiterTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: RecruiterTheme.primaryColor,
                          ),
                        ),
                        Text(
                          'Cliquez pour positionner l\'offre sur Google Maps',
                          style: RecruiterTheme.bodySmall.copyWith(
                            color:
                                RecruiterTheme.customColors['secondary_text'],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: RecruiterTheme.primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compétences requises',
          style: RecruiterTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: RecruiterTheme.customColors['primary_text'],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _competencesController,
                decoration: InputDecoration(
                  hintText: 'Ajouter une compétence',
                  hintStyle: RecruiterTheme.bodyMedium.copyWith(
                    color:
                        RecruiterTheme.customColors['secondary_text'] ??
                        Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          RecruiterTheme.customColors['border'] ?? Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          RecruiterTheme.customColors['border'] ?? Colors.grey,
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
                onSubmitted: (value) => _addCompetence(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addCompetence,
              style: ElevatedButton.styleFrom(
                backgroundColor: RecruiterTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        if (_competencesRequises.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _competencesRequises.map((competence) {
              return Chip(
                label: Text(competence),
                onDeleted: () {
                  setState(() {
                    _competencesRequises.remove(competence);
                  });
                },
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
        ],
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submitOffer,
        style: ElevatedButton.styleFrom(
          backgroundColor: RecruiterTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          widget.offreToEdit != null ? 'Modifier l\'offre' : 'Publier l\'offre',
          style: RecruiterTheme.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showVillesDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Sélectionner les villes'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: _villesCameroun.length,
                itemBuilder: (context, index) {
                  final ville = _villesCameroun[index];
                  final isSelected = _selectedVilles.contains(ville);

                  return CheckboxListTile(
                    title: Text(ville),
                    value: isSelected,
                    onChanged: (value) {
                      setDialogState(() {
                        if (value == true) {
                          _selectedVilles.add(ville);
                        } else {
                          _selectedVilles.remove(ville);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: const Text('Valider'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addCompetence() {
    final competence = _competencesController.text.trim();
    if (competence.isNotEmpty && !_competencesRequises.contains(competence)) {
      setState(() {
        _competencesRequises.add(competence);
        _competencesController.clear();
      });
    }
  }

  void _openMaps() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Position sur la carte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, size: 64, color: RecruiterTheme.primaryColor),
            const SizedBox(height: 16),
            const Text(
              'Fonctionnalité de géolocalisation',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cette fonctionnalité permettra de positionner l\'offre sur Google Maps pour faciliter l\'itinérance des candidats.',
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Position enregistrée (simulation)'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Enregistrer la position'),
              style: ElevatedButton.styleFrom(
                backgroundColor: RecruiterTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _submitOffer() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedVilles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner au moins une ville'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        print('🚀 Début de la création d\'offre...');

        // S'assurer que l'API est initialisée
        await ApiService.initialize();
        print('✅ API initialisée');

        // Vérifier les données de l'entreprise
        print('📋 Données entreprise: ${_dataService.entreprise}');

        // Préparer les données de l'offre
        final offreData = {
          'titre': _titreController.text,
          'description': _descriptionController.text,
          'secteur_activite': _secteurActiviteController.text,
          'competences_requises': _competencesRequises,
          'localisation': _selectedVilles.join(', '),
          'type_contrat': _selectedTypeContrat,
          'type_stage': _selectedTypeContrat == 'Stage'
              ? _selectedTypeStage
              : null,
          'duree_mois': _dureeMois,
          'salaire_min': int.tryParse(_salaireMinController.text) ?? 0,
          'salaire_max': int.tryParse(_salaireMaxController.text) ?? 0,
          'salaire_text': _salaireTextController.text,
          'niveau_etudes': _selectedNiveauEtudes,
          'niveau_experience': _selectedNiveauExperience,
          'experience_requise': _experienceRequise,
          'date_expiration': DateTime.now()
              .add(const Duration(days: 30))
              .toIso8601String(),
          'contact_email': _contactEmailController.text,
          'contact_telephone': _contactTelephoneController.text,
          'is_active': _isActive,
          'avantages': _avantages,
          'processus_recrutement': _processusController.text,
        };

        print('📝 Données de l\'offre préparées: $offreData');

        Map<String, dynamic>? result;

        if (widget.offreToEdit != null) {
          // Mode édition
          print('✏️ Mode édition...');
          result = await ApiService.updateOffre(
            int.parse(widget.offreToEdit.id),
            offreData,
          );
        } else {
          // Mode création
          print('➕ Mode création...');
          result = await ApiService.createOffre(offreData);
        }

        print('📤 Réponse API: $result');

        // Fermer le dialogue de chargement
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (result != null) {
          print('✅ Offre créée avec succès!');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.offreToEdit != null
                      ? 'Offre modifiée avec succès !'
                      : 'Offre créée avec succès !',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );

            // Retourner à la page précédente
            Navigator.of(context).pop();
          }
        } else {
          print('❌ Résultat null - Erreur lors de la sauvegarde');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Erreur: Impossible de sauvegarder l\'offre. Vérifiez votre connexion.',
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e, stackTrace) {
        print('❌ ERREUR DÉTAILLÉE:');
        print('Erreur: $e');
        print('Stack trace: $stackTrace');

        // Fermer le dialogue de chargement
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (mounted) {
          // Afficher une erreur plus détaillée
          String errorMessage = 'Erreur inconnue';

          if (e.toString().contains('SocketException')) {
            errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
          } else if (e.toString().contains('TimeoutException')) {
            errorMessage = 'Délai d\'attente dépassé. Réessayez.';
          } else if (e.toString().contains('FormatException')) {
            errorMessage = 'Erreur de format des données.';
          } else if (e.toString().contains('Exception')) {
            errorMessage = 'Erreur: ${e.toString()}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Détails',
                textColor: Colors.white,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Détails de l\'erreur'),
                      content: SingleChildScrollView(
                        child: Text('$e\n\n$stackTrace'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    }
  }
}
