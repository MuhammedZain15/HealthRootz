import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/patient/data/models/patient_model.dart';
import 'package:grad_project/patient/features/patient/utils/patient_auth_redirect.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import 'package:intl/intl.dart';

class DoctorNotesScreen extends StatefulWidget {
  const DoctorNotesScreen({super.key});

  @override
  State<DoctorNotesScreen> createState() => _DoctorNotesScreenState();
}

class _DoctorNotesScreenState extends State<DoctorNotesScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<PatientCubit>();
    if (cubit.state is! PatientLoaded) {
      cubit.fetchMe();
    }
  }

  String _formatTimestamp(DateTime? createdAt) {
    if (createdAt == null) return '';
    return DateFormat('MMM d, yyyy • h:mm a').format(createdAt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientCubit, PatientState>(
      listener: (context, state) {
        PatientAuthRedirect.handlePatientError(context, state);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: BlocBuilder<PatientCubit, PatientState>(
            builder: (context, state) {
              if (state is PatientLoading || state is PatientInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is PatientError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.read<PatientCubit>().fetchMe(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final notes = state is PatientLoaded
                  ? (List<PatientNoteModel>.from(state.patient.notes)
                    ..sort((a, b) {
                      final da = a.createdAt;
                      final db = b.createdAt;
                      if (da == null && db == null) return 0;
                      if (da == null) return 1;
                      if (db == null) return -1;
                      return db.compareTo(da);
                    }))
                  : <PatientNoteModel>[];

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.skyBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Doctor Notes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              '${notes.length} medical notes',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: notes.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return _buildNoteCard(note);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No notes from your doctor yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(PatientNoteModel note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1E293B),
              height: 1.5,
            ),
          ),
          if (note.createdAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTimestamp(note.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
