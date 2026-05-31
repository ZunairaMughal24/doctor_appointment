import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/entities/doctor_entity.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';

class DoctorDetailPage extends StatelessWidget {
  final String doctorId;
  final DoctorEntity? doctor;

  const DoctorDetailPage({super.key, required this.doctorId, this.doctor});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<DoctorBloc>()..add(LoadDoctorById(doctorId)),
      child: _DoctorDetailView(preloaded: doctor),
    );
  }
}

class _DoctorDetailView extends StatelessWidget {
  final DoctorEntity? preloaded;
  const _DoctorDetailView({this.preloaded});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          if (state is DoctorLoading && preloaded == null) {
            return const AppLoader();
          }
          final doctor =
              state is DoctorDetailLoaded ? state.doctor : preloaded;
          if (doctor == null) {
            return const Center(child: Text('Doctor not found.'));
          }
          return _buildContent(context, doctor);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DoctorEntity doctor) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context, doctor),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _infoRow(doctor),
              const SizedBox(height: 24),
              _section('About Doctor', doctor.description.isNotEmpty
                  ? doctor.description
                  : 'No description available.'),
              const SizedBox(height: 20),
              _detailsCard(doctor),
              const SizedBox(height: 20),
              _servicesCard(doctor),
              const SizedBox(height: 32),
              Row(
                children: [
                  _CallButton(phone: doctor.phoneNumber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      label: 'Book Appointment',
                      onPressed: () => context.push(
                        AppRoutes.scheduleAppointment,
                        extra: doctor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, DoctorEntity doctor) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _DoctorAvatar(doctor: doctor, size: 88),
                const SizedBox(height: 12),
                Text(
                  doctor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  doctor.speciality,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(DoctorEntity doctor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _InfoChip(
          icon: Icons.workspace_premium_outlined,
          label: doctor.experience,
          sublabel: 'Experience',
        ),
        _InfoChip(
          icon: Icons.star,
          label: doctor.rating.toStringAsFixed(1),
          sublabel: 'Rating',
          iconColor: Colors.amber,
        ),
        _InfoChip(
          icon: Icons.schedule_outlined,
          label: 'Available',
          sublabel: doctor.availability,
          iconColor: AppColors.success,
        ),
      ],
    );
  }

  Widget _section(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h4),
        const SizedBox(height: 8),
        Text(content,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary, height: 1.6)),
      ],
    );
  }

  Widget _detailsCard(DoctorEntity doctor) {
    return _Card(
      children: [
        _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: doctor.location),
        const Divider(height: 20),
        _DetailRow(
            icon: Icons.phone_outlined,
            label: 'Contact',
            value: doctor.phoneNumber),
      ],
    );
  }

  Widget _servicesCard(DoctorEntity doctor) {
    return _Card(
      children: [
        Text('Services', style: AppTextStyles.h4),
        const SizedBox(height: 10),
        ...doctor.services
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                        child:
                            Text(s, style: AppTextStyles.body)),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  final DoctorEntity doctor;
  final double size;
  const _DoctorAvatar({required this.doctor, required this.size});

  @override
  Widget build(BuildContext context) {
    if (doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 4),
        child: Image.network(doctor.imageUrl!,
            width: size, height: size, fit: BoxFit.cover),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Center(
        child: Text(
          doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color? iconColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.sublabel,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.label
                  .copyWith(fontWeight: FontWeight.bold)),
          Text(sublabel, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children),
    );
  }
}

class _CallButton extends StatelessWidget {
  final String phone;
  const _CallButton({required this.phone});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse('tel:$phone');
        if (await canLaunchUrl(uri)) launchUrl(uri);
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.call, color: AppColors.success),
      ),
    );
  }
}
