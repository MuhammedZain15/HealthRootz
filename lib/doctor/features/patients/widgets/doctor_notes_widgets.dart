import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import 'package:grad_project/patient/features/patient/data/models/patient_model.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/app_colors.dart';
import '../model/doctor_note_model.dart';

// Doctor Note Card
class DoctorNoteCard extends StatelessWidget {
  final DoctorNote note;
  final VoidCallback? onDelete;

  const DoctorNoteCard({super.key, required this.note, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, size: 18, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(note.doctorName, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Text(
            note.content,
            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM d, yyyy \'at\' h:mm a').format(note.timestamp),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<DoctorNote> doctorNotesFromPatient(
  List<PatientNoteModel> notes, {
  required String fallbackDoctorName,
}) {
  return notes.map((note) {
    final colonIndex = note.text.indexOf(': ');
    final title =
        colonIndex > 0 ? note.text.substring(0, colonIndex) : 'Note';
    final content = colonIndex > 0
        ? note.text.substring(colonIndex + 2)
        : note.text;

    return DoctorNote(
      id: note.id.isNotEmpty
          ? note.id
          : note.text.hashCode.toString(),
      title: title,
      doctorName: note.doctorName ?? fallbackDoctorName,
      content: content,
      timestamp: note.createdAt ?? DateTime.now(),
    );
  }).toList();
}

// Doctor Notes Section
class DoctorNotesSection extends StatefulWidget {
  final String patientId;
  const DoctorNotesSection({super.key, required this.patientId});

  @override
  State<DoctorNotesSection> createState() => _DoctorNotesSectionState();
}

class _DoctorNotesSectionState extends State<DoctorNotesSection> {
  final Set<String> _deletedNoteIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotes());
  }

  void _loadNotes() {
    final cubit = context.read<PatientCubit>();
    final state = cubit.state;
    if (state is! PatientLoaded || state.patient.id != widget.patientId) {
      cubit.fetchPatientById(widget.patientId);
    }
  }

  void _addNote() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String title = '';
        String content = '';
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Add Note'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => title = value,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Note Content',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    onChanged: (value) => content = value,
                  ),
                  if (isSubmitting) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (title.isEmpty || content.isEmpty) return;

                          setDialogState(() => isSubmitting = true);

                          final cubit = this.context.read<PatientCubit>();
                          await cubit.addDoctorNote(
                            widget.patientId,
                            '$title: $content',
                          );

                          if (!mounted) return;

                          if (cubit.state is PatientError) {
                            final message =
                                (cubit.state as PatientError).message;
                            if (dialogContext.mounted) {
                              setDialogState(() => isSubmitting = false);
                            }
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                            return;
                          }

                          await cubit.fetchPatientById(widget.patientId);

                          if (!mounted) return;

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }

                          final successMessage = cubit.state is PatientActionSuccess
                              ? (cubit.state as PatientActionSuccess).message
                              : 'Note added successfully';
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text(successMessage)),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteNote(String noteId) {
    setState(() {
      _deletedNoteIds.add(noteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fallbackDoctorName =
        context.read<AuthCubit>().state.user?.name ?? 'Doctor';

    return BlocBuilder<PatientCubit, PatientState>(
      buildWhen: (previous, current) {
        if (current is PatientLoaded) {
          return current.patient.id == widget.patientId;
        }
        return current is PatientError || current is PatientActionSuccess;
      },
      builder: (context, state) {
        final notes = state is PatientLoaded &&
                state.patient.id == widget.patientId
            ? doctorNotesFromPatient(
                state.patient.notes,
                fallbackDoctorName: fallbackDoctorName,
              ).where((n) => !_deletedNoteIds.contains(n.id))
            : const <DoctorNote>[];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Doctor\'s Notes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addNote,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.skyBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...notes.map((note) => DoctorNoteCard(
                    note: note,
                    onDelete: () => _deleteNote(note.id),
                  )),
            ],
          ),
        );
      },
    );
  }
}
