import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class DoctorSignUpPage extends StatelessWidget {
  const DoctorSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _DoctorSignUpView(),
    );
  }
}

class _DoctorSignUpView extends StatefulWidget {
  const _DoctorSignUpView();

  @override
  State<_DoctorSignUpView> createState() => _DoctorSignUpViewState();
}

class _DoctorSignUpViewState extends State<_DoctorSignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _speciality = TextEditingController();
  final _experience = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _availability = TextEditingController();
  final _services = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    for (final c in [
      _name, _email, _password, _speciality, _experience,
      _phone, _location, _availability, _services,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(AuthSignUpDoctorRequested(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          speciality: _speciality.text.trim(),
          experience: _experience.text.trim(),
          phoneNumber: _phone.text.trim(),
          location: _location.text.trim(),
          availability: _availability.text.trim(),
          services: _services.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('${AppRoutes.myAppointments}?isDoctor=true');
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const Text(
                        'Doctor Registration',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Professional Info', style: AppTextStyles.h3),
                            const SizedBox(height: 4),
                            Text('Fill in your professional details',
                                style: AppTextStyles.bodySmall),
                            const SizedBox(height: 24),
                            _buildField(_name, 'Full name',
                                Icons.person_outline),
                            _buildField(_email, 'Email address',
                                Icons.email_outlined,
                                keyboard: TextInputType.emailAddress,
                                validator: Validators.email),
                            AppTextField(
                              controller: _password,
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              validator: Validators.password,
                              suffixWidget: GestureDetector(
                                onTap: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text('Practice Details', style: AppTextStyles.h4),
                            const SizedBox(height: 16),
                            _buildField(_speciality, 'Speciality (e.g. Cardiologist)',
                                Icons.medical_information_outlined),
                            _buildField(
                                _experience, 'Experience (e.g. 5 years)',
                                Icons.workspace_premium_outlined),
                            _buildField(_phone, 'Contact number',
                                Icons.phone_outlined,
                                keyboard: TextInputType.phone,
                                validator: Validators.phone),
                            _buildField(
                                _location, 'Hospital / Clinic location',
                                Icons.location_on_outlined),
                            _buildField(
                                _availability,
                                'Availability (e.g. Mon-Fri 9am-5pm)',
                                Icons.schedule_outlined),
                            AppTextField(
                              controller: _services,
                              hintText: 'Services offered',
                              prefixIcon: Icons.list_alt_outlined,
                              maxLines: 3,
                              validator: (v) =>
                                  Validators.required(v, 'Services'),
                            ),
                            const SizedBox(height: 32),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) => GradientButton(
                                label: 'Register as Doctor',
                                isLoading: state is AuthLoading,
                                onPressed: _submit,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppTextField(
        controller: controller,
        hintText: hint,
        prefixIcon: icon,
        keyboardType: keyboard,
        validator: validator ?? (v) => Validators.required(v, hint),
      ),
    );
  }
}
