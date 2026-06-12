import 'package:flutter/material.dart';
import 'package:grad_project/doctor/features/profile/widgets/profile_header.dart';
import 'package:grad_project/doctor/features/profile/widgets/profile_info_card.dart';
import 'package:grad_project/doctor/features/profile/widgets/change_password_card.dart';
import 'package:grad_project/doctor/features/profile/widgets/preferences_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import 'package:grad_project/patient/features/auth/sign_in/sign_in_page.dart';
import 'cubit/doctor_profile_cubit.dart';
import 'models/doctor_profile_model.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  late DoctorProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    // Create cubit with auth dependency
    _profileCubit = DoctorProfileCubit(context.read<AuthCubit>());
    // Initialize profile
    Future.microtask(() {
      _profileCubit.initialize();
    });
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  void _logout() async {
    await context.read<AuthCubit>().logout();
    if (!mounted) return;
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const SignInPage()));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider<DoctorProfileCubit>.value(
      value: _profileCubit,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocBuilder<DoctorProfileCubit, DoctorProfileModel>(
            builder: (context, profile) {
              // Show loading indicator while fetching profile
              if (profile.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header Title
                    Text(
                      "Profile & Settings",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Manage your account information and preferences",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Display current info from cubit
                    ProfileHeader(
                      name: _profileCubit.getDisplayName(),
                      email: _profileCubit.getDisplayEmail(),
                      phone: _profileCubit.getFormattedPhone(),
                      specialty: _profileCubit.getSpecialtyDisplay(),
                      licenseNumber: _profileCubit.getLicenseDisplay(),
                      address: _profileCubit.getAddressDisplay(),
                    ),

                    const SizedBox(height: 24),

                    /// Edit info form
                    ProfileInfoCard(
                      initialData: {
                        'name': profile.name ?? '',
                        'email': profile.email ?? '',
                        'phone': profile.phone ?? '',
                        'specialty': profile.specialty ?? '',
                        'licenseNumber': profile.licenseNumber ?? '',
                        'address': profile.address ?? '',
                      },
                      onSave: (newData) async {
                        final error = _profileCubit.getValidationError(
                          name: newData['name'] ?? '',
                          specialty: newData['specialty'] ?? '',
                          licenseNumber: newData['licenseNumber'] ?? '',
                        );

                        if (error != null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        await _profileCubit.updateProfile(
                          name: newData['name'] ?? '',
                          phone: newData['phone'] ?? '',
                          specialty: newData['specialty'] ?? '',
                          licenseNumber: newData['licenseNumber'] ?? '',
                          address: newData['address'] ?? '',
                        );

                        if (mounted) {
                          final updatedProfile = _profileCubit.state;
                          if (updatedProfile.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(updatedProfile.errorMessage!),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 24),
                    const ChangePasswordCard(),
                    const SizedBox(height: 24),
                    const PreferencesCard(),
                    const SizedBox(height: 32),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red[600],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _logout,
                        child: const Text(
                          "Log Out",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
