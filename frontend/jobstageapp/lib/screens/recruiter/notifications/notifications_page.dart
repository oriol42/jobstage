import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import '../../../services/recruiter_api_service.dart';
import '../../../models/notification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final RecruiterApiService _apiService = RecruiterApiService();
  List<NotificationModel> _notifications = [];
  String _filter = 'all'; // 'all', 'unread', 'read'

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = _apiService.notifications;
    });
  }

  List<NotificationModel> get _filteredNotifications {
    var filtered = _notifications;

    switch (_filter) {
      case 'unread':
        filtered = filtered.where((n) => !n.isLue).toList();
        break;
      case 'read':
        filtered = filtered.where((n) => n.isLue).toList();
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildNotificationsList()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Toutes',
            isSelected: _filter == 'all',
            onTap: () => _setFilter('all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Non lues',
            isSelected: _filter == 'unread',
            onTap: () => _setFilter('unread'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Lues',
            isSelected: _filter == 'read',
            onTap: () => _setFilter('read'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    final filteredNotifications = _filteredNotifications;

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isLue
            ? Colors.white
            : RecruiterTheme.customColors['blue_light']!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: notification.isLue
            ? null
            : Border.all(color: RecruiterTheme.primaryColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildNotificationIcon(notification.type),
        title: Text(
          notification.titre,
          style: RecruiterTheme.titleSmall.copyWith(
            fontWeight: notification.isLue ? FontWeight.w500 : FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message, style: RecruiterTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              notification.tempsEcoule,
              style: RecruiterTheme.bodySmall.copyWith(
                color: RecruiterTheme.customColors['secondary_text'],
              ),
            ),
          ],
        ),
        trailing: notification.isLue
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: RecruiterTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'nouvelle_candidature':
        icon = Icons.person_add;
        color = RecruiterTheme.customColors['green_dark']!;
        break;
      case 'candidat_match':
        icon = Icons.psychology;
        color = RecruiterTheme.customColors['purple_dark']!;
        break;
      case 'offre_expiree':
        icon = Icons.schedule;
        color = RecruiterTheme.customColors['orange_dark']!;
        break;
      case 'validation_profil':
        icon = Icons.verified;
        color = RecruiterTheme.customColors['blue_dark']!;
        break;
      default:
        icon = Icons.notifications;
        color = RecruiterTheme.customColors['secondary_text']!;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _filter == 'all'
                ? 'Aucune notification'
                : _filter == 'unread'
                ? 'Aucune notification non lue'
                : 'Aucune notification lue',
            style: RecruiterTheme.titleMedium.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _filter == 'all'
                ? 'Vous recevrez des notifications ici'
                : _filter == 'unread'
                ? 'Toutes vos notifications ont été lues'
                : 'Aucune notification n\'a encore été lue',
            style: RecruiterTheme.bodyMedium.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _setFilter(String filter) {
    setState(() {
      _filter = filter;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer les notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Toutes'),
              value: 'all',
              groupValue: _filter,
              onChanged: (value) {
                setState(() {
                  _filter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Non lues'),
              value: 'unread',
              groupValue: _filter,
              onChanged: (value) {
                setState(() {
                  _filter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Lues'),
              value: 'read',
              groupValue: _filter,
              onChanged: (value) {
                setState(() {
                  _filter = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _markAllAsRead() {
    for (final notification in _notifications) {
      if (!notification.isLue) {
        // TODO: Implémenter la méthode dans RecruiterApiService
        // _apiService.marquerNotificationCommeLue(notification.id);
      }
    }
    _loadNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Toutes les notifications ont été marquées comme lues'),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isLue) {
      // TODO: Implémenter la méthode dans RecruiterApiService
      // _apiService.marquerNotificationCommeLue(notification.id);
      _loadNotifications();
    }

    // Navigate based on notification type
    switch (notification.type) {
      case 'nouvelle_candidature':
        _navigateToCandidatures();
        break;
      case 'candidat_match':
        _navigateToMatches();
        break;
      case 'offre_expiree':
        _navigateToOffers();
        break;
      case 'validation_profil':
        _navigateToProfile();
        break;
    }
  }

  void _navigateToCandidatures() {
    // TODO: Navigate to candidatures page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers les candidatures')),
    );
  }

  void _navigateToMatches() {
    // TODO: Navigate to matches page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers les matches')),
    );
  }

  void _navigateToOffers() {
    // TODO: Navigate to offers page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigation vers les offres')));
  }

  void _navigateToProfile() {
    // TODO: Navigate to profile page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigation vers le profil')));
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? RecruiterTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? RecruiterTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: RecruiterTheme.labelMedium.copyWith(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
