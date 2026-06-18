import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/alerts/cubit/patient_alerts_cubit.dart';
import 'package:grad_project/patient/features/alerts/models/patient_alert_item.dart';
import 'package:grad_project/patient/features/alerts/models/patient_alerts_list_model.dart';
import 'package:grad_project/patient/features/alerts/widgets/alert_card.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late final PatientAlertsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = PatientAlertsCubit();
    Future.microtask(_cubit.loadAlerts);
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
      child: BlocConsumer<PatientAlertsCubit, PatientAlertsListModel>(
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
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                'Alerts',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              backgroundColor:
                  theme.appBarTheme.backgroundColor ?? theme.cardColor,
              elevation: 0,
              centerTitle: false,
            ),
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: state.isLoading && state.alerts.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.errorMessage != null && state.alerts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(state.errorMessage!),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: _cubit.retry,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : ResponsiveLayout(
                            mobile: _buildList(context, state, 1),
                            tablet: _buildList(context, state, 2),
                            desktop: _buildList(context, state, 3),
                          ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    PatientAlertsListModel state,
    int crossAxisCount,
  ) {
    final alerts = state.activeAlerts;

    if (alerts.isEmpty && !state.isLoading) {
      return Center(
        child: Text(
          'No active alerts',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(
                  alpha: 0.5,
                ),
          ),
        ),
      );
    }

    Widget buildCard(PatientAlertItem item) {
      return AlertCard(
        title: item.title,
        message: item.message,
        dateTime: item.dateTimeLabel,
        icon: item.icon,
        iconBgColor: item.iconBgColor,
        iconColor: item.iconColor,
        onGotIt: state.isUpdating
            ? () {}
            : () => _cubit.acknowledge(item.id),
        onClose: state.isUpdating
            ? () {}
            : () => _cubit.dismiss(item.id),
      );
    }

    if (crossAxisCount == 1) {
      return RefreshIndicator(
        onRefresh: _cubit.loadAlerts,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: alerts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => buildCard(alerts[index]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cubit.loadAlerts,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.35,
        ),
        itemCount: alerts.length,
        itemBuilder: (context, index) => buildCard(alerts[index]),
      ),
    );
  }
}

// commit update
 