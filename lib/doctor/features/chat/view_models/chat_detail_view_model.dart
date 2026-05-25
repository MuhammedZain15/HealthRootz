// lib/doctor/features/chat/view_models/chat_detail_view_model.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/doctor/features/chat/data/datasources/chat_remote_data_source.dart';
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
  })  : _getMessagesUseCase =
            getMessagesUseCase ??
            GetMessagesUseCase(
              ChatRepositoryImpl(ChatRemoteDataSourceImpl()),
            ),
        _sendMessageUseCase =
            sendMessageUseCase ??
            SendMessageUseCase(
              ChatRepositoryImpl(ChatRemoteDataSourceImpl()),
            ),
        _markAsReadUseCase =
            markAsReadUseCase ??
            MarkAsReadUseCase(
              ChatRepositoryImpl(ChatRemoteDataSourceImpl()),
            ),
        _deleteMessageUseCase =
            deleteMessageUseCase ??
            DeleteMessageUseCase(
              ChatRepositoryImpl(ChatRemoteDataSourceImpl()),
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

  String? _patientId;
  List<ChatMessage> _messages = const <ChatMessage>[];

  List<ChatMessage> get messages => _messages;

  Future<void> loadMessages(String patientId) async {
    _patientId = patientId;
    emit(const ChatDetailLoading());
    final result = await _getMessagesUseCase(patientId);
    result.fold(
      (failure) => emit(ChatDetailError(failure.message)),
      (messages) {
        _messages = messages;
        emit(ChatDetailLoaded(messages));
      },
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final patientId = _patientId ?? DoctorChatSession.activePatientId;
    if (patientId == null || patientId.isEmpty) {
      emit(const ChatDetailError('Patient id is missing.'));
      return;
    }
    _patientId = patientId;

    emit(const ChatDetailSending());
    final result = await _sendMessageUseCase(patientId: patientId, text: text);
    await result.fold(
      (failure) async => emit(ChatDetailError(failure.message)),
      (_) async => await _refreshMessages(patientId),
    );
  }

  Future<void> _refreshMessages(String patientId) async {
    final result = await _getMessagesUseCase(patientId);
    result.fold(
      (failure) => emit(ChatDetailError(failure.message)),
      (messages) {
        _messages = messages;
        emit(ChatDetailLoaded(messages));
      },
    );
  }

  void _onStateChanged(ChatDetailState state) {
    if (state is ChatDetailLoaded) {
      _messages = state.messages;
    }
    _notifyListeners();
  }

  Future<void> markAsRead(String messageId) async {
    final result = await _markAsReadUseCase(messageId);
    result.fold(
      (failure) => emit(ChatDetailError(failure.message)),
      (_) {},
    );
  }

  Future<void> deleteMessage(String messageId) async {
    final result = await _deleteMessageUseCase(messageId);
    result.fold(
      (failure) => emit(ChatDetailError(failure.message)),
      (_) {
        _messages = _messages.where((m) => m.id != messageId).toList(growable: false);
        emit(ChatDetailLoaded(_messages));
      },
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
    await _sub.cancel();
    return super.close();
  }
}

class ChatDetailViewModel extends ChatDetailCubit {
  ChatDetailViewModel() : super();
}
