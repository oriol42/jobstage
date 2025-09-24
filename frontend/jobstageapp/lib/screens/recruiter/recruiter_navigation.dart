import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import 'recruiter_dashboard.dart';
import 'offers/offers_list_page.dart';
import 'candidates/matches_page.dart';
import 'candidates/recruiter_applications_page.dart';
import 'settings/settings_page.dart';

class RecruiterNavigation extends StatefulWidget {
  const RecruiterNavigation({super.key});

  @override
  State<RecruiterNavigation> createState() => _RecruiterNavigationState();
}

class _RecruiterNavigationState extends State<RecruiterNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home,
      label: 'Accueil',
      page: const RecruiterDashboard(),
    ),
    NavigationItem(
      icon: Icons.work,
      label: 'Offres',
      page: const OffersListPage(),
    ),
    NavigationItem(
      icon: Icons.group,
      label: 'Candidats',
      page: const MatchesPage(),
    ),
    NavigationItem(
      icon: Icons.assignment,
      label: 'Candidatures',
      page: const RecruiterApplicationsPage(),
    ),
    NavigationItem(
      icon: Icons.settings,
      label: 'Paramètres',
      page: const SettingsPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _navigationItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 5,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                      });
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? RecruiterTheme.primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? RecruiterTheme.primaryColor
                                : Colors.grey[600],
                            size: 22,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: RecruiterTheme.labelSmall.copyWith(
                              color: isSelected
                                  ? RecruiterTheme.primaryColor
                                  : Colors.grey[600],
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget page;

  NavigationItem({required this.icon, required this.label, required this.page});
}
