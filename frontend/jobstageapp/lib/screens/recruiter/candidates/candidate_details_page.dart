import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import '../../../models/candidat.dart';

class CandidateDetailsPage extends StatefulWidget {
  final Candidat candidat;

  const CandidateDetailsPage({super.key, required this.candidat});

  @override
  State<CandidateDetailsPage> createState() => _CandidateDetailsPageState();
}

class _CandidateDetailsPageState extends State<CandidateDetailsPage> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          RecruiterTheme.customColors['surface_bg'] ?? Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profil candidat'),
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'contact',
                child: Row(
                  children: [
                    Icon(Icons.phone),
                    SizedBox(width: 8),
                    Text('Contacter'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email),
                    SizedBox(width: 8),
                    Text('Envoyer un email'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cv',
                child: Row(
                  children: [
                    Icon(Icons.description),
                    SizedBox(width: 8),
                    Text('Voir le CV'),
                  ],
                ),
              ),
            ],
            onSelected: _handleMenuAction,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCandidateHeader(),
            _buildCandidateInfo(),
            _buildSkillsSection(),
            _buildExperienceSection(),
            _buildEducationSection(),
            _buildContactSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildCandidateHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: RecruiterTheme.primaryColor.withOpacity(0.1),
            child: Text(
              widget.candidat.nomComplet
                  .split(' ')
                  .map((name) => name[0])
                  .join(''),
              style: RecruiterTheme.headlineLarge.copyWith(
                color: RecruiterTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.candidat.nomComplet,
            style: RecruiterTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color:
                  RecruiterTheme.customColors['primary_text'] ?? Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.candidat.domaineEtude,
            style: RecruiterTheme.titleMedium.copyWith(
              color:
                  RecruiterTheme.customColors['secondary_text'] ?? Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color:
                    RecruiterTheme.customColors['secondary_text'] ??
                    Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                widget.candidat.localisation,
                style: RecruiterTheme.bodyMedium.copyWith(
                  color:
                      RecruiterTheme.customColors['secondary_text'] ??
                      Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.candidat.isActif
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.candidat.isActif ? 'Disponible' : 'En poste',
                  style: RecruiterTheme.labelSmall.copyWith(
                    color: widget.candidat.isActif
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateInfo() {
    return SizedBox(
      width: double.infinity,
      height: 250, // Dimensions fixes identiques
      child: Container(
        margin: const EdgeInsets.all(16),
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
            // En-tête fixe
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Informations générales',
                style: RecruiterTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Niveau d\'études',
                      widget.candidat.niveauEtudeAffichage,
                      Icons.school,
                    ),
                    _buildInfoRow(
                      'Année de diplôme',
                      '${widget.candidat.anneeDiplome}',
                      Icons.calendar_today,
                    ),
                    _buildInfoRow(
                      'Université',
                      widget.candidat.universite,
                      Icons.location_city,
                    ),
                    _buildInfoRow(
                      'Expérience',
                      widget.candidat.experienceAffichage,
                      Icons.work,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: RecruiterTheme.customColors['secondary_text'] ?? Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: RecruiterTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: RecruiterTheme.bodyMedium.copyWith(
                color:
                    RecruiterTheme.customColors['secondary_text'] ??
                    Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return SizedBox(
      width: double.infinity,
      height: 250, // Dimensions fixes identiques
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
            // En-tête fixe
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Compétences',
                style: RecruiterTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.candidat.competences.map((competence) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: RecruiterTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        competence,
                        style: RecruiterTheme.labelMedium.copyWith(
                          color: RecruiterTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return SizedBox(
      width: double.infinity,
      height: 250, // Dimensions fixes identiques
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
            // En-tête fixe
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Expérience professionnelle',
                style: RecruiterTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.candidat.experiences.map((experience) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            experience,
                            style: RecruiterTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    return SizedBox(
      width: double.infinity,
      height: 250, // Dimensions fixes identiques
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
            // En-tête fixe
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Formation',
                style: RecruiterTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Formation basée sur les données existantes
                    _buildFormationItem(
                      '${widget.candidat.niveauEtudeAffichage}',
                      widget.candidat.universite,
                      '${widget.candidat.anneeDiplome - 3}-${widget.candidat.anneeDiplome}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return SizedBox(
      width: double.infinity,
      height: 250, // Dimensions fixes identiques
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
            // En-tête fixe
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Contact',
                style: RecruiterTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    _buildContactRow(
                      Icons.phone,
                      'Téléphone',
                      widget.candidat.telephone,
                    ),
                    _buildContactRow(
                      Icons.email,
                      'Email',
                      widget.candidat.email,
                    ),
                    // LinkedIn simulé
                    _buildContactRow(
                      Icons.link,
                      'LinkedIn',
                      'linkedin.com/in/${widget.candidat.nom.toLowerCase()}-${widget.candidat.prenom.toLowerCase()}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: RecruiterTheme.customColors['secondary_text'] ?? Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: RecruiterTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: RecruiterTheme.bodyMedium.copyWith(
                color:
                    RecruiterTheme.customColors['secondary_text'] ??
                    Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormationItem(
    String diplome,
    String etablissement,
    String periode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            diplome,
            style: RecruiterTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            etablissement,
            style: RecruiterTheme.bodyMedium.copyWith(
              color:
                  RecruiterTheme.customColors['secondary_text'] ?? Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            periode,
            style: RecruiterTheme.bodySmall.copyWith(
              color:
                  RecruiterTheme.customColors['secondary_text'] ?? Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _contactCandidate,
              icon: const Icon(Icons.phone),
              label: const Text('Contacter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: RecruiterTheme.primaryColor,
                side: BorderSide(color: RecruiterTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _viewCV,
              icon: const Icon(Icons.description),
              label: const Text('Voir le CV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: RecruiterTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? 'Candidat ajouté aux favoris'
              : 'Candidat retiré des favoris',
        ),
        backgroundColor: _isFavorite ? Colors.green : Colors.orange,
      ),
    );
  }

  void _handleMenuAction(dynamic value) {
    switch (value) {
      case 'contact':
        _contactCandidate();
        break;
      case 'email':
        _sendEmail();
        break;
      case 'cv':
        _viewCV();
        break;
    }
  }

  void _contactCandidate() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contacter ${widget.candidat.nomComplet}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Appeler'),
              subtitle: Text(widget.candidat.telephone),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ouverture de l\'application téléphone'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Envoyer un SMS'),
              subtitle: Text(widget.candidat.telephone),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ouverture de l\'application SMS'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Envoyer un email'),
              subtitle: Text(widget.candidat.email),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Ouverture de l\'application email pour ${widget.candidat.email}',
                    ),
                    action: SnackBarAction(
                      label: 'Envoyer',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email envoyé')),
                        );
                      },
                    ),
                  ),
                );
              },
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

  void _sendEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ouverture de l\'application email pour ${widget.candidat.email}',
        ),
        action: SnackBarAction(
          label: 'Envoyer',
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Email envoyé')));
          },
        ),
      ),
    );
  }

  void _viewCV() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture du CV de ${widget.candidat.nomComplet}'),
        action: SnackBarAction(
          label: 'Télécharger',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Téléchargement du CV...')),
            );
          },
        ),
      ),
    );
  }
}
