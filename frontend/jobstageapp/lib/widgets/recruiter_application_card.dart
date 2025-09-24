import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/candidature.dart';
import '../dashboard_screen.dart';

class RecruiterApplicationCard extends StatelessWidget {
  final Candidature candidature;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsViewed;
  final VoidCallback? onPreSelect;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const RecruiterApplicationCard({
    super.key, 
    required this.candidature, 
    this.onTap,
    this.onMarkAsViewed,
    this.onPreSelect,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec candidat et statut
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidature.candidatNom?.isNotEmpty == true 
                            ? candidature.candidatNom!
                            : 'Candidat ${candidature.candidatId}',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        if (candidature.candidatEmail?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            candidature.candidatEmail!,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Candidature du ${_formatDate(candidature.dateCandidature)}',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(candidature.statut),
                ],
              ),

              const SizedBox(height: 12),

              // Informations de l'offre
              if (candidature.offreTitre?.isNotEmpty == true) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Offre',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidature.offreTitre!,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (candidature.offreEntreprise?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          candidature.offreEntreprise!,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Fichiers joints
              if (candidature.cvPath.isNotEmpty ||
                  candidature.lettreMotivationPath.isNotEmpty) ...[
                Row(
                  children: [
                    if (candidature.cvPath.isNotEmpty) ...[
                      _buildFileChip('CV', Icons.description, Colors.blue),
                      const SizedBox(width: 8),
                    ],
                    if (candidature.lettreMotivationPath.isNotEmpty)
                      _buildFileChip('Lettre', Icons.mail, Colors.green),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Actions rapides
              if (candidature.statut == 'envoyee') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onMarkAsViewed,
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Marquer comme vue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPreSelect,
                        icon: const Icon(Icons.star, size: 16),
                        label: const Text('Présélectionner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Accepter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Rejeter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Dates importantes
              Row(
                children: [
                  if (candidature.dateVue != null) ...[
                    Icon(Icons.visibility, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Vue le ${_formatDate(candidature.dateVue!)}',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (candidature.dateReponse != null) ...[
                    Icon(Icons.reply, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Réponse le ${_formatDate(candidature.dateReponse!)}',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileChip(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String statut) {
    final color = _getStatusColor(statut);
    final text = _getStatusText(statut);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'envoyee':
        return Colors.orange;
      case 'vue':
        return Colors.blue;
      case 'preselectionnee':
        return Colors.purple;
      case 'refusee':
        return Colors.red;
      case 'acceptee':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String statut) {
    switch (statut) {
      case 'envoyee':
        return 'Nouvelle';
      case 'vue':
        return 'Vue';
      case 'preselectionnee':
        return 'Présélectionnée';
      case 'refusee':
        return 'Rejetée';
      case 'acceptee':
        return 'Acceptée';
      default:
        return 'Inconnu';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
