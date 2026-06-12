import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/doctor/features/patients/patient_details_page.dart';
import '../models/chat_model.dart';
import '../view_models/chat_detail_view_model.dart';
import '../widgets/chat_widgets.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatUser user;
  final String patientId;
  const ChatDetailPage({
    super.key,
    required this.user,
    required this.patientId,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage>
    with WidgetsBindingObserver {
  final _vm = ChatDetailViewModel();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _vm.addListener(_onViewModelChanged);
    _vm.loadMessages(widget.patientId);
    _scrollToBottom();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vm.removeListener(_onViewModelChanged);
    _vm.close();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _scrollToBottom();
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _openPatientProfile() {
    final recordId = widget.user.patientRecordId;
    if (recordId.isEmpty) {
      _showSnackBar('Patient profile not available.');
      return;
    }
    final patientCubit = context.read<PatientCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => BlocProvider.value(
          value: patientCubit,
          child: PatientDetailsPage(patientId: recordId),
        ),
      ),
    );
  }

  Future<void> _callPatient() async {
    final phone = widget.user.phone?.trim();
    if (phone == null || phone.isEmpty) {
      _showSnackBar('No phone number found for this patient.');
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    _showSnackBar('Could not open phone dialer.');
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Color(0xFF1A65EB)),
                title: const Text('Image'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.video_library,
                  color: Color(0xFF1A65EB),
                ),
                title: const Text('Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Color(0xFF1A65EB),
                ),
                title: const Text('PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPdf();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    await _sendPickedFile(
      filePath: file.path,
      fileName: file.name,
      fileType: 'image',
    );
  }

  Future<void> _pickVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    await _sendPickedFile(
      filePath: file.path,
      fileName: file.name,
      fileType: 'video',
    );
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    final file = result?.files.single;
    final path = file?.path;
    if (file == null || path == null) return;
    await _sendPickedFile(filePath: path, fileName: file.name, fileType: 'pdf');
  }

  Future<void> _sendPickedFile({
    required String filePath,
    required String fileName,
    required String fileType,
  }) async {
    await _vm.sendMediaMessage(
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A65EB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: _openPatientProfile,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF1A65EB),
                child: Text(
                  widget.user.name.substring(0, 2).toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'Tap to view profile',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Call patient',
            icon: const Icon(Icons.phone, color: Color(0xFF1A65EB)),
            onPressed: _callPatient,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 16),
              itemCount: _vm.messages.length,
              itemBuilder: (ctx, i) {
                final message = _vm.messages[i];
                return MessageBubble(
                  message: message,
                  onDelete: message.id.isEmpty
                      ? null
                      : () => _vm.deleteMessage(message.id),
                  onForward: (patientId) =>
                      _vm.forwardMessage(message, patientId),
                  onGetPatients: _vm.getPatientsList,
                );
              },
            ),
          ),
          ChatInputArea(
            controller: _controller,
            onAttach: _showAttachmentSheet,
            onSend: () {
              _vm.sendMessage(_controller.text);
              _controller.clear();
            },
          ),
        ],
      ),
    );
  }
}
