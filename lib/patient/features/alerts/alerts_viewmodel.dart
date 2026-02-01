/*
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class AlertsViewModel extends ChangeNotifier {
  final AlertsService _notificationService;
  final List<AlertModel> _alerts = [];
  WebSocketChannel? _channel;
  int _nextId = 1;

  AlertsViewModel(this._notificationService);

  List<AlertModel> get alerts => List.unmodifiable(_alerts);

  Future<void> init() async {
    await _notificationService.init();
  }
  void addAlertFromPayload({required String title, required String body, String iconEmoji = '🔔'}) {
    final id = _nextId++;
    final alert = AlertModel(
      id: id,
      title: title,
      body: body,
      dateTime: DateTime.now(),
      iconEmoji: iconEmoji,
    );
    _alerts.insert(0, alert);
    notifyListeners();

  
  }

  void markRead(int id) {
    final idx = _alerts.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _alerts[idx].read = true;
      notifyListeners();
    }
  }

  void removeAlert(int id) {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // لحد ما ربنا يفرجها ويبعتو ال اند بويننت ونشتغل علي نضافه
  void simulateSample() {
    addAlertFromPayload(
      title: 'Hydration Reminder',
      body: 'Drink more water throughout the day to maintain optimal health',
      iconEmoji: '💧',
    );
  }

 
  void startWebSocket(String url) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen((event) {
        try {
          final data = event is String ? jsonDecode(event) : null;
          if (data != null && data['title'] != null) {
            addAlertFromPayload(
              title: data['title'],
              body: data['body'] ?? '',
              iconEmoji: data['icon'] ?? '🔔',
            );
          }
        } catch (e) {
       
        }
      }, onError: (err) {
        // عشان نهندل الايرورز
      }, onDone: () {
        // قفل خلاص 
      });
    } catch (e) {
      // الشبكه قطعت 
    }
  }

  void stopWebSocket() {
    _channel?.sink.close();
    _channel = null;
  }

  String formattedDate(DateTime dt) {
    return DateFormat.yMMMd().add_jm().format(dt);
  }

  @override
  void dispose() {
    stopWebSocket();
    super.dispose();
  }
}
*/
