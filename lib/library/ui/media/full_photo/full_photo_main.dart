import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/data/project.dart';
import 'package:geo_monitor/library/ui/media/full_photo/full_photo_desktop.dart';
import 'package:geo_monitor/library/ui/media/full_photo/full_photo_mobile.dart';
import 'package:geo_monitor/library/ui/media/full_photo/full_photo_tablet.dart';
import 'package:responsive_builder/responsive_builder.dart';

class FullPhotoMain extends StatelessWidget {
  final Photo photo;
  final Project project;

  FullPhotoMain(this.photo, this.project);

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: FullPhotoMobile(photo, project),
      tablet: FullPhotoTablet(photo, project),
      desktop: FullPhotoDesktop(photo, project),
    );
  }
}
