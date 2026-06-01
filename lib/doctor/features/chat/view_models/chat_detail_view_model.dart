// lib/doctor/features/chat/view_models/chat_detail_view_model.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/network/token_storage.dart';
import 'package:grad_project/doctor/features/chat/data/datasources/chat_firestore_data_source.dart';
import 'package:grad_project/doctor/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:grad_project/doctor/features/chat/domain/usecases/delete_message_usecase.dart';
import 'package:grad_project/doctor/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:grad_project/doctor/features/chat/domain/usecases/mark_as_read_usecase.dart';
import 'package:grad_project/doctor/features/chat/doctor_chat_session.dart';
import 'package:grad_project/doctor/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:grad_project/doctor/features/chat/models/chat_model.dart';

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
    final patientId = DoctorChatSession.activePatientId;
    if (patientId != null && patientId.isNotEmpty) {
      unawaited(loadMessages(patientId));
    }
  }

  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final MarkAsReadUseCase _markAsReadUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();
  late final StreamSubscription<ChatDetailState> _sub;
  StreamSubscription<dynamic>? _messagesSub;

  String? _patientId;
  String? _doctorId;
  List<ChatMessage> _messages = const <ChatMessage>[];

  List<ChatMessage> get messages => _messages;

  Future<void> loadMessages(String patientId) async {
    _patientId = patientId;
    final doctorId = await TokenStorage.getUserId();
    if (doctorId == null || doctorId.isEmpty) {
      emit(const ChatDetailError('Doctor id is missing.'));
      return;
    }
    _doctorId = doctorId;

    await _messagesSub?.cancel();
    emit(const ChatDetailLoading());

    _messagesSub = _getMessagesUseCase(doctorId: doctorId, patientId: patientId)
        .listen((result) {
          result.fold((failure) => emit(ChatDetailError(failure.message)), (
            messages,
          ) {
            _messages = messages;
            emit(ChatDetailLoaded(messages));
            unawaited(_markIncomingMessagesAsRead(messages));
          });
        });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final patientId = _patientId ?? DoctorChatSession.activePatientId;
    final doctorId = _doctorId ?? await TokenStorage.getUserId();
    if (patientId == null ||
        patientId.isEmpty ||
        doctorId == null ||
        doctorId.isEmpty) {
      emit(const ChatDetailError('Chat participants are missing.'));
      return;
    }
    _patientId = patientId;
    _doctorId = doctorId;

    emit(const ChatDetailSending());
    final result = await _sendMessageUseCase(
      doctorId: doctorId,
      patientId: patientId,
      senderId: doctorId,
      text: text,
    );
    result.fold((failure) => emit(ChatDetailError(failure.message)), (_) {});
  }

  void _onStateChanged(ChatDetailState state) {
    if (state is ChatDetailLoaded) {
      _messages = state.messages;
    }
    _notifyListeners();
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
    result.fold((failure) => emit(ChatDetailError(failure.message)), (_) {});
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
    result.fold((failure) => emit(ChatDetailError(failure.message)), (_) {});
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
    await _sub.cancel();
    return super.close();
  }
}

class ChatDetailViewModel extends ChatDetailCubit {
  ChatDetailViewModel() : super();
}
