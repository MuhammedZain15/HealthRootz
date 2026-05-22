import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/doctor_patients_cubit.dart';
import '../models/doctor_patients_list_model.dart';
import '../patient_details_page.dart';
import 'patient_card.dart';

class PatientList extends StatefulWidget {
  const PatientList({super.key});

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorPatientsCubit, DoctorPatientsListModel>(
      builder: (context, state) {
        final cubit = context.read<DoctorPatientsCubit>();
        final list = state.filteredPatients;
        final textTheme = Theme.of(context).textTheme;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final horizontalPadding = isWide ? 24.0 : 12.0;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patients List',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'View and manage all patient records',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: TextStyle(color: Colors.red.shade800),
                              ),
                            ),
                            TextButton(
                              onPressed: cubit.retry,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: cubit.setSearchQuery,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: Colors.white,
                        value: state.statusFilter,
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text('All Status'),
                          ),
                          DropdownMenuItem(
                            value: 'Normal',
                            child: Text('Normal'),
                          ),
                          DropdownMenuItem(
                            value: 'Warning',
                            child: Text('Warning'),
                          ),
                          DropdownMenuItem(
                            value: 'Critical',
                            child: Text('Critical'),
                          ),
                        ],
                        onChanged: (v) => cubit.setStatusFilter(v ?? 'All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: state.isLoading && state.patients.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: cubit.loadPatients,
                            child: list.isEmpty
                                ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(
                                        height:
                                            constraints.maxHeight > 200
                                                ? constraints.maxHeight * 0.4
                                                : 120,
                                        child: Center(
                                          child: Text(
                                            state.isLoading
                                                ? 'Loading patients...'
                                                : 'No patients found',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: list.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final patient = list[index];
                                      return PatientCard(
                                        patient: patient,
                                        onViewDetails: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PatientDetailsPage(
                                                patientId: patient.id,
                                                preview: patient,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
