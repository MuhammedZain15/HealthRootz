// lib/doctor/features/chat/view_models/chat_list_view_model.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/network/token_storage.dart';
import 'package:grad_project/doctor/features/chat/data/datasources/chat_firestore_data_source.dart';
import 'package:grad_project/doctor/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:grad_project/doctor/features/chat/domain/repositories/chat_repository.dart';
import 'package:grad_project/doctor/features/chat/models/chat_model.dart';
import 'package:grad_project/patient/features/patient/data/repositories/patient_repository_impl.dart';

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
  ChatListCubit({
    ChatRepository? repository,
    Future<List<Map<String, dynamic>>> Function(String doctorId)?
    fetchDoctorPatients,
  }) : _repository =
           repository ?? ChatRepositoryImpl(ChatFirestoreDataSourceImpl()),
       _fetchPatientsFn = fetchDoctorPatients ?? _defaultFetchDoctorPatients,
       super(const ChatListInitial()) {
    _sub = stream.listen((_) => _notifyListeners());
    unawaited(_startChatListStream());
  }

  final ChatRepository _repository;
  final Future<List<Map<String, dynamic>>> Function(String doctorId)
  _fetchPatientsFn;
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();
  late final StreamSubscription<ChatListState> _sub;
  StreamSubscription<dynamic>? _chatListSub;

  List<ChatUser> _chats = const <ChatUser>[];
  List<ChatUser> _filtered = const <ChatUser>[];

  List<ChatUser> get chats => _filtered;

  void _safeEmit(ChatListState state) {
    if (isClosed) return;
    emit(state);
  }

  static Future<List<Map<String, dynamic>>> _defaultFetchDoctorPatients(
    String doctorId,
  ) async {
    final repository = PatientRepositoryImpl();
    final result = await repository.getPatients();
    return result.fold((_) => <Map<String, dynamic>>[], (patients) {
      return patients
          .map(
            (patient) => <String, dynamic>{
              'id': patient.chatUserId,
              '_id': patient.id,
              'patientRecordId': patient.id,
              'user': patient.userId,
              'name': patient.name,
              'patientName': patient.name,
              'phone': patient.phone,
            },
          )
          .toList(growable: false);
    });
  }

  Future<List<Map<String, dynamic>>> _fetchDoctorPatients(
    String doctorId,
  ) {
    return _fetchPatientsFn(doctorId);
  }

  Future<void> _startChatListStream() async {
    final doctorId = await TokenStorage.getUserId();
    if (isClosed) return;
    if (doctorId == null || doctorId.isEmpty) {
      _safeEmit(const ChatListError('Doctor id is missing.'));
      return;
    }

    _safeEmit(const ChatListLoading());
    await _chatListSub?.cancel();
    if (isClosed) return;
    _chatListSub = _repository
        .watchChatList(
          doctorId: doctorId,
          fetchPatients: () => _fetchDoctorPatients(doctorId),
        )
        .listen((result) {
          if (isClosed) return;
          result.fold((failure) => _safeEmit(ChatListError(failure.message)), (
            chats,
          ) {
            if (isClosed) return;
            _chats = chats;
            _filtered = chats;
            _safeEmit(ChatListLoaded(_chats, _filtered));
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
    _safeEmit(ChatListLoaded(_chats, _filtered));
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
    _chatListSub = null;
    await _sub.cancel();
    return super.close();
  }
}

class ChatListViewModel extends ChatListCubit {
  ChatListViewModel({
    super.fetchDoctorPatients,
  });
}
