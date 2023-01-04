import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:geo_monitor/library/data/position.dart';

class User {
  String? name,
      userId,
      email,
      gender,
      cellphone,
      created,
      userType,
      organizationName,
      fcmRegistration,
      countryId,
      organizationId;
  Position? position;

  User(
      {required this.name,
      required this.email,
      required this.userId,
      required this.cellphone,
      required this.created,
      required this.userType,
      required this.gender,
      required this.organizationName,
      required this.organizationId,
      required this.countryId,
      this.position,
      this.fcmRegistration});

  User.fromJson(Map data) {
    name = data['name'];
    userId = data['userId'];
    countryId = data['countryId'];
    gender = data['gender'];
    fcmRegistration = data['fcmRegistration'];
    email = data['email'];
    cellphone = data['cellphone'];
    created = data['created'];
    userType = data['userType'];
    organizationId = data['organizationId'];
    organizationName = data['organizationName'];
    if (data['position'] != null) {
      position = Position.fromJson(data['position']);
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name,
      'userId': userId,
      'countryId': countryId,
      'gender': gender,
      'fcmRegistration': fcmRegistration,
      'email': email,
      'cellphone': cellphone,
      'created': created,
      'userType': userType,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'position': position == null ? null : position!.toJson(),
    };
    return map;
  }
}

const FIELD_MONITOR = 'FIELD_MONITOR';
const ORG_ADMINISTRATOR = 'ORG_ADMINISTRATOR';
const ORG_EXECUTIVE = 'ORG_EXECUTIVE';
const NETWORK_ADMINISTRATOR = 'NETWORK_ADMINISTRATOR';
const ORG_OWNER = 'ORG_OWNER';

const MONITOR_ONCE_A_DAY = 'Once Every Day';
const MONITOR_TWICE_A_DAY = 'Twice A Day';
const MONITOR_THREE_A_DAY = 'Three Times A Day';
const MONITOR_ONCE_A_WEEK = 'Once A Week';

const labels = [
  'Once Every Day',
  'Twice A Day',
  'Three Times A Day',
  'Once A Week',
  'Once A Month',
  'Whenever Necessary'
];

class OrgMessage {
  String? name, userId, message, created, organizationId, projectId;
  String? projectName, adminId, adminName;
  String? frequency, result, orgMessageId;

  OrgMessage(
      {required this.name,
      required this.message,
      required this.userId,
      required this.orgMessageId,
      required this.created,
      required this.projectId,
      required this.projectName,
      required this.adminId,
      required this.adminName,
      required this.frequency,
      required this.organizationId});

  OrgMessage.fromJson(Map data) {
   name = data['name'];
   userId = data['userId'];
   orgMessageId = data['orgMessageId'];
   message = data['message'];
   created = data['created'];
   organizationId = data['organizationId'];
   projectId = data['projectId'];
   projectName = data['projectName'];
   adminId = data['adminId'];
   adminName = data['adminName'];
   frequency = data['frequency'];
   result = data['result'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name,
      'userId': userId,
      'orgMessageId': orgMessageId,
      'message': message,
      'created': created,
      'organizationId': organizationId,
      'projectId': projectId,
      'projectName': projectName,
      'adminId': adminId,
      'adminName': adminName,
      'frequency': frequency,
      'result': result,
    };
    return map;
  }
}

class UserType {
  static const String fieldMonitor = 'FIELD_MONITOR';
  static const String orgAdministrator = 'ORG_ADMINISTRATOR';
  static const String orgExecutive = 'ORG_EXECUTIVE';
  static const String networkAdministrator = 'NETWORK_ADMINISTRATOR';
  static const String orgOwner = 'ORG_OWNER';
}
