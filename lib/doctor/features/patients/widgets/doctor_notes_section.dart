import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import '../model/doctor_note_model.dart';

import 'doctor_notes_widgets.dart';

class DoctorNotesSection extends StatefulWidget {
  const DoctorNotesSection({super.key});

  @override
  State<DoctorNotesSection> createState() => _DoctorNotesSectionState();
}

class _DoctorNotesSectionState extends State<DoctorNotesSection> {
  late List<DoctorNote> doctorNotes;

  @override
  void initState() {
    super.initState();
    doctorNotes = [
      DoctorNote(
        id: '1',
        title: 'Initial Consultation',
        doctorName: 'Dr. Anderson',
        content:
            'Patient presented with mild hypertension. Started on Lisinopril 10mg daily. Blood pressure to be monitored weekly.',
        timestamp: DateTime(2026, 1, 28, 10, 30),
      ),
      DoctorNote(
        id: '2',
        title: 'Follow-up Visit',
        doctorName: 'Dr. Anderson',
        content:
            'Patient reports feeling better. Blood pressure readings show improvement. Continue current medication regimen.',
        timestamp: DateTime(2026, 1, 15, 14, 15),
      ),
      DoctorNote(
        id: '3',
        title: 'Lab Results Review',
        doctorName: 'Dr. Anderson',
        content:
            'Cholesterol levels within normal range. LDL: 95 mg/dL, HDL: 58 mg/dL. No changes needed to current treatment plan.',
        timestamp: DateTime(2026, 1, 5, 11, 0),
      ),
    ];
  }

  void _addNote() {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String content = '';

        return AlertDialog(
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty && content.isNotEmpty) {
                  setState(() {
                    doctorNotes.insert(
                      0,
                      DoctorNote(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        doctorName: 'Dr. Anderson',
                        content: content,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
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
  }

  void _deleteNote(String noteId) {
    setState(() {
      doctorNotes.removeWhere((note) => note.id == noteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment:.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Doctor\'s Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addNote,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.skyBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...doctorNotes.map((note) => DoctorNoteCard(
                note: note,
                onDelete: () => _deleteNote(note.id),
              )),
        ],
      ),
    );
  }
}
