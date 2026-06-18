// dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';

import 'package:grad_project/shared/widgets/custom_button.dart';


class EditProfileCard extends StatefulWidget {
  final String initialName;
  final String initialAge;
  final String initialMedical;
  final void Function(String name, String age, String medical) onSave;

  const EditProfileCard({
    super.key,
    required this.initialName,
    required this.initialAge,
    required this.initialMedical,
    required this.onSave,
  });

  /// Helper to display the dialog easily:
  static Future<void> show(
    BuildContext context, {
    required String initialName,
    required String initialAge,
    required String initialMedical,
    required void Function(String name, String age, String medical) onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: EditProfileCard(
          initialName: initialName,
          initialAge: initialAge,
          initialMedical: initialMedical,
          onSave: onSave,
        ),
      ),
    );
  }

  @override
  State<EditProfileCard> createState() => _EditProfileCardState();
}

class _EditProfileCardState extends State<EditProfileCard> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _medicalCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _ageCtrl = TextEditingController(text: widget.initialAge);
    _medicalCtrl = TextEditingController(text: widget.initialMedical);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _medicalCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    widget.onSave(
      _nameCtrl.text.trim(),
      _ageCtrl.text.trim(),
      _medicalCtrl.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  InputDecoration _outlineDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;

    // Responsive width and max height
    final dialogWidth = min(520.0, screenW * 0.92);
    final dialogMaxHeight = min(640.0, screenH * 0.88);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: SafeArea(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: const [
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.close, color: Colors.grey.shade600),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Update your personal information',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Form area: scrollable when needed
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: _outlineDecoration(
                                label: 'Full Name',
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter full name'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _ageCtrl,
                              decoration: _outlineDecoration(label: 'Age'),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter age';
                                }
                                if (int.tryParse(v.trim()) == null) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _medicalCtrl,
                              decoration: _outlineDecoration(
                                label: 'Medical Details',
                              ),
                              keyboardType: TextInputType.multiline,
                              minLines: 3,
                              maxLines: 6,
                            ),
                            const SizedBox(height: 18),
                            // Save button
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: CustomButton(
                                color: AppColors.skyBlue,
                                text: _saving ? "Saving..." : "Save Changes",
                                onPressed: () {
                                  if (!_saving) _onSave();
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// commit update
 