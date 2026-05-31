import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_loader.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import '../widgets/doctor_card.dart';

class AllDoctorsPage extends StatelessWidget {
  final String? speciality;

  const AllDoctorsPage({super.key, this.speciality});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<DoctorBloc>();
        if (speciality != null && speciality!.isNotEmpty) {
          bloc.add(LoadDoctorsBySpeciality(speciality!));
        } else {
          bloc.add(const LoadAllDoctors());
        }
        return bloc;
      },
      child: _AllDoctorsView(speciality: speciality),
    );
  }
}

class _AllDoctorsView extends StatelessWidget {
  final String? speciality;
  const _AllDoctorsView({this.speciality});

  @override
  Widget build(BuildContext context) {
    final title =
        speciality != null && speciality!.isNotEmpty ? speciality! : 'All Doctors';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          if (state is DoctorLoading) return const AppLoader();
          if (state is DoctorError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: AppColors.error)));
          }
          if (state is DoctorsLoaded) {
            if (state.doctors.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off,
                        size: 64, color: AppColors.textHint),
                    SizedBox(height: 12),
                    Text('No doctors found',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: state.doctors.length,
              itemBuilder: (context, index) {
                final doctor = state.doctors[index];
                return DoctorCard(
                  doctor: doctor,
                  onTap: () => context.push(
                    AppRoutes.doctorDetailPath(doctor.id),
                    extra: doctor,
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
