import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/doctor/features/home/cubit/doctor_appointments_cubit.dart';
import 'package:grad_project/doctor/features/home/models/doctor_appointments_list_model.dart';
import 'package:grad_project/doctor/features/home/widgets/appointment_page_widgets/appointment_card.dart';
import 'package:grad_project/doctor/features/home/widgets/appointment_page_widgets/appointment_filters.dart';

class BookedAppointmentsPage extends StatefulWidget {
  const BookedAppointmentsPage({super.key});

  @override
  State<BookedAppointmentsPage> createState() => _BookedAppointmentsPageState();
}

class _BookedAppointmentsPageState extends State<BookedAppointmentsPage> {
  late final DoctorAppointmentsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DoctorAppointmentsCubit();
    Future.microtask(_cubit.loadAppointments);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<DoctorAppointmentsCubit, DoctorAppointmentsListModel>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            _cubit.clearMessages();
          }
          if (state.errorMessage != null && !state.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ),
            );
            _cubit.clearMessages();
          }
        },
        builder: (context, state) {
          final list = state.filteredAppointments;
          final filters = state.buildFilterLabels();

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                'Appointments',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              backgroundColor: Theme.of(context).cardColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Manage upcoming, pending, and completed patient appointments',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppointmentFilters(
                        selectedIndex: state.selectedFilterIndex,
                        filters: filters,
                        onSelected: _cubit.setFilterIndex,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.isLoading && state.appointments.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : state.errorMessage != null &&
                              state.appointments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _cubit.retry,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _cubit.loadAppointments,
                              child: list.isEmpty
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: const [
                                        SizedBox(height: 120),
                                        Center(
                                          child: Text(
                                            'No appointments found',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(16),
                                      itemCount: list.length,
                                      itemBuilder: (context, index) {
                                        final item = list[index];
                                        return AppointmentCard(
                                          appointment: item,
                                          isBusy: state.isUpdating,
                                          onApprove: () =>
                                              _cubit.approve(item.id),
                                          onReject: () =>
                                              _cubit.reject(item.id),
                                          onComplete: () =>
                                              _cubit.markCompleted(item.id),
                                          onDelete: () =>
                                              _cubit.deleteAppointment(item.id),
                                        );
                                      },
                                    ),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// commit update
 