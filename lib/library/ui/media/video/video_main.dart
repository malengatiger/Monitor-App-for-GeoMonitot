import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/ui/media/video/video_desktop.dart';
import 'package:geo_monitor/library/ui/media/video/video_mobile.dart';
import 'package:geo_monitor/library/ui/media/video/video_tablet.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../data/video.dart';

class VideoMain extends StatelessWidget {
  final Video video;

  VideoMain(this.video);

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: VideoMobile(video),
      tablet: VideoTablet(video),
      desktop: VideoDesktop(video),
    );
  }
}
