import 'package:flutter/material.dart';
import 'package:grad_project/doctor/features/home/models/doctor_appointment_item.dart';
import 'package:grad_project/shared/widgets/custom_button.dart';

class AppointmentCard extends StatefulWidget {
  final DoctorAppointmentItem appointment;
  final bool isBusy;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isBusy = false,
    this.onApprove,
    this.onReject,
    this.onComplete,
    this.onDelete,
  });

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool _isExpanded = false;

  Color _statusBg(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFFDCFCE7);
      case 'Completed':
        return const Color(0xFFE0E7FF);
      case 'Cancelled':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFEBF5FF);
    }
  }

  Color _statusText(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF166534);
      case 'Completed':
        return const Color(0xFF3730A3);
      case 'Cancelled':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFF0067FF);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete appointment?'),
        content: const Text(
          'This will permanently remove the appointment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      widget.onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    final isPending = a.status == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(12),
              bottom: Radius.circular(_isExpanded ? 0 : 12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    child: Text(
                      a.patientName.isNotEmpty
                          ? a.patientName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0067FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                a.patientName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              a.dateLabel,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              a.timeLabel,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                a.type,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _statusBg(a.status),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                a.status,
                                style: TextStyle(
                                  color: _statusText(a.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(height: 1, color: Colors.grey[200]),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reason',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a.reason,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.isBusy)
                    const Center(child: CircularProgressIndicator())
                  else if (isPending) ...[
                    CustomButton(
                      text: 'Approve',
                      onPressed: widget.onApprove,
                      color: const Color(0xFF0067FF),
                      height: 48,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      width: double.infinity,
                      filled: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Reject',
                            onPressed: widget.onReject,
                            color: const Color(0xFFDC2626),
                            height: 48,
                            filled: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Delete',
                            onPressed: _confirmDelete,
                            color: const Color(0xFF4B5563),
                            height: 48,
                            filled: true,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    if (a.status == 'Approved')
                      CustomButton(
                        text: 'Mark Completed',
                        onPressed: widget.onComplete,
                        color: const Color(0xFF0067FF),
                        height: 48,
                        width: double.infinity,
                        filled: true,
                      ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Delete',
                      onPressed: _confirmDelete,
                      color: const Color(0xFFDC2626),
                      height: 48,
                      width: double.infinity,
                      filled: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
