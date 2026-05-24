// lib/patient/features/chat/chat_view_model.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/network/token_storage.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';
import 'package:grad_project/patient/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:grad_project/patient/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:grad_project/patient/features/chat/domain/usecases/delete_message_usecase.dart';
import 'package:grad_project/patient/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:grad_project/patient/features/chat/domain/usecases/mark_as_read_usecase.dart';
import 'package:grad_project/patient/features/chat/domain/usecases/send_message_usecase.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isDoctorChat;
  const ChatLoaded(this.messages, this.isDoctorChat);
}

class ChatSending extends ChatState {
  const ChatSending();
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
}

class ChatCubit extends Cubit<ChatState> implements Listenable {
  ChatCubit({
    required bool isDoctorChat,
    GetMessagesUseCase? getMessagesUseCase,
    SendMessageUseCase? sendMessageUseCase,
    MarkAsReadUseCase? markAsReadUseCase,
    DeleteMessageUseCase? deleteMessageUseCase,
  })  : _isDoctorChat = isDoctorChat,
        _getMessagesUseCase =
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
        super(const ChatInitial()) {
    _sub = stream.listen(_onStateChanged);
    if (_isDoctorChat) {
      unawaited(_loadDoctorMessages());
    } else {
      _addInitialMessages();
      _emitLoaded();
    }
  }

  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final MarkAsReadUseCase _markAsReadUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;

  final TextEditingController textController = TextEditingController();
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();
  late final StreamSubscription<ChatState> _sub;

  bool _isDoctorChat = true;
  final List<ChatMessage> _messages = [];

  bool get isDoctorChat => _isDoctorChat;
  List<ChatMessage> get messages => _messages;

  void toggleChatMode(bool isDoctor) {
    if (_isDoctorChat != isDoctor) {
      _isDoctorChat = isDoctor;
      _messages.clear();
      if (_isDoctorChat) {
        unawaited(_loadDoctorMessages());
      } else {
        _addInitialMessages();
        _emitLoaded();
      }
    }
  }

  void sendMessage() {
    if (textController.text.trim().isEmpty) return;

    final text = textController.text;
    final newMessage = ChatMessage(
      text: text,
      isSender: true,
      timestamp: DateTime.now(),
    );

    _messages.add(newMessage);
    textController.clear();
    _emitLoaded();

    if (_isDoctorChat) {
      unawaited(_sendDoctorMessage(text));
      return;
    }

    Future.delayed(const Duration(seconds: 1), () {
      _messages.add(
        ChatMessage(
          text: "انا الذكاء الاصطبحي لو محتاجني ف حاجه متكلمنيش ",
          isSender: false,
          timestamp: DateTime.now(),
          doctorName: "AI Assistant",
        ),
      );
      _emitLoaded();
    });
  }

  Future<void> markAsRead(String messageId) async {
    if (!_isDoctorChat) return;
    final result = await _markAsReadUseCase(messageId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {},
    );
  }

  Future<void> deleteMessage(String messageId) async {
    if (!_isDoctorChat) return;
    final result = await _deleteMessageUseCase(messageId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {
        _messages.removeWhere((m) => m.id == messageId);
        _emitLoaded();
      },
    );
  }

  Future<void> _loadDoctorMessages() async {
    emit(const ChatLoading());
    final patientId = await TokenStorage.getUserId();
    if (patientId == null || patientId.isEmpty) {
      emit(const ChatError('Patient id is missing.'));
      return;
    }

    final result = await _getMessagesUseCase(patientId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) {
        _messages
          ..clear()
          ..addAll(messages);
        _emitLoaded();
      },
    );
  }

  Future<void> _sendDoctorMessage(String text) async {
    final patientId = await TokenStorage.getUserId();
    if (patientId == null || patientId.isEmpty) {
      emit(const ChatError('Patient id is missing.'));
      return;
    }

    emit(ChatSending());
    final result = await _sendMessageUseCase(patientId: patientId, text: text);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (message) {
        if (_messages.isNotEmpty) {
          _messages.removeLast();
        }
        _messages.add(message);
        _emitLoaded();
      },
    );
  }

  void _addInitialMessages() {
    if (_isDoctorChat) {
      _messages.add(
        ChatMessage(
          text:
              "يا فتاح يا عليم يا رزاق يا كريم يا بركه باسم الله اي يا مريض يا عاجز عامل اي ",
          isSender: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          doctorName: "Dr. Sarah Johnson",
        ),
      );
    } else {
      _messages.add(
        ChatMessage(
          text:
              "صباحك كلو رزق يا مريض يا عاجز انا الذكاء الاصطبحي لو محتاجني ف حاجه متكلمنيش ",
          isSender: false,
          timestamp: DateTime.now(),
          doctorName: "AI Assistant",
        ),
      );
    }
  }

  void _emitLoaded() {
    emit(ChatLoaded(List<ChatMessage>.unmodifiable(_messages), _isDoctorChat));
  }

  void _onStateChanged(ChatState state) {
    if (state is ChatLoaded) {
      _messages
        ..clear()
        ..addAll(state.messages);
      _isDoctorChat = state.isDoctorChat;
    }
    _notifyListeners();
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

class ChatViewModel extends ChatCubit {
  ChatViewModel({required super.isDoctorChat});
}
