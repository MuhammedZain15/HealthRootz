// lib/doctor/features/chat/view_models/chat_detail_view_model.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:grad_project/core/network/token_storage.dart';
import 'package:grad_project/doctor/features/chat/data/datasources/chat_firestore_data_source.dart';
import 'package:grad_project/doctor/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:grad_project/doctor/features/chat/domain/usecases/delete_message_usecase.dart';
import 'package:grad_project/doctor/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:grad_project/doctor/features/chat/domain/usecases/mark_as_read_usecase.dart';
import 'package:grad_project/doctor/features/chat/doctor_chat_session.dart';
import 'package:grad_project/doctor/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:grad_project/doctor/features/chat/domain/usecases/send_media_message_usecase.dart';
import 'package:grad_project/doctor/features/chat/models/chat_model.dart';
import 'package:grad_project/patient/features/patient/data/repositories/patient_repository_impl.dart';
import 'package:intl/intl.dart';

abstract class ChatDetailState {
  const ChatDetailState();
}

class ChatDetailInitial extends ChatDetailState {
  const ChatDetailInitial();
}

class ChatDetailLoading extends ChatDetailState {
  const ChatDetailLoading();
}

class ChatDetailLoaded extends ChatDetailState {
  final List<ChatMessage> messages;
  const ChatDetailLoaded(this.messages);
}

class ChatDetailSending extends ChatDetailState {
  const ChatDetailSending();
}

class ChatDetailError extends ChatDetailState {
  final String message;
  const ChatDetailError(this.message);
}

class ChatDetailCubit extends Cubit<ChatDetailState> implements Listenable {
  ChatDetailCubit({
    GetMessagesUseCase? getMessagesUseCase,
    SendMessageUseCase? sendMessageUseCase,
    SendMediaMessageUseCase? sendMediaMessageUseCase,
    MarkAsReadUseCase? markAsReadUseCase,
    DeleteMessageUseCase? deleteMessageUseCase,
  }) : _getMessagesUseCase =
           getMessagesUseCase ??
           GetMessagesUseCase(
             ChatRepositoryImpl(ChatFirestoreDataSourceImpl()),
           ),
       _sendMessageUseCase =
           sendMessageUseCase ??
           SendMessageUseCase(
             ChatRepositoryImpl(ChatFirestoreDataSourceImpl()),
           ),
       _sendMediaMessageUseCase =
           sendMediaMessageUseCase ??
           SendMediaMessageUseCase(
             ChatRepositoryImpl(ChatFirestoreDataSourceImpl()),
           ),
       _markAsReadUseCase =
           markAsReadUseCase ??
           MarkAsReadUseCase(ChatRepositoryImpl(ChatFirestoreDataSourceImpl())),
       _deleteMessageUseCase =
           deleteMessageUseCase ??
           DeleteMessageUseCase(
             ChatRepositoryImpl(ChatFirestoreDataSourceImpl()),
           ),
       super(const ChatDetailInitial()) {
    _sub = stream.listen(_onStateChanged);
  }

  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final SendMediaMessageUseCase _sendMediaMessageUseCase;
  final MarkAsReadUseCase _markAsReadUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();
  late final StreamSubscription<ChatDetailState> _sub;
  StreamSubscription<dynamic>? _messagesSub;

  String? _patientId;
  String? _doctorId;
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => _messages;

  void _safeEmit(ChatDetailState state) {
    if (isClosed) return;
    emit(state);
  }

  Future<void> loadMessages(String patientId) async {
    _patientId = patientId;
    final doctorId = await TokenStorage.getUserId();
    if (isClosed) return;
    if (doctorId == null || doctorId.isEmpty) {
      _safeEmit(const ChatDetailError('Doctor id is missing.'));
      return;
    }
    _doctorId = doctorId;

    await _messagesSub?.cancel();
    if (isClosed) return;
    _safeEmit(const ChatDetailLoading());

    _messagesSub = _getMessagesUseCase(doctorId: doctorId, patientId: patientId)
        .listen((result) {
          if (isClosed) return;
          result.fold((failure) => _safeEmit(ChatDetailError(failure.message)), (
            messages,
          ) {
            if (isClosed) return;
            _messages
              ..clear()
              ..addAll(messages);
            _emitLoaded();
            unawaited(_markIncomingMessagesAsRead(messages));
          });
        });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final patientId = _patientId ?? DoctorChatSession.activePatientId;
    final doctorId = _doctorId ?? await TokenStorage.getUserId();
    if (isClosed) return;
    if (patientId == null ||
        patientId.isEmpty ||
        doctorId == null ||
        doctorId.isEmpty) {
      _safeEmit(const ChatDetailError('Chat participants are missing.'));
      return;
    }
    _patientId = patientId;
    _doctorId = doctorId;

    final optimisticMessage = ChatMessage(
      id: '',
      text: text,
      isMe: true,
      time: DateFormat.jm().format(DateTime.now()),
      patientId: patientId,
    );
    _messages.add(optimisticMessage);
    _emitLoaded();

    _safeEmit(const ChatDetailSending());
    final result = await _sendMessageUseCase(
      doctorId: doctorId,
      patientId: patientId,
      senderId: doctorId,
      text: text,
    );
    if (isClosed) return;
    result.fold(
      (failure) {
        _messages.remove(optimisticMessage);
        _safeEmit(ChatDetailError(failure.message));
        _emitLoaded();
      },
      (sentMessage) {
        _messages.remove(optimisticMessage);
        if (!_messages.any((message) => message.id == sentMessage.id)) {
          _messages.add(sentMessage);
        }
        _emitLoaded();
      },
    );
  }

  Future<void> sendMediaMessage({
    required String filePath,
    required String fileName,
    required String fileType,
  }) async {
    final patientId = _patientId ?? DoctorChatSession.activePatientId;
    final doctorId = _doctorId ?? await TokenStorage.getUserId();
    if (isClosed) return;
    if (patientId == null ||
        patientId.isEmpty ||
        doctorId == null ||
        doctorId.isEmpty) {
      _safeEmit(const ChatDetailError('Chat participants are missing.'));
      return;
    }
    _patientId = patientId;
    _doctorId = doctorId;

    _safeEmit(const ChatDetailSending());
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('chats')
          .child(doctorId)
          .child(patientId)
          .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');
      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask;
      if (isClosed) return;
      final fileUrl = await snapshot.ref.getDownloadURL();

      final result = await _sendMediaMessageUseCase(
        doctorId: doctorId,
        patientId: patientId,
        senderId: doctorId,
        fileUrl: fileUrl,
        fileType: fileType,
        fileName: fileName,
      );
      if (isClosed) return;
      result.fold(
        (failure) => _safeEmit(ChatDetailError(failure.message)),
        (_) {},
      );
    } catch (e) {
      _safeEmit(ChatDetailError('Failed to send media: $e'));
    }
  }

  Future<List<Map<String, dynamic>>> getPatientsList() async {
    final repository = PatientRepositoryImpl();
    final result = await repository.getPatients();
    return result.fold((_) => <Map<String, dynamic>>[], (patients) {
      return patients
          .map(
            (patient) => <String, dynamic>{
              'id': patient.chatUserId,
              'name': patient.name,
            },
          )
          .toList();
    });
  }

  Future<void> forwardMessage(
    ChatMessage message,
    String targetPatientId,
  ) async {
    final doctorId = _doctorId ?? await TokenStorage.getUserId();
    if (doctorId == null || doctorId.isEmpty) return;

    if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty) {
      await _sendMediaMessageUseCase(
        doctorId: doctorId,
        patientId: targetPatientId,
        senderId: doctorId,
        fileUrl: message.mediaUrl!,
        fileType: message.mediaType ?? '',
        fileName: message.fileName ?? '',
      );
    } else {
      await _sendMessageUseCase(
        doctorId: doctorId,
        patientId: targetPatientId,
        senderId: doctorId,
        text: message.text,
      );
    }
  }

  void _onStateChanged(ChatDetailState state) {
    if (state is ChatDetailLoaded) {
      _messages
        ..clear()
        ..addAll(state.messages);
    }
    _notifyListeners();
  }

  void _emitLoaded() {
    _safeEmit(ChatDetailLoaded(List<ChatMessage>.unmodifiable(_messages)));
  }

  Future<void> _markIncomingMessagesAsRead(List<ChatMessage> messages) async {
    for (final message in messages) {
      if (message.id.isEmpty) continue;
      if (message.isMe || message.isRead) continue;
      await markAsRead(message.id);
    }
  }

  Future<void> markAsRead(String messageId) async {
    final patientId = _patientId;
    final doctorId = _doctorId ?? await TokenStorage.getUserId();
    if (patientId == null || doctorId == null) return;

    final result = await _markAsReadUseCase(
      doctorId: doctorId,
      patientId: patientId,
      messageId: messageId,
    );
    if (isClosed) return;
    result.fold(
      (failure) => _safeEmit(ChatDetailError(failure.message)),
      (_) {},
    );
  }

  Future<void> deleteMessage(String messageId) async {
    final patientId = _patientId;
    final doctorId = _doctorId ?? await TokenStorage.getUserId();
    if (patientId == null || doctorId == null) return;

    final result = await _deleteMessageUseCase(
      doctorId: doctorId,
      patientId: patientId,
      messageId: messageId,
    );
    if (isClosed) return;
    result.fold(
      (failure) => _safeEmit(ChatDetailError(failure.message)),
      (_) {},
    );
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }

  @override
  Future<void> close() async {
    await _messagesSub?.cancel();
    _messagesSub = null;
    await _sub.cancel();
    return super.close();
  }
}

class ChatDetailViewModel extends ChatDetailCubit {
  ChatDetailViewModel() : super();
}
