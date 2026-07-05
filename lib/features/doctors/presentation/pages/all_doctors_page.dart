import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_loader.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import '../viewmodels/all_doctors_view_model.dart';
import '../widgets/doctor_list_tile.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class AllDoctorsPage extends StatefulWidget {
  final String? speciality;
  const AllDoctorsPage({super.key, this.speciality});

  @override
  State<AllDoctorsPage> createState() => _AllDoctorsPageState();
}

class _AllDoctorsPageState extends State<AllDoctorsPage> {
  static const _vm = AllDoctorsViewModel();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<DoctorBloc>();
    if (bloc.state is DoctorInitial) bloc.add(const LoadAllDoctors());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: CustomAppBar(
        title: widget.speciality ?? 'All Specialists',
        forceShowBack: true,
        onBackPressed: () => context.go(AppRoutes.home),
      ),
      body: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          if (state is DoctorInitial || state is DoctorLoading) {
            return const AppLoader();
          }

          if (state is DoctorsLoaded) {
            final doctors = _vm.filter(state.doctors, widget.speciality);

            if (doctors.isEmpty) {
              return const Center(child: Text('No doctors found'));
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<DoctorBloc>().add(const LoadAllDoctors()),
              child: ListView.builder(
                padding: const EdgeInsets.all(14.0),
                physics: const BouncingScrollPhysics(),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return DoctorListTile(
                    doctor: doctor,
                    tileColor: AppColors.doctorTileColors[
                        index % AppColors.doctorTileColors.length],
                    image: AppAssets.doctorAvatars[
                        index % AppAssets.doctorAvatars.length],
                    onTap: () => _vm.openDoctor(context, doctor),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Error loading doctors'));
        },
      ),
    );
  }
}
