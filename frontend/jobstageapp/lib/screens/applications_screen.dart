import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard_screen.dart';
import '../services/application_service.dart';
import '../models/candidature.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with TickerProviderStateMixin {
  String selectedTab = 'En cours';
  String selectedFilter = 'En cours'; // Nouveau: pour le filtre des cartes
  final List<String> tabs = ['En cours', 'Acceptées', 'Refusées', 'Toutes'];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> applications = [
    {
      'title': 'Développeur Flutter Junior',
      'company': 'TechCorp Cameroun',
      'location': 'Yaoundé',
      'appliedDate': '15 Sep 2024',
      'status': 'En cours',
      'statusColor': AppColors.orangeDark,
      'progress': 2,
      'totalSteps': 4,
      'nextStep': 'Entretien technique',
      'salary': '400,000 - 600,000 FCFA',
    },
    {
      'title': 'Analyste Junior',
      'company': 'Data Solutions',
      'location': 'Douala',
      'appliedDate': '12 Sep 2024',
      'status': 'En cours',
      'statusColor': AppColors.orangeDark,
      'progress': 1,
      'totalSteps': 3,
      'nextStep': 'Révision du CV',
      'salary': '350,000 - 500,000 FCFA',
    },
    {
      'title': 'Stage Marketing Digital',
      'company': 'Innovation Hub',
      'location': 'Yaoundé',
      'appliedDate': '10 Sep 2024',
      'status': 'Acceptées',
      'statusColor': AppColors.greenDark,
      'progress': 3,
      'totalSteps': 3,
      'nextStep': 'Signature du contrat',
      'salary': '150,000 FCFA',
    },
    {
      'title': 'Développeur Web',
      'company': 'WebCorp',
      'location': 'Douala',
      'appliedDate': '08 Sep 2024',
      'status': 'Refusées',
      'statusColor': Colors.red,
      'progress': 1,
      'totalSteps': 3,
      'nextStep': 'Candidature fermée',
      'salary': '450,000 - 600,000 FCFA',
    },
    {
      'title': 'UI/UX Designer',
      'company': 'Creative Agency',
      'location': 'Yaoundé',
      'appliedDate': '05 Sep 2024',
      'status': 'En cours',
      'statusColor': AppColors.orangeDark,
      'progress': 3,
      'totalSteps': 4,
      'nextStep': 'Entretien final',
      'salary': '450,000 - 700,000 FCFA',
    },
  ];

  List<Map<String, dynamic>> get filteredApplications {
    if (selectedFilter == 'Toutes') return applications;
    return applications
        .where((app) => app['status'] == selectedFilter)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          'Mes Candidatures',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab selector
          Container(
            color: AppColors.blueDark,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: tabs.map((tab) {
                  final isSelected = selectedTab == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = tab;
                          selectedFilter =
                              tab; // Synchroniser le filtre avec l'onglet
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(21),
                        ),
                        child: Center(
                          child: Text(
                            tab,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.blueDark
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Statistics
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildAnimatedStatCard(
                    'Total',
                    applications.length.toString(),
                    AppColors.blueDark,
                    Icons.assignment,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAnimatedStatCard(
                    'En cours',
                    applications
                        .where((a) => a['status'] == 'En cours')
                        .length
                        .toString(),
                    AppColors.orangeDark,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAnimatedStatCard(
                    'Acceptées',
                    applications
                        .where((a) => a['status'] == 'Acceptées')
                        .length
                        .toString(),
                    AppColors.greenDark,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),
          // Applications list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredApplications.length,
              itemBuilder: (context, index) {
                final application = filteredApplications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildApplicationCard(application),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    final isSelected = selectedFilter == title;

    return GestureDetector(
      onTap: () {
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        setState(() {
          selectedFilter = title;
          selectedTab = title; // Synchroniser avec l'onglet
        });
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? 0.95 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: color, width: 2) : null,
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? color.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? color : color.withValues(alpha: 0.7),
                    size: isSelected ? 28 : 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: GoogleFonts.roboto(
                      fontSize: isSelected ? 22 : 20,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : color.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? color : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    return GestureDetector(
      onTap: () => _showApplicationDetails(application),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border(
            left: BorderSide(color: application['statusColor'], width: 5),
          ),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['title'],
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application['company'],
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: application['statusColor'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    application['status'],
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Progress bar
            Row(
              children: [
                Text(
                  'Progression: ',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                Text(
                  '${application['progress']}/${application['totalSteps']}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: application['progress'] / application['totalSteps'],
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                application['statusColor'],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.orangeDark),
                const SizedBox(width: 5),
                Text(
                  application['location'],
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 15),
                Icon(Icons.calendar_today, size: 16, color: AppColors.blueDark),
                const SizedBox(width: 5),
                Text(
                  application['appliedDate'],
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  'Prochaine étape: ${application['nextStep']}',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApplicationDetails(Map<String, dynamic> application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
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
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['title'],
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        application['company'],
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Timeline
                      Text(
                        'Suivi de candidature',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildTimeline(application),
                      const SizedBox(height: 20),
                      _buildDetailRow('Salaire', application['salary']),
                      _buildDetailRow('Localisation', application['location']),
                      _buildDetailRow(
                        'Date de candidature',
                        application['appliedDate'],
                      ),
                      _buildDetailRow('Statut', application['status']),
                      const SizedBox(height: 30),
                      if (application['status'] == 'En cours') ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showCancelDialog(application);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Annuler la candidature',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTimeline(Map<String, dynamic> application) {
    final steps = [
      'Candidature envoyée',
      'CV examiné',
      'Entretien RH',
      'Entretien technique',
      'Décision finale',
    ];
    final currentStep = application['progress'];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final step = entry.value;
        final isCompleted = index <= currentStep;
        final isCurrent = index == currentStep + 1;

        return Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.greenDark
                    : (isCurrent ? AppColors.orangeDark : Colors.grey[300]),
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                step,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isCompleted || isCurrent
                      ? AppColors.primaryText
                      : AppColors.secondaryText,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Annuler la candidature',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir annuler votre candidature pour "${application['title']}" ?',
          style: GoogleFonts.roboto(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Non',
              style: GoogleFonts.roboto(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Candidature annulée'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
              'Oui, annuler',
              style: GoogleFonts.roboto(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
