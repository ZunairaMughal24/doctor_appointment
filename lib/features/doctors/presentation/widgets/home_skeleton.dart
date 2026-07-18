import 'package:flutter/material.dart';
import 'package:medic/core/widgets/skeleton_loader.dart';
import 'package:medic/features/doctors/presentation/widgets/home_sections.dart'
    show kHomeHorizontalPadding;

/// Static skeleton for the home screen, shown while doctors load.
/// Mirrors the real layout: header, featured cards, categories,
/// available doctors, and recommended doctors.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
                kHomeHorizontalPadding, 20, kHomeHorizontalPadding, 12),
            child: Row(
              children: [
                const SkeletonLoader(width: 54, height: 54, borderRadius: 27),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLoader(width: 130, height: 18),
                    SizedBox(height: 8),
                    SkeletonLoader(width: 190, height: 13),
                  ],
                ),
              ],
            ),
          ),

          // ── Search bar ──────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding),
            child: SkeletonLoader(
                width: double.infinity, height: 50, borderRadius: 16),
          ),
          const SizedBox(height: 28),

          // ── Featured cards ──────────────────────────────────────
          _horizontalRow(cardWidth: 255, cardHeight: 160, count: 2),
          const SizedBox(height: 24),

          // ── Categories ──────────────────────────────────────────
          _sectionHeader(),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding),
            child: Row(
              children: List.generate(
                5,
                (_) => const Padding(
                  padding: EdgeInsets.only(right: 18),
                  child: Column(
                    children: [
                      SkeletonLoader(width: 50, height: 50, borderRadius: 14),
                      SizedBox(height: 8),
                      SkeletonLoader(width: 46, height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Available doctors ───────────────────────────────────
          _sectionHeader(),
          const SizedBox(height: 14),
          _horizontalRow(cardWidth: 230, cardHeight: 140, count: 2),
          const SizedBox(height: 24),

          // ── Recommended doctors ─────────────────────────────────
          _sectionHeader(),
          const SizedBox(height: 14),
          _horizontalRow(cardWidth: 130, cardHeight: 160, count: 3),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionHeader() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonLoader(width: 150, height: 20),
            SkeletonLoader(width: 50, height: 16),
          ],
        ),
      );

  Widget _horizontalRow({
    required double cardWidth,
    required double cardHeight,
    required int count,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding:
          const EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding),
      child: Row(
        children: List.generate(
          count,
          (_) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SkeletonLoader(
              width: cardWidth,
              height: cardHeight,
              borderRadius: 12,
            ),
          ),
        ),
      ),
    );
  }
}
