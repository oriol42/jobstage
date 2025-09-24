import 'package:flutter/material.dart';
import '../../../theme/recruiter_theme.dart';
import 'create_offer_page.dart';
import '../../../utils/navigation_helper.dart';
import 'offers_list_page.dart';

class OfferDetailsPage extends StatefulWidget {
  final dynamic offre;

  const OfferDetailsPage({super.key, required this.offre});

  @override
  State<OfferDetailsPage> createState() => _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {
  String _offerStatus = 'active'; // active, paused, disabled

  @override
  Widget build(BuildContext context) {
    print('📱 OfferDetailsPage.build() appelé');
    print('   - offre: ${widget.offre?.titre}');
    return Scaffold(
      backgroundColor: RecruiterTheme.customColors['surface_bg'],
      appBar: NavigationHelper.createAppBar(
        context,
        title: 'Détails de l\'offre',
        backgroundColor: RecruiterTheme.primaryColor,
        foregroundColor: Colors.white,
        fallbackScreen: const OffersListPage(),
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeOfferStatus,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'active',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Activer'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'paused',
                child: Row(
                  children: [
                    Icon(Icons.pause, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Mettre en pause'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'disabled',
                child: Row(
                  children: [
                    Icon(Icons.stop, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Désactiver'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor()),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getStatusIcon(), size: 16, color: _getStatusColor()),
                  const SizedBox(width: 4),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: _getStatusColor(),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Modifier'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildOfferHeader(), _buildOfferDetails()],
        ),
      ),
    );
  }

  Widget _buildOfferHeader() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.offre.titre,
                  style: RecruiterTheme.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: RecruiterTheme.customColors['primary_text'],
                  ),
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.business,
                size: 16,
                color: RecruiterTheme.customColors['secondary_text'],
              ),
              const SizedBox(width: 4),
              Text(
                widget.offre.entreprise,
                style: RecruiterTheme.bodyMedium.copyWith(
                  color: RecruiterTheme.customColors['secondary_text'],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.location_on,
                size: 16,
                color: RecruiterTheme.customColors['secondary_text'],
              ),
              const SizedBox(width: 4),
              Text(
                widget.offre.lieu,
                style: RecruiterTheme.bodyMedium.copyWith(
                  color: RecruiterTheme.customColors['secondary_text'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Publiée le ${_formatDate(widget.offre.datePublication)}',
            style: RecruiterTheme.bodySmall.copyWith(
              color: RecruiterTheme.customColors['secondary_text'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusText(),
        style: RecruiterTheme.labelSmall.copyWith(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOfferDetails() {
    return Container(
      margin: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: RecruiterTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.offre.description,
            style: RecruiterTheme.bodyMedium.copyWith(height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildDetailRow(
            'Type de contrat',
            widget.offre.typeContrat,
            Icons.work,
          ),
          _buildDetailRow(
            'Niveau d\'expérience',
            widget.offre.niveauExperience,
            Icons.trending_up,
          ),
          if (widget.offre.salaire.isNotEmpty)
            _buildDetailRow(
              'Salaire',
              widget.offre.salaire,
              Icons.attach_money,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: RecruiterTheme.customColors['secondary_text'],
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
                color: RecruiterTheme.customColors['secondary_text'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _changeOfferStatus(String status) {
    setState(() {
      _offerStatus = status;
    });

    String message = '';
    Color backgroundColor = Colors.green;

    switch (status) {
      case 'active':
        message = 'Offre activée';
        backgroundColor = Colors.green;
        break;
      case 'paused':
        message = 'Offre mise en pause';
        backgroundColor = Colors.orange;
        break;
      case 'disabled':
        message = 'Offre désactivée';
        backgroundColor = Colors.red;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Color _getStatusColor() {
    switch (_offerStatus) {
      case 'active':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'disabled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_offerStatus) {
      case 'active':
        return Icons.play_arrow;
      case 'paused':
        return Icons.pause;
      case 'disabled':
        return Icons.stop;
      default:
        return Icons.help;
    }
  }

  String _getStatusText() {
    switch (_offerStatus) {
      case 'active':
        return 'Active';
      case 'paused':
        return 'En pause';
      case 'disabled':
        return 'Désactivée';
      default:
        return 'Inconnu';
    }
  }

  void _handleMenuAction(dynamic value) {
    switch (value) {
      case 'edit':
        _editOffer();
        break;
      case 'delete':
        _deleteOffer();
        break;
    }
  }

  void _editOffer() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CreateOfferPage(offreToEdit: widget.offre),
          ),
        )
        .then((_) {
          // Recharger les données après modification
          setState(() {
            // Les données seront rechargées automatiquement
          });
        });
  }

  void _deleteOffer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'offre'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette offre ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Offre supprimée')));
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
