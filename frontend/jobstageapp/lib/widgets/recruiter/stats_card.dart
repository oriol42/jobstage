import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int offresActives;
  final int candidats;
  final VoidCallback? onOffresTap;
  final VoidCallback? onCandidatsTap;

  const StatsCard({
    super.key,
    required this.offresActives,
    required this.candidats,
    this.onOffresTap,
    this.onCandidatsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
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
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onOffresTap,
              child: _StatItem(
                number: offresActives,
                label: 'Offres actives',
                color: const Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: GestureDetector(
              onTap: onCandidatsTap,
              child: _StatItem(
                number: candidats,
                label: 'Candidats',
                color: const Color(0xFF2196F3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int number;
  final String label;
  final Color color;

  const _StatItem({
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        children: [
          Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C3E50),
            ).copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ).copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
