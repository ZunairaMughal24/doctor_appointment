import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    // If AuthBloc hasn't loaded the user yet (e.g. came from splash
    // without sign-in flow), trigger a check now
    if (state is! AuthAuthenticated) {
      context.read<AuthBloc>().add(const AuthCheckRequested());
    }
    final user = state is AuthAuthenticated ? state.user : null;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile(UserEntity user) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthUpdateProfileRequested(
          uid: user.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        ));
    setState(() => _editing = false);
  }

  void _switchRole(UserEntity user) {
    final newRole =
        user.role == UserRole.doctor ? UserRole.patient : UserRole.doctor;
    context.read<AuthBloc>().add(AuthSwitchRoleRequested(newRole));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.signIn);
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthAuthenticated) {
          _nameController.text = state.user.name;
          _emailController.text = state.user.email;
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = state.user;
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 249, 253, 255),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 11, 77, 105),
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              actions: [
                if (!_editing)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => setState(() => _editing = true),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() => _editing = false);
                      _nameController.text = user.name;
                      _emailController.text = user.email;
                    },
                  ),
              ],
            ),
            body: state is AuthLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      // ── Avatar ──────────────────────────────────────
                      Center(
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: const Color.fromARGB(255, 11, 77, 105),
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: user.isDoctor
                                ? const Color.fromARGB(255, 11, 77, 105)
                                : const Color.fromARGB(255, 212, 229, 243),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.isDoctor ? 'Doctor Mode' : 'Patient Mode',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: user.isDoctor
                                  ? Colors.white
                                  : const Color.fromARGB(255, 11, 77, 105),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Personal Info ────────────────────────────────
                      _sectionHeader('Personal Information'),
                      const SizedBox(height: 10),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildField(
                              label: 'Full Name',
                              controller: _nameController,
                              icon: Icons.person_outline,
                              enabled: _editing,
                              validator: (v) =>
                                  v!.isEmpty ? 'Name is required' : null,
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              label: 'Email',
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              enabled: _editing,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  v!.isEmpty ? 'Email is required' : null,
                            ),
                          ],
                        ),
                      ),
                      if (_editing) ...[
                        const SizedBox(height: 16),
                        _primaryButton(
                          label: 'Save Changes',
                          onTap: () => _saveProfile(user),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // ── Role Switching ───────────────────────────────
                      if (user.hasDoctorProfile) ...[
                        _sectionHeader('Account Mode'),
                        const SizedBox(height: 10),
                        _card(
                          child: Row(
                            children: [
                              Icon(
                                user.isDoctor
                                    ? Icons.medical_services_outlined
                                    : Icons.person_outlined,
                                color: const Color.fromARGB(255, 11, 77, 105),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.isDoctor
                                          ? 'Switch to Patient Mode'
                                          : 'Switch to Doctor Mode',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 11, 77, 105),
                                      ),
                                    ),
                                    Text(
                                      user.isDoctor
                                          ? 'Browse doctors & book appointments'
                                          : 'Manage your patient appointments',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(
                                              255, 130, 145, 157)),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: user.isDoctor,
                                activeThumbColor:
                                    const Color.fromARGB(255, 11, 77, 105),
                                onChanged: (_) => _switchRole(user),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // ── Become a Doctor ──────────────────────────────
                      if (!user.hasDoctorProfile) ...[
                        _sectionHeader('Professional Account'),
                        const SizedBox(height: 10),
                        _card(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor:
                                  Color.fromARGB(255, 212, 229, 243),
                              child: Icon(
                                Icons.medical_services_outlined,
                                color: Color.fromARGB(255, 11, 77, 105),
                              ),
                            ),
                            title: const Text(
                              'Register as Doctor',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color.fromARGB(255, 11, 77, 105),
                              ),
                            ),
                            subtitle: const Text(
                              'Add a professional profile to manage patient appointments',
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Color.fromARGB(255, 11, 77, 105),
                            ),
                            onTap: () => context.push(
                              AppRoutes.registerAsDoctor,
                              extra: {'name': user.name, 'email': user.email, 'uid': user.uid},
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // ── Sign Out ─────────────────────────────────────
                      _card(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 255, 235, 235),
                            child: Icon(Icons.logout,
                                color: Color.fromARGB(255, 180, 40, 40)),
                          ),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color.fromARGB(255, 180, 40, 40),
                            ),
                          ),
                          onTap: () {
                            context
                                .read<AuthBloc>()
                                .add(const AuthSignOutRequested());
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 120, 140, 155),
          letterSpacing: 0.8,
        ),
      );

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 210, 220, 230),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color.fromARGB(255, 245, 248, 252),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled
              ? const Color.fromARGB(255, 11, 77, 105)
              : const Color.fromARGB(255, 220, 228, 235),
        ),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Color.fromARGB(255, 11, 77, 105), fontSize: 14),
          prefixIcon:
              Icon(icon, color: const Color.fromARGB(255, 11, 77, 105), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 11, 77, 105),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
