// lib/doctor/features/chat/view_models/chat_list_view_model.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/doctor/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:grad_project/doctor/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:grad_project/doctor/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:grad_project/doctor/features/chat/models/chat_model.dart';

abstract class ChatListState {
  const ChatListState();
}

class ChatListInitial extends ChatListState {
  const ChatListInitial();
}

class ChatListLoading extends ChatListState {
  const ChatListLoading();
}

class ChatListLoaded extends ChatListState {
  final List<ChatUser> chats;
  final List<ChatUser> filtered;
  const ChatListLoaded(this.chats, this.filtered);
}

class ChatListError extends ChatListState {
  final String message;
  const ChatListError(this.message);
}

class ChatListCubit extends Cubit<ChatListState> implements Listenable {
  ChatListCubit({GetMessagesUseCase? getMessagesUseCase})
      : _getMessagesUseCase =
            getMessagesUseCase ??
            GetMessagesUseCase(
              ChatRepositoryImpl(ChatRemoteDataSourceImpl()),
            ),
        super(const ChatListInitial()) {
    _sub = stream.listen((_) => _notifyListeners());
    unawaited(loadChats());
  }

  final GetMessagesUseCase _getMessagesUseCase;
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();
  late final StreamSubscription<ChatListState> _sub;

  List<ChatUser> _chats = const <ChatUser>[];
  List<ChatUser> _filtered = const <ChatUser>[];

  List<ChatUser> get chats => _filtered;

  Future<void> loadChats() async {
    emit(const ChatListLoading());

    final result = await _getMessagesUseCase('all');
    result.fold(
      (failure) => emit(ChatListError(failure.message)),
      (messages) {
        final Map<String, ChatMessage> latestByPatient = <String, ChatMessage>{};
        for (final message in messages) {
          final patientId = message.patientId;
          if (patientId == null || patientId.isEmpty) continue;
          final existing = latestByPatient[patientId];
          if (existing == null) {
            latestByPatient[patientId] = message;
          } else {
            latestByPatient[patientId] = message;
          }
        }

        _chats =
            latestByPatient.entries.map((entry) {
              final msg = entry.value;
              return ChatUser(
                id: entry.key,
                name: entry.key,
                lastMessage: msg.text,
                time: msg.time,
                unreadCount: msg.isRead ? 0 : 1,
                isActive: true,
              );
            }).toList(growable: false);
        _filtered = _chats;
        emit(ChatListLoaded(_chats, _filtered));
      },
    );
  }

  void filterChats(String query) {
    final search = query.trim().toLowerCase();
    _filtered =
        search.isEmpty
            ? _chats
            : _chats
                .where(
                  (chat) =>
                      chat.name.toLowerCase().contains(search) ||
                      chat.lastMessage.toLowerCase().contains(search),
                )
                .toList(growable: false);
    emit(ChatListLoaded(_chats, _filtered));
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

class ChatListViewModel extends ChatListCubit {
  ChatListViewModel() : super();
}
