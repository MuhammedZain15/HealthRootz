// lib/patient/features/chat/chat_view_model.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/network/token_storage.dart';
import 'package:grad_project/services/ai_service.dart';
import 'package:grad_project/patient/features/ai_chat/data/ai_chat_datasource.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';
import 'package:grad_project/patient/features/chat/data/datasources/chat_firestore_data_source.dart';
import 'package:grad_project/patient/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:grad_project/patient/features/chat/data/utils/chat_doctor_id.dart';
import 'package:grad_project/patient/features/chat/domain/repositories/chat_repository.dart';

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
    String? sessionId,
    ChatRepository? repository,
  }) : _isDoctorChat = isDoctorChat,
       _sessionId = sessionId,
       _repository =
           repository ?? ChatRepositoryImpl(ChatFirestoreDataSourceImpl()),
       super(const ChatInitial()) {
    _sub = stream.listen(_onStateChanged);
    if (_isDoctorChat) {
      unawaited(_startDoctorChatStream());
    } else {
      _addInitialMessages();
      _emitLoaded();
    }
  }

  final ChatRepository _repository;
  final AIService _aiService = AIService();
  final AiChatDataSource _aiChatDataSource = AiChatDataSourceImpl();

  final TextEditingController textController = TextEditingController();
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();
  late final StreamSubscription<ChatState> _sub;
  StreamSubscription<dynamic>? _messagesSub;
  VoidCallback? _onEmergency;

  bool _isDoctorChat = true;
  String? _doctorId;
  String? _patientId;
  String? _sessionId;
  final List<ChatMessage> _messages = [];

  bool get isDoctorChat => _isDoctorChat;
  List<ChatMessage> get messages => _messages;

  void _safeEmit(ChatState state) {
    if (isClosed) return;
    emit(state);
  }

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

    unawaited(_sendAIMessage(text));
  }

  Future<void> markAsRead(String messageId) async {
    if (!_isDoctorChat) return;
    final doctorId = _doctorId;
    final patientId = _patientId;
    if (doctorId == null || patientId == null) return;

    final result = await _repository.markAsRead(
      doctorId: doctorId,
      patientId: patientId,
      messageId: messageId,
    );
    if (isClosed) return;
    result.fold(
      (failure) => _safeEmit(ChatError(failure.message)),
      (_) {},
    );
  }

  Future<void> deleteMessage(String messageId) async {
    if (_isDoctorChat) {
      final doctorId = _doctorId;
      final patientId = _patientId;
      if (doctorId == null || patientId == null) return;

      final result = await _repository.deleteMessage(
        doctorId: doctorId,
        patientId: patientId,
        messageId: messageId,
      );
      if (isClosed) return;
      result.fold(
        (failure) => _safeEmit(ChatError(failure.message)),
        (_) {},
      );
    } else {
      // Delete from AI chat session
      if (_sessionId == null || _patientId == null) return;
      
      try {
        await _aiChatDataSource.deleteMessage(
          _patientId!,
          _sessionId!,
          messageId,
        );
        if (isClosed) return;
        _messages.removeWhere((msg) => msg.id == messageId);
        _emitLoaded();
      } catch (e) {
        _safeEmit(const ChatError('Failed to delete message'));
      }
    }
  }

  Future<void> _startDoctorChatStream() async {
    _safeEmit(const ChatLoading());
    final patientId = await TokenStorage.getUserId();
    if (isClosed) return;
    if (patientId == null || patientId.isEmpty) {
      _safeEmit(const ChatError('Patient id is missing.'));
      return;
    }
    _patientId = patientId;

    final doctorResult = await _repository.resolveDoctorId(patientId);
    if (isClosed) return;
    final doctorId = doctorResult.fold((failure) {
      _safeEmit(ChatError(failure.message));
      return null;
    }, (id) => id);
    if (doctorId == null) return;
    _doctorId = doctorId;

    await _messagesSub?.cancel();
    if (isClosed) return;
    _messagesSub = _repository
        .watchMessages(doctorId: doctorId, patientId: patientId)
        .listen((result) {
          if (isClosed) return;
          result.fold((failure) => _safeEmit(ChatError(failure.message)), (
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

  Future<void> _sendDoctorMessage(String text) async {
    final patientId = _patientId ?? await TokenStorage.getUserId();
    if (isClosed) return;
    if (patientId == null || patientId.isEmpty) {
      _safeEmit(const ChatError('Patient id is missing.'));
      return;
    }
    _patientId = patientId;

    var doctorId = _doctorId;
    if (!isResolvableDoctorId(doctorId)) {
      final doctorResult = await _repository.resolveDoctorId(patientId);
      if (isClosed) return;
      doctorId = doctorResult.fold((failure) {
        _safeEmit(ChatError(failure.message));
        return null;
      }, (id) => id);
      if (doctorId == null) return;
      _doctorId = doctorId;
    }

    // Firestore doctor queries require exact id match with doctor JWT user id.
    if (!isResolvableDoctorId(doctorId)) {
      _safeEmit(const ChatError(kDoctorAssignmentMissingMessage));
      return;
    }
    final resolvedDoctorId = doctorId!.trim();
    _doctorId = resolvedDoctorId;

    // Add optimistically before sending
    _messages.add(ChatMessage(
      text: text,
      isSender: true,
      timestamp: DateTime.now(),
    ));
    _emitLoaded();

    _safeEmit(const ChatSending());
    final result = await _repository.sendMessage(
      doctorId: resolvedDoctorId,
      patientId: patientId,
      senderId: patientId,
      text: text,
    );
    if (isClosed) return;
    result.fold((failure) {
      _safeEmit(ChatError(failure.message));
      _emitLoaded();
    }, (_) {});
  }

  Future<void> _sendAIMessage(String userText) async {
    // Initialize session if not already done
    if (_sessionId == null && !_isDoctorChat) {
      _patientId ??= await TokenStorage.getUserId();
      if (isClosed) return;
      if (_patientId != null) {
        _sessionId = await _aiChatDataSource.createSession(_patientId!);
      }
    }

    // Save user message to Firestore
    if (_sessionId != null && _patientId != null && !_isDoctorChat) {
      await _aiChatDataSource.saveMessage(
        _patientId!,
        _sessionId!,
        userText,
        true,
      );
      if (isClosed) return;
    }

    final result = await _aiService.sendMessage(userText);
    if (isClosed) return;
    _messages.add(ChatMessage(
      text: result.text,
      isSender: false,
      timestamp: DateTime.now(),
      doctorName: "AI Assistant",
    ));

    // Save AI response to Firestore
    if (_sessionId != null && _patientId != null && !_isDoctorChat) {
      await _aiChatDataSource.saveMessage(
        _patientId!,
        _sessionId!,
        result.text,
        false,
      );
      if (isClosed) return;
      // Update session metadata
      await _aiChatDataSource.updateSessionMeta(
        _patientId!,
        _sessionId!,
        userText,
        result.text,
      );
      if (isClosed) return;
    }

    _emitLoaded();
    if (result.isEmergency) {
      _onEmergency?.call();
    }
  }

  Future<void> initAISession(String? sessionId) async {
    _sessionId = sessionId;
    _patientId = await TokenStorage.getUserId();
    if (isClosed) return;
    
    if (_sessionId != null && _patientId != null) {
      // Load existing session messages
      await loadSession(_sessionId!);
    } else if (_sessionId == null && _patientId != null) {
      // Create new session
      _sessionId = await _aiChatDataSource.createSession(_patientId!);
      if (isClosed) return;
      _addInitialMessages();
      _emitLoaded();
    }
  }

  Future<void> loadSession(String sessionId) async {
    try {
      _messages.clear();
      final messagesStream = _aiChatDataSource.watchMessages(
        _patientId!,
        sessionId,
      );
      
      await for (final messages in messagesStream.take(1)) {
        if (isClosed) return;
        _messages.addAll(messages);
      }
      if (isClosed) return;
      _emitLoaded();
    } catch (e) {
      _safeEmit(const ChatError('Failed to load session'));
    }
  }

  Future<void> forwardToDoctor(String text) async {
    if (!_isDoctorChat) {
      _isDoctorChat = true;
      _messages.clear();
      await _messagesSub?.cancel();
      _messagesSub = null;
      await _startDoctorChatStream();
      if (isClosed) return;
    }
    await _sendDoctorMessage(text);
  }

  Future<void> forwardToAI(String text) async {
    if (_isDoctorChat) {
      _isDoctorChat = false;
      _messages.clear();
      await initAISession(null);
      if (isClosed) return;
    }
    await _sendAIMessage(text);
  }

  void _addInitialMessages() {
    if (_isDoctorChat) {
      // Doctor chat is driven entirely by the Firestore snapshot listener.
      return;
    } else {
      _messages.add(
        ChatMessage(
          text:
              "How can i help you today? You can ask me anything about your health",
          isSender: false,
          timestamp: DateTime.now(),
          doctorName: "AI Assistant",
        ),
      );
    }
  }

  void _emitLoaded() {
    _safeEmit(
      ChatLoaded(List<ChatMessage>.unmodifiable(_messages), _isDoctorChat),
    );
  }

  Future<void> _markIncomingMessagesAsRead(List<ChatMessage> messages) async {
    if (!_isDoctorChat) return;
    for (final message in messages) {
      final messageId = message.id;
      if (messageId == null || messageId.isEmpty) continue;
      if (message.isSender || message.isRead) continue;
      await markAsRead(messageId);
    }
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
    _messagesSub = null;
    await _sub.cancel();
    textController.dispose();
    return super.close();
  }
}

class ChatViewModel extends ChatCubit {
  ChatViewModel({required super.isDoctorChat, super.sessionId});

  void setOnEmergency(VoidCallback callback) {
    _onEmergency = callback;
  }
}

// commit update
 