import 'package:hive/hive.dart';

import '../data/position.dart';
import 'user.dart';
import 'field_monitor_schedule.dart';
import 'photo.dart';
import 'project.dart';
import 'project_position.dart';
import 'video.dart';

part 'data_bag.g.dart';

@HiveType(typeId: 18)
class DataBag {
  @HiveField(0)
  List<Photo>? photos;
  @HiveField(1)
  List<Video>? videos;
  @HiveField(2)
  List<FieldMonitorSchedule>? fieldMonitorSchedules;
  @HiveField(3)
  List<ProjectPosition>? projectPositions;
  @HiveField(4)
  List<Project>? projects;
  @HiveField(5)
  String? date;
  @HiveField(6)
  List<User>? users;

  DataBag({
    required this.photos,
    required this.videos,
    required this.fieldMonitorSchedules,
    required this.projectPositions,
    required this.projects,
    required this.date, required this.users,
  });

  DataBag.fromJson(Map data) {
    date = data['date'];
    users = [];
    if (data['users'] != null) {
      List m = data['users'];
      for (var element in m) {
        var pos = User.fromJson(element);
        users?.add(pos);
      }
    }
    projectPositions = [];
    if (data['projectPositions'] != null) {
      List m = data['projectPositions'];
      for (var element in m) {
        var pos = ProjectPosition.fromJson(element);
        projectPositions?.add(pos);
      }
    }
    projects = [];
    if (data['projects'] != null) {
      List m = data['projects'];
      for (var element in m) {
        var project = Project.fromJson(element);
        projects?.add(project);
      }
    }
    photos = [];
    if (data['photos'] != null) {
      List m = data['photos'];
      for (var element in m) {
        var photo = Photo.fromJson(element);
        photos?.add(photo);
      }
    }
    videos = [];
    if (data['videos'] != null) {
      List m = data['videos'];
      for (var element in m) {
        var video = Video.fromJson(element);
        videos?.add(video);
      }
    }
    fieldMonitorSchedules = [];
    if (data['fieldMonitorSchedules'] != null) {
      List m = data['fieldMonitorSchedules'];
      for (var element in m) {
        var schedule = FieldMonitorSchedule.fromJson(element);
        fieldMonitorSchedules?.add(schedule);
      }
    }
  }
  Map<String, dynamic> toJson() {
    List mPhotos = [];
    if (photos != null) {
      for (var r in photos!) {
        mPhotos.add(r.toJson());
      }
    }
    List mVideos = [];
    if (videos != null) {
      for (var r in videos!) {
        mVideos.add(r.toJson());
      }
    }
    List mSchedules = [];
    if (fieldMonitorSchedules != null) {
      for (var r in fieldMonitorSchedules!) {
        mSchedules.add(r.toJson());
      }
    }
    List mProjects = [];
    if (projects != null) {
      for (var r in projects!) {
        mProjects.add(r.toJson());
      }
    }
    List mPositions = [];
    if (projectPositions != null) {
      for (var r in projectPositions!) {
        mPositions.add(r.toJson());
      }
    }
    List mUsers = [];
    if (users != null) {
      for (var r in users!) {
        mUsers.add(r.toJson());
      }
    }

    Map<String, dynamic> map = {
      'photos': mPhotos,
      'videos': mVideos,
      'fieldMonitorSchedules': mSchedules,
      'projectPositions': mPositions,
      'projects': mProjects,
      'users': mUsers,
      'date': date,
    };
    return map;
  }
}
