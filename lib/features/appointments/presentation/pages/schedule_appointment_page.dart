import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fyp/core/constants/app_colors.dart';
import 'package:fyp/core/di/injection_container.dart';
import 'package:fyp/core/router/app_router.dart';
import 'package:fyp/core/utils/app_feedback.dart';
import 'package:fyp/features/appointments/domain/entities/appointment_entity.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_state.dart';
import 'package:fyp/features/appointments/presentation/cubit/slots_cubit.dart';
import 'package:fyp/features/appointments/presentation/viewmodels/schedule_appointment_viewmodel.dart';
import 'package:fyp/features/appointments/presentation/widgets/schedule_widgets.dart';
import 'package:fyp/features/doctors/domain/entities/doctor_entity.dart';
import 'package:fyp/core/widgets/custom_app_bar.dart';

class ScheduleAppointmentPage extends StatelessWidget {
  final DoctorEntity doctor;
  const ScheduleAppointmentPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SlotsCubit>(),
      child: _ScheduleView(doctor: doctor),
    );
  }
}

class _ScheduleView extends StatefulWidget {
  final DoctorEntity doctor;
  const _ScheduleView({required this.doctor});

  @override
  State<_ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<_ScheduleView> {
  late final ScheduleAppointmentViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ScheduleAppointmentViewModel(widget.doctor);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: CustomAppBar(
        title: widget.doctor.name,
        onBackPressed: () => context.pop(),
      ),
      body: BlocListener<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentBooked) {
            AppFeedback.showSuccess(context, 'Appointment booked successfully!');
            context.go(AppRoutes.appointments);
          } else if (state is AppointmentError) {
            AppFeedback.showError(context, state.message);
            _vm.refreshSlots(context);
          }
        },
        child: Form(
          key: _vm.formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            physics: const BouncingScrollPhysics(),
            children: [
              const ScheduleSectionLabel('Consultation type'),
              ConsultationToggle(
                selected: _vm.consultationType,
                onChanged: (t) => setState(() => _vm.setConsultationType(t)),
              ),
              if (_vm.consultationType == ConsultationType.video) ...[
                const SizedBox(height: 10),
                const VideoConsultationNote(),
              ],
              const SizedBox(height: 8),
              const ScheduleSectionLabel('Your name'),
              ScheduleField(
                controller: _vm.nameController,
                hint: 'Enter your full name',
                maxLength: 40,
                validator: _vm.nameValidator,
              ),
              const ScheduleSectionLabel('Contact number'),
              ScheduleField(
                controller: _vm.phoneController,
                hint: 'Enter your number',
                keyboardType: TextInputType.phone,
                maxLength: 15,
                validator: _vm.phoneValidator,
              ),
              const ScheduleSectionLabel('Appointment date'),
              ScheduleDateSelector(
                label: _vm.hasDate
                    ? '${_vm.selectedDay}, ${_vm.formattedDate}'
                    : 'Tap to pick a date',
                isPlaceholder: !_vm.hasDate,
                onTap: () async {
                  if (await _vm.pickDate(context) && mounted) setState(() {});
                },
              ),
              const SizedBox(height: 16),
              const ScheduleSectionLabel('Available slots'),
              ScheduleSlotsArea(vm: _vm, onPick: (t) => setState(() => _vm.selectTime(t))),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: BlocBuilder<AppointmentBloc, AppointmentState>(
            builder: (context, state) => ScheduleSubmitButton(
              loading: state is AppointmentLoading,
              onTap: () {
                final error = _vm.submit(context);
                if (error != null) AppFeedback.showError(context, error);
              },
            ),
          ),
        ),
      ),
    );
  }
}
