// lib/patient/features/chat/chat_view_model.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/network/token_storage.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';
import 'package:grad_project/patient/features/chat/data/datasources/chat_firestore_data_source.dart';
import 'package:grad_project/patient/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:grad_project/patient/features/chat/domain/usecases/delete_message_usecase.dart';
import 'package:grad_project/patient/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:grad_project/patient/features/chat/domain/usecases/mark_as_read_usecase.dart';
import 'package:grad_project/patient/features/chat/domain/usecases/resolve_doctor_id_usecase.dart';
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
    ResolveDoctorIdUseCase? resolveDoctorIdUseCase,
  })  : _isDoctorChat = isDoctorChat,
        _getMessagesUseCase =
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
            MarkAsReadUseCase(
              ChatRepositoryImpl(ChatFirestoreDataSourceImpl()),
            ),
        _deleteMessageUseCase =
            deleteMessageUseCase ??
            DeleteMessageUseCase(
              ChatRepositoryImpl(ChatFirestoreDataSourceImpl()),
            ),
        _resolveDoctorIdUseCase =
            resolveDoctorIdUseCase ??
            ResolveDoctorIdUseCase(
              ChatRepositoryImpl(ChatFirestoreDataSourceImpl()),
            ),
        super(const ChatInitial()) {
    _sub = stream.listen(_onStateChanged);
    if (_isDoctorChat) {
      unawaited(_startDoctorChatStream());
    } else {
      _addInitialMessages();
      _emitLoaded();
    }
  }

  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final MarkAsReadUseCase _markAsReadUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final ResolveDoctorIdUseCase _resolveDoctorIdUseCase;

  final TextEditingController textController = TextEditingController();
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();
  late final StreamSubscription<ChatState> _sub;
  StreamSubscription<dynamic>? _messagesSub;

  bool _isDoctorChat = true;
  String? _doctorId;
  String? _patientId;
  final List<ChatMessage> _messages = [];

  bool get isDoctorChat => _isDoctorChat;
  List<ChatMessage> get messages => _messages;

  void toggleChatMode(bool isDoctor) {
    if (_isDoctorChat != isDoctor) {
      _isDoctorChat = isDoctor;
      _messages.clear();
      unawaited(_messagesSub?.cancel());
      _messagesSub = null;
      if (_isDoctorChat) {
        unawaited(_startDoctorChatStream());
      } else {
        _addInitialMessages();
        _emitLoaded();
      }
    }
  }

  void sendMessage() {
    if (textController.text.trim().isEmpty) return;

    final text = textController.text;
    textController.clear();

    if (_isDoctorChat) {
      unawaited(_sendDoctorMessage(text));
      return;
    }

    final newMessage = ChatMessage(
      text: text,
      isSender: true,
      timestamp: DateTime.now(),
    );

    _messages.add(newMessage);
    _emitLoaded();

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
    final doctorId = _doctorId;
    final patientId = _patientId;
    if (doctorId == null || patientId == null) return;

    final result = await _markAsReadUseCase(
      doctorId: doctorId,
      patientId: patientId,
      messageId: messageId,
    );
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {},
    );
  }

  Future<void> deleteMessage(String messageId) async {
    if (!_isDoctorChat) return;
    final doctorId = _doctorId;
    final patientId = _patientId;
    if (doctorId == null || patientId == null) return;

    final result = await _deleteMessageUseCase(
      doctorId: doctorId,
      patientId: patientId,
      messageId: messageId,
    );
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {},
    );
  }

  Future<void> _startDoctorChatStream() async {
    emit(const ChatLoading());
    final patientId = await TokenStorage.getUserId();
    if (patientId == null || patientId.isEmpty) {
      emit(const ChatError('Patient id is missing.'));
      return;
    }
    _patientId = patientId;

    final doctorResult = await _resolveDoctorIdUseCase(patientId);
    final doctorId = doctorResult.fold((failure) {
      emit(ChatError(failure.message));
      return null;
    }, (id) => id);
    if (doctorId == null) return;
    _doctorId = doctorId;

    await _messagesSub?.cancel();
    _messagesSub = _getMessagesUseCase(
      doctorId: doctorId,
      patientId: patientId,
    ).listen((result) {
      result.fold(
        (failure) => emit(ChatError(failure.message)),
        (messages) {
          _messages
            ..clear()
            ..addAll(messages);
          _emitLoaded();
        },
      );
    });
  }

  Future<void> _sendDoctorMessage(String text) async {
    final patientId = _patientId ?? await TokenStorage.getUserId();
    if (patientId == null || patientId.isEmpty) {
      emit(const ChatError('Patient id is missing.'));
      return;
    }
    _patientId = patientId;

    var doctorId = _doctorId;
    if (doctorId == null || doctorId.isEmpty) {
      final doctorResult = await _resolveDoctorIdUseCase(patientId);
      doctorId = doctorResult.fold((failure) {
        emit(ChatError(failure.message));
        return null;
      }, (id) => id);
      if (doctorId == null) return;
      _doctorId = doctorId;
    }

    emit(const ChatSending());
    final result = await _sendMessageUseCase(
      doctorId: doctorId,
      patientId: patientId,
      senderId: patientId,
      text: text,
    );
    result.fold(
      (failure) {
        emit(ChatError(failure.message));
        _emitLoaded();
      },
      (_) {},
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
    await _messagesSub?.cancel();
    await _sub.cancel();
    return super.close();
  }
}

class ChatViewModel extends ChatCubit {
  ChatViewModel({required super.isDoctorChat});
}
