import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/recruiter_theme.dart';
import '../../services/recruiter_api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/recruiter/stats_card.dart';
import '../../widgets/recruiter/quick_action_card.dart';
import '../../widgets/recruiter/offer_card.dart';
import '../../widgets/recruiter/candidate_card.dart';
import '../../models/entreprise.dart';
import '../../models/offre.dart';
import '../../models/candidat.dart';
import 'offers/create_offer_page.dart';
import 'offers/offers_list_page.dart';
import 'offers/offer_details_page.dart';
// import 'candidates/candidates_list_page.dart'; // Supprimé - page inutile
import 'candidates/candidate_details_page.dart';
import 'candidates/matches_page.dart';
import 'favorites/favorites_page.dart';
import 'settings/profile_page.dart';

class RecruiterDashboard extends StatefulWidget {
  const RecruiterDashboard({super.key});

  @override
  State<RecruiterDashboard> createState() => _RecruiterDashboardState();
}

class _RecruiterDashboardState extends State<RecruiterDashboard> {
  final RecruiterApiService _apiService = RecruiterApiService();
  final AuthService _authService = AuthService();
  Entreprise? _entreprise;
  List<Offre> _offres = [];
  List<Candidat> _candidatsRecommandes = [];
  Map<String, int> _statistiques = {};
  String _companyName = 'Entreprise';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _apiService.initialize();
      if (mounted) {
        setState(() {
          _offres = _apiService.offres;
          _candidatsRecommandes = _apiService.candidats.take(3).toList();
          _statistiques = {
            'total_offres': _offres.length,
            'offres_actives': _offres.where((o) => o.isActive).length,
            'total_candidats': _apiService.candidats.length,
            'candidats_disponibles': _apiService.candidats
                .where((c) => c.disponible)
                .length,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des données: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final result = await _authService.getProfile();
    if (result['success'] && mounted) {
      setState(() {
        if (result['user'] != null) {
          final user = result['user'];
          // Utiliser le nom d'utilisateur comme nom de l'entreprise
          _companyName = user.username;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: RecruiterTheme.customColors['surface_bg'],
        body: const Center(
          child: CircularProgressIndicator(color: RecruiterTheme.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAppBar(),
            _buildStatsCard(),
            _buildQuickActions(),
            _buildActiveOffers(),
            _buildRecommendedCandidates(),
            const SizedBox(height: 20), // Espace pour la navigation
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderTop(),
              const SizedBox(height: 8),
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildCompanyInfo(),
              const SizedBox(height: 8),
              _buildVerificationBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTop() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/images/jobstage_logo.png',
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'JOBSTAGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
        Row(
          children: [
            _buildHeaderIcon(Icons.support_agent),
            const SizedBox(width: 10),
            _buildHeaderIcon(Icons.business),
            const SizedBox(width: 10),
            _buildHeaderIconWithBadge(
              Icons.notifications,
              _getHighMatchCount(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return GestureDetector(
      onTap: () {
        // Action pour l'icône
        if (icon == Icons.support_agent) {
          _showSupportDialog();
        } else if (icon == Icons.business) {
          _navigateToProfile();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildHeaderIconWithBadge(IconData icon, int badgeCount) {
    return GestureDetector(
      onTap: () {
        print('DEBUG: Tap sur notification détecté'); // Debug
        // Action pour les notifications
        _showNotifications();
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5722),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _companyName,
          style: RecruiterTheme.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Trouvez les meilleurs talents',
          style: RecruiterTheme.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher des candidats...',
          hintStyle: RecruiterTheme.bodyMedium.copyWith(
            color: RecruiterTheme.customColors['secondary_text'],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: RecruiterTheme.customColors['secondary_text'],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBadge() {
    if (_entreprise == null || !_entreprise!.isVerified) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                'Vérifiée CENADI',
                style: RecruiterTheme.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return StatsCard(
      offresActives: _statistiques['offres_actives'] ?? 0,
      candidats: _statistiques['candidats'] ?? 0,
      onOffresTap: _navigateToAllOffers,
      onCandidatsTap: _navigateToCandidates,
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(0, 8),
            child: Text('Actions rapides', style: RecruiterTheme.headlineSmall),
          ),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              QuickActionCard(
                icon: Icons.add_circle,
                title: 'Publier Offre',
                iconColor: RecruiterTheme.customColors['green_dark']!,
                backgroundColor: RecruiterTheme.customColors['green_light']!,
                onTap: () => _navigateToCreateOffer(),
              ),
              QuickActionCard(
                icon: Icons.group,
                title: 'Mes Candidats',
                iconColor: RecruiterTheme.customColors['blue_dark']!,
                backgroundColor: RecruiterTheme.customColors['blue_light']!,
                onTap: () => _navigateToCandidates(),
              ),
              QuickActionCard(
                icon: Icons.psychology,
                title: 'Candidats Matches',
                iconColor: RecruiterTheme.customColors['purple_dark']!,
                backgroundColor: RecruiterTheme.customColors['purple_light']!,
                onTap: () => _navigateToMatches(),
              ),
              QuickActionCard(
                icon: Icons.bookmark_border,
                title: 'Mes Favoris',
                iconColor: RecruiterTheme.customColors['red_dark']!,
                backgroundColor: RecruiterTheme.customColors['red_light']!,
                onTap: () => _navigateToFavorites(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOffers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mes offres actives', style: RecruiterTheme.headlineSmall),
              TextButton(
                onPressed: () => _navigateToAllOffers(),
                child: Text(
                  'Gérer tout',
                  style: RecruiterTheme.bodyMedium.copyWith(
                    color: RecruiterTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ..._offres
              .where((offre) => offre.isActive)
              .map(
                (offre) => OfferCard(
                  offre: offre,
                  onTap: () => _navigateToOfferDetails(offre),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCandidates() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Candidats recommandés',
                style: RecruiterTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () => _navigateToAllCandidates(),
                child: Text(
                  'Voir tous',
                  style: RecruiterTheme.bodyMedium.copyWith(
                    color: RecruiterTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ..._candidatsRecommandes
              .take(3)
              .map(
                (candidat) => CandidateCard(
                  candidat: candidat,
                  onTap: () => _navigateToCandidateDetails(candidat),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _navigateToCreateOffer,
      backgroundColor: RecruiterTheme.primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  // Navigation methods
  void _navigateToCreateOffer() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CreateOfferPage()))
        .then((_) {
          // Recharger les données après création d'offre
          _loadData();
        });
  }

  void _navigateToCandidates() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MatchesPage()));
  }

  void _navigateToCandidatesWithTab() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MatchesPage()));
  }

  void _navigateToMatches() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MatchesPage()));
  }

  void _navigateToCandidateDetails(Candidat candidat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CandidateDetailsPage(candidat: candidat),
      ),
    );
  }

  void _navigateToFavorites() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FavoritesPage()));
  }

  void _navigateToAllOffers() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const OffersListPage()));
  }

  void _navigateToOfferDetails(Offre offre) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => OfferDetailsPage(offre: offre)),
    );
  }

  void _navigateToAllCandidates() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MatchesPage()));
  }

  void _showSupportDialog() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SupportChatPage()));
  }

  void _navigateToProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  void _showNotifications() {
    print('DEBUG: _showNotifications appelée'); // Debug

    // Récupérer les candidats avec un match de plus de 90%
    final highMatchCandidates = _apiService.candidats.where((candidat) {
      final matchScore = _calculateMatchScore(candidat);
      return matchScore > 90;
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.green),
              const SizedBox(width: 8),
              Text('Notifications (${highMatchCandidates.length})'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: highMatchCandidates.isEmpty
                ? const Text(
                    'Aucun candidat avec un match de plus de 90% pour le moment.',
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: highMatchCandidates.length,
                    itemBuilder: (context, index) {
                      final candidat = highMatchCandidates[index];
                      final matchScore = _calculateMatchScore(candidat);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              candidat.nomComplet.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            candidat.nomComplet,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${candidat.domaineEtude} • ${candidat.experiences.length} expérience${candidat.experiences.length > 1 ? 's' : ''}',
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$matchScore% match',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            _navigateToCandidatesWithTab();
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour obtenir le nombre de candidats avec un match > 90%
  int _getHighMatchCount() {
    return _apiService.candidats.where((candidat) {
      final matchScore = _calculateMatchScore(candidat);
      return matchScore > 90;
    }).length;
  }

  // Méthode pour calculer le score de match (simulation)
  int _calculateMatchScore(Candidat candidat) {
    // Simulation basée sur l'expérience et les compétences
    int baseScore = 60;

    // Bonus pour l'expérience (basé sur le nombre d'expériences)
    if (candidat.experiences.length >= 3) {
      baseScore += 20;
    } else if (candidat.experiences.length >= 2)
      baseScore += 15;
    else if (candidat.experiences.isNotEmpty)
      baseScore += 10;

    // Bonus pour les compétences
    if (candidat.competences.length >= 5) {
      baseScore += 15;
    } else if (candidat.competences.length >= 3)
      baseScore += 10;
    else if (candidat.competences.isNotEmpty)
      baseScore += 5;

    // Bonus pour le niveau d'études
    if (candidat.niveauEtude == 'Bac+5') {
      baseScore += 10;
    } else if (candidat.niveauEtude == 'Bac+3')
      baseScore += 5;

    // Bonus aléatoire pour la simulation
    baseScore += (candidat.nomComplet.hashCode % 20);

    return baseScore.clamp(0, 100);
  }
}

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // Base de données de questions/réponses
  final Map<String, String> _faqDatabase = {
    'comment créer une offre':
        'Pour créer une offre d\'emploi, allez dans "Offres" puis cliquez sur "Créer une offre". Remplissez tous les champs requis et publiez votre offre.',
    'comment modifier mon profil':
        'Pour modifier votre profil, cliquez sur l\'icône entreprise en haut à droite, puis sur l\'icône crayon pour activer le mode édition.',
    'comment rechercher des candidats':
        'Utilisez la section "Candidats" pour rechercher et filtrer les profils selon vos critères.',
    'mot de passe oublié':
        'Pour réinitialiser votre mot de passe, allez sur la page de connexion et cliquez sur "Mot de passe oublié".',
    'problème de connexion':
        'Vérifiez votre connexion internet et essayez de vous reconnecter. Si le problème persiste, contactez le support.',
    'comment supprimer mon compte':
        'Allez dans Paramètres > Confidentialité > Suppression du compte pour supprimer définitivement votre compte.',
    'aide':
        'Je suis là pour vous aider ! Posez-moi votre question et je ferai de mon mieux pour vous répondre.',
    'bonjour': 'Bonjour ! Comment puis-je vous aider aujourd\'hui ?',
    'merci': 'De rien ! N\'hésitez pas si vous avez d\'autres questions.',
  };

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      'Bonjour ! Je suis votre assistant virtuel. Comment puis-je vous aider ?',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: false, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _addBotMessageWithCopyButton() {
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              'Cliquez sur le bouton ci-dessous pour copier le numéro CENADI :',
          isUser: false,
          timestamp: DateTime.now(),
          hasCopyButton: true,
        ),
      );
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();

    // Simuler un délai de réponse du bot
    Future.delayed(const Duration(milliseconds: 1000), () {
      _processUserMessage(message);
    });
  }

  void _processUserMessage(String message) {
    final lowerMessage = message.toLowerCase();

    // Chercher une correspondance dans la base de données
    String? response;
    for (String key in _faqDatabase.keys) {
      if (lowerMessage.contains(key)) {
        response = _faqDatabase[key];
        break;
      }
    }

    if (response != null) {
      _addBotMessage(response);
    } else {
      _addBotMessage(
        'Je ne trouve pas de réponse à votre question dans ma base de données. Pour une assistance personnalisée, contactez notre équipe CENADI sur WhatsApp au 676295488.',
      );
      // Ajouter un message avec bouton de copie
      Future.delayed(const Duration(milliseconds: 500), () {
        _addBotMessageWithCopyButton();
      });
    }
  }

  void _openWhatsApp() {
    const phoneNumber = '676295488';

    // Copier le numéro dans le presse-papier
    Clipboard.setData(ClipboardData(text: phoneNumber));

    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Numéro CENADI copié: $phoneNumber'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Ouvrir WhatsApp',
          textColor: Colors.white,
          onPressed: () {
            // Ici vous pourriez utiliser url_launcher pour ouvrir WhatsApp
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ouvrez WhatsApp et collez le numéro: 676295488'),
                backgroundColor: Colors.blue,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg']!,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.support_agent,
                color: RecruiterTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support Client',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Assistant virtuel CENADI',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Tapez votre message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: RecruiterTheme.primaryColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // WhatsApp button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openWhatsApp,
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text(
                      'Contacter CENADI sur WhatsApp',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: RecruiterTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: RecruiterTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? RecruiterTheme.primaryColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (message.hasCopyButton) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: '676295488'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Numéro CENADI copié: 676295488'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copier le numéro'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool hasCopyButton;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.hasCopyButton = false,
  });
}
