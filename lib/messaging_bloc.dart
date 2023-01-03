import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'library/api/Constants.dart';

/// This Bloc manages messaging (FCM)
class AdminMessagingBloc {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  AdminMessagingBloc() {
    initialize();
  }

  subscribe() async {
    debugPrint(
        '\n\n🍏🍏 💙💙💙 💙💙💙 AdminMessagingBloc: Subscribe to FCM topics ... 💙💙💙💙💙💙 🍏🍏');
    await firebaseMessaging.subscribeToTopic(Constants.TOPIC_USERS);
    await firebaseMessaging.subscribeToTopic(Constants.TOPIC_SETTLEMENTS);
    await firebaseMessaging.subscribeToTopic(Constants.TOPIC_PROJECTS);
    await firebaseMessaging.subscribeToTopic(Constants.TOPIC_QUESTIONNAIRES);
    await firebaseMessaging.subscribeToTopic(Constants.TOPIC_ORGANIZATIONS);
    debugPrint(
        '💙💙💙 🍎🍎🍎🍎 AdminMessagingBloc: Subscriptions to FCM topics completed. 🍎🍎🍎🍎🍎🍎');
    debugPrint(
        '🔆🔆🔆🔆 topics: 🔆 ${Constants.TOPIC_USERS} 🔆 ${Constants.TOPIC_SETTLEMENTS} 🔆 ${Constants.TOPIC_PROJECTS} 🔆 ${Constants.TOPIC_ORGANIZATIONS} 🔆 ${Constants.TOPIC_QUESTIONNAIRES} 🔆🔆🔆🔆 \n\n');
  }

  initialize() async {
    debugPrint(
        "🍎🍎🍎🍎 AdminMessagingBloc: initialize: Setting up FCM messaging 🧡💛🧡💛 configurations & streams: 🧡💛 ${DateTime.now().toIso8601String()}");
    
    firebaseMessaging.setAutoInitEnabled(true);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      var mJson = json.encode(message.data);
      print(
          "\n\n🍏🍏 AdminMessagingBloc: 🍏🍏 onMessage: 🍏🍏 type: 🔵 $mJson 🔵 🧡🧡🧡 from ${message.from} 🍎🍎🍎");
      var type = message.data['type'];
      switch (type) {
        case Constants.TOPIC_USERS:
          _userController.sink.add(message);
          break;
        case Constants.TOPIC_SETTLEMENTS:
          _settController.sink.add(message);
          break;
        case Constants.TOPIC_PROJECTS:
          _projectController.sink.add(message);
          break;
        case Constants.TOPIC_QUESTIONNAIRES:
          _questController.sink.add(message);
          break;
        case Constants.TOPIC_ORGANIZATIONS:
          _orgController.sink.add(message);
          break;
      }
    });
    var token = await firebaseMessaging.getToken();
    debugPrint(
        '🧩🧩🧩🧩🧩🧩 AdminMessagingBloc: FCM token: 🧩🧩🧩🧩🧩🧩🧩🧩 🐥🐥🐥🐥🐥 $token 🐥🐥🐥🐥🐥');
    subscribe();
  }

  StreamController _userController = StreamController.broadcast();
  StreamController _settController = StreamController.broadcast();
  StreamController _projectController = StreamController.broadcast();
  StreamController _questController = StreamController.broadcast();
  StreamController _orgController = StreamController.broadcast();

  Stream get userStream => _userController.stream;

  Stream get settlementStream => _settController.stream;

  Stream get projectStream => _projectController.stream;

  Stream get questionnaireStream => _questController.stream;

  Stream get organizationStream => _orgController.stream;

  closeStreams() {
    _userController.close();
    _settController.close();
    _projectController.close();
    _questController.close();
    _orgController.close();
  }
}
