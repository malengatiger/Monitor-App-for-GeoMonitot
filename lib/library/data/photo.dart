import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/position.dart';

part 'photo.g.dart';

@HiveType(typeId: 4)
class Photo {
  @HiveField(0)
  String? url;
  @HiveField(1)
  String? thumbnailUrl;
  @HiveField(2)
  String? caption;
  @HiveField(3)
  String? created;
  @HiveField(4)
  String? photoId;
  @HiveField(5)
  String? projectPositionId;
  @HiveField(6)
  String? userId;
  @HiveField(7)
  String? organizationId;
  @HiveField(8)
  String? userName;
  @HiveField(9)
  Position? projectPosition;
  @HiveField(10)
  double? distanceFromProjectPosition;
  @HiveField(11)
  String? projectId;
  @HiveField(12)
  String? projectName;
  @HiveField(13)
  int? height;
  @HiveField(14)
  int? width;

  Photo(
      {required this.url,
      required this.caption,
      required this.created,
      required this.userId,
      required this.userName,
      required this.projectPosition,
      required this.distanceFromProjectPosition,
      required this.projectId,
      required this.thumbnailUrl,
      required this.photoId,
      required this.organizationId,
      required this.projectName,
      required this.height,
        required this.projectPositionId,
      required this.width});

  Photo.fromJson(Map data) {
    this.projectPositionId = data['projectPositionId'];
    this.url = data['url'];
    this.thumbnailUrl = data['thumbnailUrl'];
    this.caption = data['caption'];
    this.height = data['height'];
    this.width = data['width'];
    this.created = data['created'];
    this.organizationId = data['organizationId'];
    this.userId = data['userId'];
    this.photoId = data['photoId'];
    this.userName = data['userName'];
    this.distanceFromProjectPosition = data['distanceFromProjectPosition'];
    this.projectId = data['projectId'];
    this.projectName = data['projectName'];
    if (data['projectPosition'] != null) {
      this.projectPosition = Position.fromJson(data['projectPosition']);
    }
    if (this.height == null) {
      this.height = -5;
    }
    if (this.width == null) {
      this.width = -10;
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'url': url,
      'projectPositionId': projectPositionId,
      'caption': caption,
      'created': created,
      'width': width,
      'height': height,
      'userId': userId,
      'organizationId': organizationId,
      'photoId': photoId,
      'userName': userName,
      'distanceFromProjectPosition': distanceFromProjectPosition,
      'projectId': projectId,
      'projectName': projectName,
      'thumbnailUrl': thumbnailUrl,
      'projectPosition': projectPosition == null ? null : projectPosition!.toJson()
    };
    return map;
  }
}





