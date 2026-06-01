import 'package:flutter/material.dart';
import 'package:fyp/core/widgets/skeleton_loader.dart';

/// Static skeleton for an appointments list, shown while data loads.
/// Each row matches the footprint of [AppointmentTile].
class AppointmentListSkeleton extends StatelessWidget {
  final int itemCount;
  const AppointmentListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const SkeletonLoader(
        width: double.infinity,
        height: 76,
        borderRadius: 14,
      ),
    );
  }
}
