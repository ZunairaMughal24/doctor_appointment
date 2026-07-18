import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/doctor_form_options.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_loader.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/profile_widgets.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/modern_bottom_sheet.dart';
import '../../../../core/services/image_picker_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../features/doctors/presentation/pages/doctor_reviews_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ProfileViewModel(
      onChange: () {
        if (mounted) setState(() {});
      },
      authBloc: context.read<AuthBloc>(),
    );
    _vm.init();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.signIn);
        } else if (state is AuthFailureState) {
          AppFeedback.showError(context, state.message);
        } else if (state is AuthAuthenticated) {
          _vm.onAuthenticated(state.user);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (_vm.cachedUser == null) {
            return const Scaffold(
              backgroundColor: AppColors.cardBg,
              body: AppLoader(),
            );
          }
          final user = _vm.cachedUser!;
          final photoUrl =
              user.isDoctor ? _vm.doctorEntity?.imageUrl : user.imageUrl;
          final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
          return Scaffold(
            backgroundColor: AppColors.cardBg,
            appBar: CustomAppBar(
              title: 'Profile',
              forceShowBack: true,
              onBackPressed: () => context.go(AppRoutes.home),
              actions: [
                if (!_vm.editing)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => setState(() => _vm.editing = true),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => _vm.cancelEditing(user),
                  ),
              ],
            ),
            body: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    // ── Avatar ──────────────────────────────────────
                    Center(
                      child: Stack(
                        children: [
                          // ── Circle avatar ──────────────────────────
                          SizedBox(
                            width: 88,
                            height: 88,
                            child: ClipOval(
                              child: Stack(
                                children: [
                                  // Background colour
                                  Container(
                                    color: AppColors.primary,
                                    width: 88,
                                    height: 88,
                                  ),

                                  if (hasPhoto)
                                    Positioned.fill(
                                      child: CachedNetworkImage(
                                        imageUrl: photoUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            Container(color: AppColors.primary),
                                            Positioned(
                                              bottom: -6,
                                              left: 0,
                                              right: 0,
                                              child: Icon(
                                                Icons.person,
                                                size: 74,
                                                color: Colors.white
                                                    .withValues(alpha: 0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  // Person silhouette: head+shoulders fill the
                                  // circle; legs are clipped below the edge.
                                  if (!hasPhoto && !_vm.uploadingImage)
                                    Positioned(
                                      bottom: -14,
                                      left: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.person,
                                        size: 74,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  // Upload progress overlay
                                  if (_vm.uploadingImage)
                                    const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.white),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // ── Camera edit button ──────────────────────
                          if (_vm.editing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () async {
                                  if (hasPhoto) {
                                    final action =
                                        await showModalBottomSheet<String>(
                                      context: context,
                                      isScrollControlled: true,
                                      useRootNavigator: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) => ModernBottomSheet(
                                        title: 'Profile Photo',
                                        subtitle: 'Manage your profile picture',
                                        icon: Icons.face_rounded,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(
                                                  Icons.photo_library_rounded,
                                                  color: AppColors.primary),
                                              title: Text('Change Photo',
                                                  style: AppTextStyles.label
                                                      .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColors.primary)),
                                              onTap: () =>
                                                  Navigator.pop(ctx, 'change'),
                                            ),
                                            const Divider(
                                                height: 1,
                                                color: AppColors.divider),
                                            ListTile(
                                              leading: const Icon(
                                                  Icons.delete_rounded,
                                                  color: AppColors.error),
                                              title: Text('Remove Photo',
                                                  style: AppTextStyles.label
                                                      .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.error)),
                                              onTap: () =>
                                                  Navigator.pop(ctx, 'remove'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );

                                    if (action == 'change' && context.mounted) {
                                      final file = await ImagePickerService
                                          .pickWithChooser(context);
                                      if (file != null && context.mounted) {
                                        final result =
                                            await _vm.uploadImage(file);
                                        if (context.mounted) {
                                          if (result.ok) {
                                            AppFeedback.showSuccess(
                                                context, result.message);
                                          } else {
                                            AppFeedback.showError(
                                                context, result.message);
                                          }
                                        }
                                      }
                                    } else if (action == 'remove' &&
                                        context.mounted) {
                                      final result =
                                          await _vm.removeProfilePhoto();
                                      if (context.mounted) {
                                        if (result.ok) {
                                          AppFeedback.showSuccess(
                                              context, result.message);
                                        } else {
                                          AppFeedback.showError(
                                              context, result.message);
                                        }
                                      }
                                    }
                                  } else {
                                    final file = await ImagePickerService
                                        .pickWithChooser(context);
                                    if (file != null && context.mounted) {
                                      final result =
                                          await _vm.uploadImage(file);
                                      if (context.mounted) {
                                        if (result.ok) {
                                          AppFeedback.showSuccess(
                                              context, result.message);
                                        } else {
                                          AppFeedback.showError(
                                              context, result.message);
                                        }
                                      }
                                    }
                                  }
                                },
                                child: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary,
                                  child: Icon(Icons.camera_alt,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.isDoctor
                              ? AppColors.primary
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.isDoctor ? 'Doctor Mode' : 'Patient Mode',
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.bold,
                            color: user.isDoctor
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Personal / Professional Info ─────────────────
                    _sectionHeader('Personal Information'),
                    const SizedBox(height: 12),
                    Form(
                      key: _vm.formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          ProfileLabeledField(
                            label: 'Full Name',
                            controller: _vm.nameController,
                            icon: Icons.person_rounded,
                            enabled: _vm.editing,
                            maxLength: 40,
                            validator: _vm.nameValidator,
                          ),
                          ProfileLabeledField(
                            label: 'Email',
                            controller: _vm.emailController,
                            icon: Icons.email_rounded,
                            enabled: _vm.editing,
                            keyboardType: TextInputType.emailAddress,
                            maxLength: 60,
                            validator: _vm.emailValidator,
                          ),
                          if (user.isDoctor) ...[
                            const SizedBox(height: 16),
                            _sectionHeader('Professional Details'),
                            const SizedBox(height: 12),
                            ProfileLabeledField(
                              label: 'Speciality',
                              controller: _vm.specialityController,
                              icon: Icons.medical_services_rounded,
                              enabled: _vm.editing,
                              options: DoctorFormOptions.specialities,
                              validator: _vm.specialityValidator,
                            ),
                            ProfileLabeledField(
                              label: 'Experience',
                              controller: _vm.experienceController,
                              icon: Icons.workspace_premium_rounded,
                              enabled: _vm.editing,
                              options: DoctorFormOptions.experienceYears,
                              validator: _vm.experienceValidator,
                            ),
                            ProfileLabeledField(
                              label: 'Phone Number',
                              controller: _vm.phoneController,
                              icon: Icons.phone_rounded,
                              enabled: _vm.editing,
                              keyboardType: TextInputType.phone,
                              validator: _vm.phoneValidator,
                            ),
                            ProfileLabeledField(
                              label: 'Clinic / Hospital Location',
                              controller: _vm.locationController,
                              icon: Icons.location_on_rounded,
                              enabled: _vm.editing,
                              options: DoctorFormOptions.locations,
                              validator: _vm.locationValidator,
                            ),
                            ProfileAvailabilitySection(
                              schedule: _vm.weeklySchedule,
                              enabled: _vm.editing,
                              onChanged: _vm.updateSchedule,
                            ),
                            ProfileLabeledField(
                              label: 'Services',
                              controller: _vm.servicesController,
                              icon: Icons.list_alt_rounded,
                              enabled: _vm.editing,
                              options: DoctorFormOptions.services,
                              validator: _vm.servicesValidator,
                            ),
                            ProfileLabeledField(
                              label: 'About / Description',
                              controller: _vm.descriptionController,
                              icon: Icons.info_rounded,
                              enabled: _vm.editing,
                              maxLines: 4,
                              maxLength: 300,
                              validator: _vm.descriptionValidator,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_vm.editing) ...[
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Save Changes',
                        icon: Icons.check_rounded,
                        loading: state is AuthLoading,
                        onPressed: () => _vm.saveProfile(user),
                      ),
                    ],

                    if (user.isDoctor && !_vm.editing) ...[
                      const SizedBox(height: 28),
                      _sectionHeader('Ratings & Reviews'),
                      const SizedBox(height: 10),
                      _card(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                            ),
                          ),
                          title: Text(
                            'My Reviews',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          subtitle: Text(
                            _vm.reviewsLoading
                                ? 'Loading ratings...'
                                : _vm.reviews.isEmpty
                                    ? 'No reviews yet'
                                    : '${(_vm.doctorEntity?.rating ?? 0.0).toStringAsFixed(1)} ★ (${_vm.reviews.length} reviews)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          onTap: _vm.reviewsLoading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DoctorReviewsPage(
                                        doctorName: user.name,
                                        reviews: _vm.reviews,
                                        rating: _vm.doctorEntity?.rating ?? 0.0,
                                      ),
                                    ),
                                  );
                                },
                        ),
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
                                  ? Icons.medical_services_rounded
                                  : Icons.person_rounded,
                              color: AppColors.primary,
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
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    user.isDoctor
                                        ? 'Browse doctors & book appointments'
                                        : 'Manage your patient appointments',
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Transform.scale(
                              scale:
                                  0.8, // Adjust this value (e.g., 0.7 to 0.9) to change the size
                              child: Switch(
                                value: user.isDoctor,
                                activeColor: AppColors.primary,
                                activeTrackColor:
                                    AppColors.primary.withOpacity(0.5),
                                inactiveThumbColor: AppColors.primary,
                                inactiveTrackColor:
                                    AppColors.primary.withOpacity(0.2),
                                onChanged: (_) => _vm.switchRole(user),
                              ),
                            )
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
                            backgroundColor: AppColors.primaryLight,
                            child: Icon(
                              Icons.medical_services_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            'Register as Doctor',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          subtitle: Text(
                            'Add a professional profile to manage patient appointments',
                            style: AppTextStyles.bodySmall,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          onTap: () => context.push(
                            AppRoutes.registerAsDoctor,
                            extra: {
                              'name': user.name,
                              'email': user.email,
                              'uid': user.uid,
                            },
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
                          backgroundColor: AppColors.dangerLight,
                          child: Icon(Icons.logout, color: AppColors.error),
                        ),
                        title: Text(
                          'Sign Out',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        onTap: () async {
                          final confirmed = await AppFeedback.showConfirmation(
                            context,
                            title: 'Sign Out',
                            message: 'Are you sure you want to sign out?',
                            confirmLabel: 'Sign Out',
                            isDanger: true,
                          );
                          if (!confirmed || !context.mounted) return;
                          final error = await _vm.signOut();
                          if (error != null && context.mounted) {
                            AppFeedback.showError(context, error);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Delete Account ───────────────────────────────
                    _card(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.dangerLight,
                          child: Icon(Icons.delete_forever_rounded,
                              color: AppColors.error),
                        ),
                        title: Text(
                          'Delete Account',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        subtitle: Text(
                          'Permanently remove your account and all data',
                          style: AppTextStyles.bodySmall,
                        ),
                        onTap: () async {
                          if (user.isDoctor) {
                            final removeProfile =
                                await AppFeedback.showConfirmation(
                              context,
                              title: 'Remove Doctor Profile',
                              message:
                                  'This will permanently delete your doctor profile and remove you from the doctors list.',
                              confirmLabel: 'Remove Profile',
                              isDanger: true,
                            );
                            if (!removeProfile || !context.mounted) return;
                            _vm.dispatchDeleteDoctorProfile();

                            final deleteAccount =
                                await AppFeedback.showConfirmation(
                              context,
                              title: 'Delete Account',
                              message:
                                  'Do you also want to permanently delete your account? This cannot be undone.',
                              confirmLabel: 'Delete Account',
                              isDanger: true,
                            );
                            if (!deleteAccount || !context.mounted) return;
                            _vm.dispatchDeleteAccount();
                          } else {
                            final confirmed =
                                await AppFeedback.showConfirmation(
                              context,
                              title: 'Delete Account',
                              message:
                                  'Are you sure? This will permanently delete your account and all data. This cannot be undone.',
                              confirmLabel: 'Delete Account',
                              isDanger: true,
                            );
                            if (!confirmed || !context.mounted) return;
                            _vm.dispatchDeleteAccount();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                if (state is AuthLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.35),
                      child: const Center(child: AppLoader()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
        title,
        style: AppTextStyles.label.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      );

  Widget _card({required Widget child}) => AppContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 14,
        child: child,
      );
}
