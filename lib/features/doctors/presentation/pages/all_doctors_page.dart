import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import '../widgets/doctor_list_tile.dart';

class AllDoctorsPage extends StatelessWidget {
  final String? speciality;
  const AllDoctorsPage({super.key, this.speciality});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<DoctorBloc>();
        if (speciality != null) {
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
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          speciality ?? 'All Specialists',
          style: const TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          if (state is DoctorInitial || state is DoctorLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DoctorsLoaded) {
            final doctors = state.doctors;

            if (doctors.isEmpty) {
              return const Center(child: Text('No doctors found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(14.0),
              physics: const BouncingScrollPhysics(),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return DoctorListTile(
                  doctor: doctor,
                  tileColor: AppColors.doctorTileColors[index % AppColors.doctorTileColors.length],
                  image: AppAssets.doctorAvatars[index % AppAssets.doctorAvatars.length],
                  onTap: () => context.push(
                    AppRoutes.doctorDetailPath(doctor.id),
                    extra: doctor,
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Error loading doctors'));
        },
      ),
    );
  }
}

