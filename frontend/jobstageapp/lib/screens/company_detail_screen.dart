import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard_screen.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> company;

  const CompanyDetailScreen({super.key, required this.company});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  bool isFollowing = false;
  String selectedTab = 'Offres';

  @override
  void initState() {
    super.initState();
    isFollowing = widget.company['isFollowing'];
  }

  // Offres de l'entreprise
  final List<Map<String, dynamic>> companyOffers = [
    {
      'title': 'Développeur Flutter Senior',
      'type': 'CDI',
      'location': 'Yaoundé',
      'salary': '800,000 - 1,200,000 FCFA',
      'time': 'Il y a 1h',
      'match': '96%',
      'isJob': true,
      'isFavorite': false,
      'description':
          'Nous recherchons un développeur passionné pour rejoindre notre équipe dynamique. Vous travaillerez sur des projets innovants et aurez l\'opportunité de développer vos compétences dans un environnement stimulant.',
      'requirements': [
        'Flutter et Dart',
        'Firebase',
        'API REST',
        'Git',
        'Travail en équipe',
      ],
      'benefits': [
        'Assurance santé',
        'Formation continue',
        'Télétravail partiel',
      ],
    },
    {
      'title': 'Développeur Flutter Junior',
      'type': 'CDI',
      'location': 'Yaoundé',
      'salary': '400,000 - 600,000 FCFA',
      'time': 'Il y a 2h',
      'match': '92%',
      'isJob': true,
      'isFavorite': true,
      'description':
          'Poste junior pour un développeur Flutter débutant souhaitant évoluer dans le développement mobile.',
      'requirements': [
        'Connaissance de base Flutter',
        'Motivation',
        'Esprit d\'équipe',
      ],
      'benefits': ['Formation encadrée', 'Mentorat', 'Évolution rapide'],
    },
    {
      'title': 'Stage Marketing Digital',
      'type': 'Stage 6 mois',
      'location': 'Douala',
      'salary': '150,000 FCFA',
      'time': 'Il y a 5h',
      'match': '87%',
      'isJob': false,
      'isFavorite': false,
      'description':
          'Stage en marketing digital pour apprendre les techniques de communication digitale et les stratégies marketing.',
      'requirements': [
        'Étudiant en marketing',
        'Connaissance des réseaux sociaux',
        'Créativité',
      ],
      'benefits': [
        'Formation pratique',
        'Encadrement personnalisé',
        'Certificat de stage',
      ],
    },
    {
      'title': 'Développeur Web Full-Stack',
      'type': 'CDI',
      'location': 'Bamenda',
      'salary': '600,000 - 900,000 FCFA',
      'time': 'Il y a 1 jour',
      'match': '89%',
      'isJob': true,
      'isFavorite': false,
      'description':
          'Développement d\'applications web complètes avec technologies modernes.',
      'requirements': ['React/Node.js', 'Base de données', 'Docker', 'CI/CD'],
      'benefits': [
        'Projets variés',
        'Technologies modernes',
        'Formation continue',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          widget.company['name'],
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _toggleFollow,
            icon: Icon(
              isFollowing ? Icons.check_circle : Icons.add_circle_outline,
              color: Colors.white,
            ),
            tooltip: isFollowing ? 'Ne plus suivre' : 'Suivre',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header de l'entreprise
            _buildCompanyHeader(),
            // Onglets
            _buildTabBar(),
            // Contenu des onglets
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      color: AppColors.blueDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Logo et informations principales
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.company['name'],
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.company['industry'],
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.company['location'],
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.people, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          widget.company['employees'],
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Description
          Text(
            widget.company['description'],
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          // Badge de validation CENADI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Validé CENADI',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Statistiques
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat(
                '${widget.company['followers']}',
                'Suiveurs',
                Icons.people,
              ),
              _buildHeaderStat('${companyOffers.length}', 'Offres', Icons.work),
              _buildHeaderStat('2024', 'Depuis', Icons.calendar_today),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: _buildTabButton('Offres', selectedTab == 'Offres')),
          Expanded(
            child: _buildTabButton('À propos', selectedTab == 'À propos'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.blueDark.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? AppColors.blueDark
                  : Colors.grey.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.blueDark : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (selectedTab == 'Offres') {
      return _buildOffersList();
    } else {
      return _buildAboutSection();
    }
  }

  Widget _buildOffersList() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Offres d\'emploi (${companyOffers.length})',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          ...companyOffers.map((offer) => _buildOfferCard(offer)),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOfferDetails(offer),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: offer['isJob']
                      ? AppColors.greenDark
                      : AppColors.blueDark,
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre
                            Text(
                              offer['title'],
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Nom de l'entreprise
                            Text(
                              widget.company['name'],
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bouton favori
                      GestureDetector(
                        onTap: () => _toggleFavorite(offer),
                        child: Icon(
                          offer['isFavorite']
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: offer['isFavorite']
                              ? Colors.amber
                              : AppColors.secondaryText,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge de match
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: offer['isJob']
                              ? AppColors.greenDark
                              : AppColors.blueDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          offer['match'],
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Salaire
                  Text(
                    offer['salary'],
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greenDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Détails (localisation, type, temps)
                  Row(
                    children: [
                      // Localisation
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            offer['location'],
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Type de contrat
                      Row(
                        children: [
                          const Icon(
                            Icons.description,
                            size: 16,
                            color: AppColors.blueDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            offer['type'],
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Temps
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            offer['time'],
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
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

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À propos de ${widget.company['name']}',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard('Description', widget.company['description']),
          const SizedBox(height: 16),
          _buildInfoCard('Secteur d\'activité', widget.company['industry']),
          const SizedBox(height: 16),
          _buildInfoCard('Localisation', widget.company['location']),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Taille de l\'entreprise',
            widget.company['employees'],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.blueDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AppColors.primaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFollow() {
    setState(() {
      isFollowing = !isFollowing;
      if (isFollowing) {
        widget.company['followers']++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vous suivez maintenant ${widget.company['name']}',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: AppColors.greenDark,
          ),
        );
      } else {
        widget.company['followers']--;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vous ne suivez plus ${widget.company['name']}',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _toggleFavorite(Map<String, dynamic> offer) {
    setState(() {
      offer['isFavorite'] = !offer['isFavorite'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            offer['isFavorite'] ? 'Ajouté aux favoris' : 'Retiré des favoris',
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: offer['isFavorite']
              ? AppColors.greenDark
              : Colors.orange,
        ),
      );
    });
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(String title, String location) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openGoogleMaps(location),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.blueDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.blueDark.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.blueDark,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Maps',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openGoogleMaps(String location) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ouverture de Google Maps pour "$location" - Fonctionnalité à venir',
          style: GoogleFonts.roboto(),
        ),
        backgroundColor: AppColors.blueDark,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showApplicationDialog(Map<String, dynamic> offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Postuler à cette offre',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Voulez-vous postuler à l\'offre "${offer['title']}" chez ${widget.company['name']} ?',
          style: GoogleFonts.roboto(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.roboto()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Candidature envoyée avec succès !',
                    style: GoogleFonts.roboto(),
                  ),
                  backgroundColor: AppColors.greenDark,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueDark,
              foregroundColor: Colors.white,
            ),
            child: Text('Confirmer', style: GoogleFonts.roboto()),
          ),
        ],
      ),
    );
  }

  void _showOfferDetails(Map<String, dynamic> offer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.blueDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        'Détails de l\'offre',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Pour centrer le titre
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['title'],
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.company['name'],
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailSection('Salaire', offer['salary']),
                      _buildLocationSection('Localisation', offer['location']),
                      _buildDetailSection('Type de contrat', offer['type']),
                      _buildDetailSection('Match', offer['match']),
                      _buildDetailSection('Publié', offer['time']),
                      _buildDetailSection('Description', offer['description']),
                      _buildDetailSection(
                        'Compétences requises',
                        offer['requirements'].map((req) => '• $req').join('\n'),
                      ),
                      _buildDetailSection(
                        'Avantages',
                        offer['benefits']
                            .map((benefit) => '• $benefit')
                            .join('\n'),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showApplicationDialog(offer);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueDark,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Postuler maintenant',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
