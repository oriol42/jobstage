import 'package:flutter/material.dart';
import '../../models/candidat.dart';
import '../../theme/recruiter_theme.dart';

class CandidateCard extends StatelessWidget {
  final Candidat candidat;
  final VoidCallback? onTap;

  const CandidateCard({super.key, required this.candidat, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: RecruiterTheme.customColors['blue_dark']!,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              _CandidateAvatar(
                name: candidat.prenom,
                color: RecruiterTheme.customColors['blue_light']!,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidat.nomComplet,
                      style: RecruiterTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    _CandidateDetail(
                      icon: Icons.work,
                      text:
                          '${candidat.domaineEtude} • ${candidat.experienceAffichage}',
                    ),
                    if (candidat.localisation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _CandidateDetail(
                        icon: Icons.location_on,
                        text: candidat.localisation,
                      ),
                    ],
                    const SizedBox(height: 8),
                    _SkillsList(skills: candidat.competences),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CandidateActions(score: candidat.scoreMatching),
            ],
          ),
        ),
      ),
    );
  }
}

class _CandidateAvatar extends StatelessWidget {
  final String name;
  final Color color;

  const _CandidateAvatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Icon(
        Icons.person,
        color: RecruiterTheme.customColors['blue_dark'],
        size: 24,
      ),
    );
  }
}

class _CandidateDetail extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CandidateDetail({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: RecruiterTheme.customColors['secondary_text'],
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: RecruiterTheme.bodyMedium.copyWith(
              color: RecruiterTheme.customColors['secondary_text'],
            ),
          ),
        ),
      ],
    );
  }
}

class _SkillsList extends StatelessWidget {
  final List<String> skills;

  const _SkillsList({required this.skills});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: skills.take(3).map((skill) => _SkillTag(skill: skill)).toList(),
    );
  }
}

class _SkillTag extends StatelessWidget {
  final String skill;

  const _SkillTag({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: RecruiterTheme.customColors['blue_light'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        skill,
        style: RecruiterTheme.labelSmall.copyWith(
          color: RecruiterTheme.customColors['blue_dark'],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CandidateActions extends StatelessWidget {
  final double score;

  const _CandidateActions({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RecruiterTheme.customColors['green_dark']!,
            const Color(0xFF66BB6A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${score.toInt()}%',
        style: RecruiterTheme.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
