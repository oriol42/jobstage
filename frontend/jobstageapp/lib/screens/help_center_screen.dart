import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  String selectedCategory = 'Général';
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'Général',
    'Compte',
    'Candidatures',
    'Recherche d\'emploi',
    'Profil',
    'Notifications',
    'Paiements',
    'Technique',
  ];

  final Map<String, List<Map<String, String>>> faqData = {
    'Général': [
      {
        'question': 'Comment créer un compte ?',
        'answer':
            'Pour créer un compte, cliquez sur "S\'inscrire" sur la page d\'accueil, remplissez le formulaire avec vos informations et confirmez votre email.',
      },
      {
        'question': 'Comment réinitialiser mon mot de passe ?',
        'answer':
            'Allez dans Paramètres > Compte > Mot de passe, puis suivez les instructions pour réinitialiser votre mot de passe.',
      },
      {
        'question': 'L\'application est-elle gratuite ?',
        'answer':
            'Oui, l\'application JobStage est entièrement gratuite pour les candidats. Certaines fonctionnalités premium peuvent être ajoutées à l\'avenir.',
      },
    ],
    'Compte': [
      {
        'question': 'Comment modifier mes informations personnelles ?',
        'answer':
            'Allez dans "Mon Profil" et cliquez sur l\'icône d\'édition pour modifier vos informations personnelles.',
      },
      {
        'question': 'Comment supprimer mon compte ?',
        'answer':
            'Allez dans Paramètres > Confidentialité > Supprimer mon compte. Cette action est irréversible.',
      },
      {
        'question': 'Comment changer mon email ?',
        'answer':
            'Dans "Mon Profil", modifiez votre email et confirmez le changement via le lien envoyé à votre nouvelle adresse.',
      },
    ],
    'Candidatures': [
      {
        'question': 'Comment postuler à une offre ?',
        'answer':
            'Trouvez l\'offre qui vous intéresse, cliquez sur "Postuler" et suivez les instructions. Votre candidature sera envoyée à l\'employeur.',
      },
      {
        'question': 'Comment suivre mes candidatures ?',
        'answer':
            'Allez dans "Mes Candidatures" pour voir le statut de toutes vos candidatures et leur progression.',
      },
      {
        'question': 'Puis-je annuler une candidature ?',
        'answer':
            'Oui, dans "Mes Candidatures", vous pouvez annuler une candidature si elle est encore "En cours".',
      },
    ],
    'Recherche d\'emploi': [
      {
        'question': 'Comment utiliser les filtres de recherche ?',
        'answer':
            'Utilisez les filtres par type d\'emploi, localisation, salaire et mots-clés pour affiner votre recherche.',
      },
      {
        'question': 'Comment sauvegarder des offres ?',
        'answer':
            'Cliquez sur l\'icône cœur à côté d\'une offre pour l\'ajouter à vos favoris.',
      },
      {
        'question': 'Comment recevoir des alertes d\'emploi ?',
        'answer':
            'Activez les notifications dans Paramètres > Notifications pour recevoir des alertes sur les nouvelles offres.',
      },
    ],
    'Profil': [
      {
        'question': 'Comment optimiser mon profil ?',
        'answer':
            'Complétez toutes les sections, ajoutez une photo professionnelle, et décrivez vos compétences et expériences.',
      },
      {
        'question': 'Comment télécharger mon CV ?',
        'answer':
            'Dans "Mon Profil", allez dans la section CV et cliquez sur "Télécharger" pour ajouter votre CV.',
      },
      {
        'question': 'Comment gérer ma visibilité ?',
        'answer':
            'Allez dans Paramètres > Confidentialité pour contrôler qui peut voir vos informations.',
      },
    ],
    'Notifications': [
      {
        'question': 'Comment gérer mes notifications ?',
        'answer':
            'Allez dans Paramètres > Notifications pour activer/désactiver les différents types de notifications.',
      },
      {
        'question': 'Pourquoi ne reçois-je pas de notifications ?',
        'answer':
            'Vérifiez que les notifications sont activées dans les paramètres de votre appareil et dans l\'application.',
      },
    ],
    'Paiements': [
      {
        'question': 'L\'application est-elle gratuite ?',
        'answer':
            'Oui, JobStage est entièrement gratuit pour les candidats. Aucun paiement n\'est requis.',
      },
    ],
    'Technique': [
      {
        'question': 'L\'application ne se lance pas, que faire ?',
        'answer':
            'Redémarrez l\'application, vérifiez votre connexion internet, ou réinstallez l\'application si le problème persiste.',
      },
      {
        'question': 'Comment signaler un bug ?',
        'answer':
            'Allez dans Paramètres > Support > Signaler un problème pour nous faire part du bug rencontré.',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          'Centre d\'aide',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            color: AppColors.blueDark,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rechercher dans l\'aide...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.blueDark,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Catégories
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.roboto(
                                color: isSelected
                                    ? AppColors.blueDark
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Contenu FAQ
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _getFilteredFAQs().length,
              itemBuilder: (context, index) {
                final faq = _getFilteredFAQs()[index];
                return _buildFAQItem(faq['question']!, faq['answer']!);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getFilteredFAQs() {
    final faqs = faqData[selectedCategory] ?? [];
    if (searchController.text.isEmpty) {
      return faqs;
    }
    return faqs.where((faq) {
      return faq['question']!.toLowerCase().contains(
            searchController.text.toLowerCase(),
          ) ||
          faq['answer']!.toLowerCase().contains(
            searchController.text.toLowerCase(),
          );
    }).toList();
  }

  Widget _buildFAQItem(String question, String answer) {
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
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.primaryText,
          ),
        ),
        iconColor: AppColors.blueDark,
        collapsedIconColor: AppColors.secondaryText,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
