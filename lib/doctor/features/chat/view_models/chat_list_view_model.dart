// lib/doctor/features/chat/view_models/chat_list_view_model.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/network/token_storage.dart';
import 'package:grad_project/doctor/features/chat/data/datasources/chat_firestore_data_source.dart';
import 'package:grad_project/doctor/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:grad_project/doctor/features/chat/domain/usecases/watch_chat_list_usecase.dart';
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
  ChatListCubit({WatchChatListUseCase? watchChatListUseCase})
    : _watchChatListUseCase =
          watchChatListUseCase ??
          WatchChatListUseCase(
            ChatRepositoryImpl(ChatFirestoreDataSourceImpl()),
          ),
      super(const ChatListInitial()) {
    _sub = stream.listen((_) => _notifyListeners());
    unawaited(_startChatListStream());
  }

  final WatchChatListUseCase _watchChatListUseCase;
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();
  late final StreamSubscription<ChatListState> _sub;
  StreamSubscription<dynamic>? _chatListSub;

  List<ChatUser> _chats = const <ChatUser>[];
  List<ChatUser> _filtered = const <ChatUser>[];

  List<ChatUser> get chats => _filtered;

  Future<void> _startChatListStream() async {
    final doctorId = await TokenStorage.getUserId();
    if (doctorId == null || doctorId.isEmpty) {
      emit(const ChatListError('Doctor id is missing.'));
      return;
    }

    emit(const ChatListLoading());
    await _chatListSub?.cancel();
    _chatListSub = _watchChatListUseCase(doctorId: doctorId).listen((result) {
      result.fold((failure) => emit(ChatListError(failure.message)), (chats) {
        _chats = chats;
        _filtered = chats;
        emit(ChatListLoaded(_chats, _filtered));
      });
    });
  }

  Future<void> loadChats() async {
    await _startChatListStream();
  }

  void filterChats(String query) {
    final search = query.trim().toLowerCase();
    _filtered = search.isEmpty
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
    await _chatListSub?.cancel();
    await _sub.cancel();
    return super.close();
  }
}

class ChatListViewModel extends ChatListCubit {
  ChatListViewModel() : super();
}
