import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/user.dart';
import 'package:geo_monitor/library/ui/schedule/scheduler_desktop.dart';
import 'package:geo_monitor/library/ui/schedule/scheduler_mobile.dart';
import 'package:geo_monitor/library/ui/schedule/scheduler_tablet.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SchedulerMain extends StatelessWidget {
  final User user;

  SchedulerMain(this.user);
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: SchedulerMobile(user),
      tablet: SchedulerTablet(user),
      desktop: SchedulerDesktop(user),
    );
  }
}
