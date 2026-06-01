import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterAsDoctorPage extends StatefulWidget {
  final String uid;
  final String prefillName;
  final String prefillEmail;

  const RegisterAsDoctorPage({
    super.key,
    required this.uid,
    required this.prefillName,
    required this.prefillEmail,
  });

  @override
  State<RegisterAsDoctorPage> createState() => _RegisterAsDoctorPageState();
}

class _RegisterAsDoctorPageState extends State<RegisterAsDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _specialityController = TextEditingController();
  final _experienceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _servicesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prefillName);
    _emailController = TextEditingController(text: widget.prefillEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _specialityController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _availabilityController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthRegisterAsDoctorRequested(
          uid: widget.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          speciality: _specialityController.text.trim(),
          experience: _experienceController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          location: _locationController.text.trim(),
          availability: _availabilityController.text.trim(),
          services: _servicesController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.user.hasDoctorProfile) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doctor profile created successfully!')),
          );
          context.go(AppRoutes.profile);
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: Container(
          height: screenHeight,
          width: screenWidth,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.primaryDark,
                AppColors.surface,
                AppColors.tabUnselected,
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: screenHeight * 0.04),
                const Text(
                  'Register as Doctor',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your name and email are pre-filled. Add your professional details below.',
                  style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 100, 120, 135)),
                ),
                SizedBox(height: screenHeight * 0.03),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        controller: _nameController,
                        hint: 'Full Name',
                        icon: Icons.person,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      _buildField(
                        controller: _emailController,
                        hint: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      _buildField(
                        controller: _specialityController,
                        hint: 'Speciality (e.g. Cardiologist)',
                        icon: Icons.medical_services,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      _buildField(
                        controller: _experienceController,
                        hint: 'Experience (e.g. 10 years)',
                        icon: Icons.workspace_premium,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      _buildField(
                        controller: _phoneController,
                        hint: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      _buildField(
                        controller: _locationController,
                        hint: 'Clinic / Hospital Location',
                        icon: Icons.location_on,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      _buildField(
                        controller: _availabilityController,
                        hint: 'Availability (e.g. Mon–Fri: 9am–5pm)',
                        icon: Icons.access_time,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      _buildField(
                        controller: _servicesController,
                        hint: 'Services (comma separated)',
                        icon: Icons.list_alt,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Container(
                      height: screenHeight * 0.06,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowCard,
                            offset: Offset(2, 3),
                            blurRadius: 0.5,
                          ),
                        ],
                      ),
                      child: state is AuthLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: Colors.white))
                          : TextButton(
                              onPressed: _submit,
                              child: const Text(
                                'Create Doctor Profile',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
                              ),
                            ),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              offset: Offset(2, 3),
              blurRadius: 0.5,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(
                fontSize: 15, color: AppColors.primary),
            prefixIcon:
                Icon(icon, color: AppColors.primary),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}


