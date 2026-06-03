import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_container.dart';

class DoctorCardFeatured extends StatelessWidget {
  final String name;
  final String speciality;
  final String availability;
  final double rating;

  const DoctorCardFeatured({
    super.key,
    required this.name,
    required this.speciality,
    required this.rating,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(
                  fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
          Text(speciality,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(availability,
              style: const TextStyle(fontSize: 12, color: Colors.white70)),
          _StarRow(rating: rating, color: Colors.yellow, textColor: Colors.white70),
          const Row(children: [
            Icon(Icons.call, size: 15, color: Colors.white),
            SizedBox(width: 5),
            Text('Contact',
                style: TextStyle(
                    fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white)),
          ]),
          const SizedBox(height: 7),
          Container(
            height: 25,
            width: 85,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Center(
              child: Text('Approach me',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark)),
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorCardAvailable extends StatelessWidget {
  final String name;
  final String speciality;
  final String availability;
  final String experience;
  final double rating;

  const DoctorCardAvailable({
    super.key,
    required this.name,
    required this.speciality,
    required this.rating,
    required this.availability,
    required this.experience,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.bold)),
          Text(speciality,
              style: const TextStyle(fontSize: 13, color: AppColors.textRed)),
          Text(availability,
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
          _StarRow(rating: rating, color: AppColors.primaryDark, textColor: AppColors.primary),
          Text(experience,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary)),
          const SizedBox(height: 5),
          Container(
            height: 25,
            width: 73,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Center(
              child: Text('Book now',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorCardCompact extends StatelessWidget {
  final String name;
  final String speciality;
  final double rating;
  final String availability;

  const DoctorCardCompact({
    super.key,
    required this.name,
    required this.speciality,
    required this.rating,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold)),
        Text(speciality,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textRed, fontSize: 12)),
        const SizedBox(height: 3),
        _StarRow(rating: rating, color: AppColors.primary, textColor: AppColors.primary),
        if (availability.isNotEmpty) ...[
          const SizedBox(height: 4),
          _AvailabilityChip(text: availability),
        ],
      ],
    );
  }
}

/// Compact "available timing" chip — mirrors the top-row availability style.
class _AvailabilityChip extends StatelessWidget {
  final String text;
  const _AvailabilityChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time_rounded,
            size: 11, color: AppColors.primary),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Search bar with built-in navigation to search results.
class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      padding: EdgeInsets.zero,
      borderRadius: 14,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search for a Doctor....',
          hintStyle: const TextStyle(color: AppColors.textHint),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          suffixIcon: GestureDetector(
            onTap: () {
              if (_controller.text.isNotEmpty) {
                context.push('${AppRoutes.search}?q=${_controller.text}');
              }
            },
            child: const Icon(Icons.send, color: AppColors.primaryDark),
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryDark),
        ),
      ),
    );
  }
}

// ── Shared star-rating row ────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final double rating;
  final Color color;
  final Color textColor;

  const _StarRow({
    required this.rating,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Row(
          children: List.generate(
              5,
              (i) => Icon(
                    i < rating.round() ? Icons.star : Icons.star_border,
                    size: 10,
                    color: color,
                  ))),
      const SizedBox(width: 4),
      Text(rating.toStringAsFixed(1),
          style: TextStyle(fontSize: 10, color: textColor)),
    ]);
  }
}
