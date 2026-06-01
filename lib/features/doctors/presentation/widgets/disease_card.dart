import 'package:flutter/material.dart';

import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/disease_entity.dart';

class DiseaseCard extends StatelessWidget {
  final DiseaseEntity disease;
  final VoidCallback onTap;

  const DiseaseCard({super.key, required this.disease, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: disease.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DiseaseIcon(imagePath: disease.imagePath, color: disease.color),
            const SizedBox(height: 8),
            Text(
              disease.name,
              style: AppTextStyles.label
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiseaseIcon extends StatelessWidget {
  final String imagePath;
  final Color color;

  const _DiseaseIcon({required this.imagePath, required this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: 48,
      height: 48,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.local_hospital_outlined,
        size: 40,
        color: Color(0xFF1565C0),
      ),
    );
  }
}
