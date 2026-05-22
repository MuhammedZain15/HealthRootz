import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import 'package:grad_project/patient/features/auth/sign_in/sign_in_page.dart';
import 'package:grad_project/patient/features/profile/cubit/patient_profile_cubit.dart';
import 'package:grad_project/patient/features/profile/edit_profile_card.dart';
import 'package:grad_project/patient/features/profile/models/patient_profile_model.dart';
import 'package:grad_project/patient/features/profile/widgets/patient_profile_body.dart';

/// Patient profile screen (MVVM via [PatientProfileCubit]).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final PatientProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = PatientProfileCubit(context.read<AuthCubit>());
    Future.microtask(_profileCubit.initialize);
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthCubit>().logout();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignInPage()),
    );
  }

  void _showEditDialog(PatientProfileModel profile) {
    EditProfileCard.show(
      context,
      initialName: profile.name ?? '',
      initialAge: profile.age?.toString() ?? '',
      initialMedical: profile.medicalHistory ?? '',
      onSave: (newName, newAge, newMedical) async {
        final ok = await _profileCubit.updateBasicInfo(
          name: newName,
          age: int.tryParse(newAge) ?? profile.age ?? 0,
          medicalHistory: newMedical,
        );
        if (!mounted) return;
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (_profileCubit.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_profileCubit.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
      child: BlocConsumer<PatientProfileCubit, PatientProfileModel>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            _profileCubit.clearSuccess();
          }
        },
        builder: (context, profile) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F8FF),
            body: SafeArea(
              child: profile.isLoading && profile.name == null
                  ? const Center(child: CircularProgressIndicator())
                  : profile.errorMessage != null && profile.name == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(profile.errorMessage!),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _profileCubit.retry,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : PatientProfileBody(
                          profile: profile,
                          onLogout: _logout,
                          onEdit: () => _showEditDialog(profile),
                        ),
            ),
          );
        },
      ),
    );
  }
}
