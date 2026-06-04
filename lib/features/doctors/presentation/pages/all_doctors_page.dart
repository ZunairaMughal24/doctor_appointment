import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import '../viewmodels/all_doctors_view_model.dart';
import '../widgets/doctor_list_tile.dart';

class AllDoctorsPage extends StatelessWidget {
  final String? speciality;
  const AllDoctorsPage({super.key, this.speciality});

  @override
  Widget build(BuildContext context) {
    const vm = AllDoctorsViewModel();

    // Reuse the app-wide DoctorBloc loaded once at startup. Repeat visits (e.g.
    // tapping disease categories) read this cached list instantly — no refetch,
    // no loading spinner. Only trigger a load if it somehow hasn't loaded yet.
    final bloc = context.read<DoctorBloc>();
    if (bloc.state is DoctorInitial) bloc.add(const LoadAllDoctors());

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
            return const AppLoader();
          }

          if (state is DoctorsLoaded) {
            final doctors = vm.filter(state.doctors, speciality);

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
                  tileColor: AppColors
                      .doctorTileColors[index % AppColors.doctorTileColors.length],
                  image: AppAssets
                      .doctorAvatars[index % AppAssets.doctorAvatars.length],
                  onTap: () => vm.openDoctor(context, doctor),
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
