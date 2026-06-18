import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'doctor_chat_session.dart';
import 'models/chat_model.dart';
import 'view_models/chat_list_view_model.dart';
import 'views/chat_detail_page.dart';
import 'widgets/chat_widgets.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';

class DoctorChatPage extends StatefulWidget {
  const DoctorChatPage({super.key});

  @override
  State<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  final _vm = ChatListViewModel();

  @override
  void dispose() {
    _vm.close();
    super.dispose();
  }

  void _openChat(BuildContext context, ChatUser user) {
    DoctorChatSession.activePatientId = user.id;
    final patientCubit = context.read<PatientCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: patientCubit,
          child: ChatDetailPage(user: user, patientId: user.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildChatList(context),
          tablet: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _buildChatList(context),
            ),
          ),
          desktop: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _buildChatList(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Chat',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: ChatSearchField(),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListenableBuilder(
            listenable: _vm,
            builder: (context, _) => ListView.separated(
              itemCount: _vm.chats.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (ctx, i) => ChatListTile(
                user: _vm.chats[i],
                onTap: () => _openChat(context, _vm.chats[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// commit update
 