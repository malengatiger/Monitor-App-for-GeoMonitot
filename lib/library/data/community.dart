import 'package:meta/meta.dart';
import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/data/position.dart';
import 'package:geo_monitor/library/data/ratingContent.dart';

import 'city.dart';

class Community {
  String? name, countryId, communityId, email, countryName, created;
  late int population = 0;
  List<Position>? polygon = [];
  List<Photo>? photoUrls = [];
  List<Video>? videoUrls = [];
  List<RatingContent>? ratings = [];
  List<City>? nearestCities = [];

  Community(
      {required this.name,
      this.countryId,
      this.email,
      required this.countryName,
      this.polygon,
      required this.created,
      required this.population,
      this.nearestCities,
      this.communityId});

  Community.fromJson(Map data) {
    name = data['name'];
    countryId = data['countryId'];
    communityId = data['communityId'];
    email = data['email'];
    countryName = data['countryName'];
    communityId = data['communityId'];
    created = data['created'];
    population = data['population'];
    polygon = [];
    if (data['polygon'] != null) {
      List list = data['polygon'];
      for (var p in list) {
        polygon!.add(Position.fromJson(p));
      }
    }
    photoUrls = [];
    if (data['photoUrls'] != null) {
      List list = data['photoUrls'];
      for (var p in list) {
        photoUrls!.add(Photo.fromJson(p));
      }
    }
    videoUrls = [];
    if (data['videoUrls'] != null) {
      List list = data['videoUrls'];
      for (var p in list) {
        videoUrls?.add(Video.fromJson(p));
      }
    }
    ratings = [];
    if (data['ratings'] != null) {
      List list = data['ratings'];
      for (var p in list) {
        ratings?.add(RatingContent.fromJson(p));
      }
    }
    nearestCities = [];
    if (data['nearestCities'] != null) {
      List list = data['nearestCities'];
      for (var p in list) {
        nearestCities?.add(City.fromJson(p));
      }
    }
  }
  Map<String, dynamic> toJson() {
    List mPolygon = [];
    if (polygon != null) {
      for (var pos in polygon!) {
        mPolygon.add(pos.toJson());
      }
    }
    List mPhotos = [];
    if (photoUrls != null) {
      for (var photo in photoUrls!) {
        mPhotos.add(photo.toJson());
      }
    }
    List mVideos = [];
    if (videoUrls != null) {
      for (var photo in videoUrls!) {
        mVideos.add(photo.toJson());
      }
    }
    List mRatings = [];
    if (ratings != null) {
      for (var r in ratings!) {
        mRatings.add(r.toJson());
      }
    }
    List mCities = [];
    if (nearestCities != null) {
      for (var r in nearestCities!) {
        mCities.add(r.toJson());
      }
    }
    Map<String, dynamic> map = {
      'name': name,
      'countryId': countryId,
      'communityId': communityId,
      'email': email,
      'countryName': countryName,
      'polygon': mPolygon,
      'population': population,
      'created': created,
      'photoUrls': mPhotos,
      'videoUrls': mVideos,
      'ratings': mRatings,
      'nearestCities': mCities,
    };
    return map;
  }
}
