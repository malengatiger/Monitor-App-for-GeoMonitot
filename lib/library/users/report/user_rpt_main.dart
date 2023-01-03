import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/user.dart';
import 'package:geo_monitor/library/users/report/user_rpt_mobile.dart';
import 'package:geo_monitor/library/users/report/user_rpt_tablet.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'user_rpt_desktop.dart';

class UserReportMain extends StatelessWidget {
  final User user;

  UserReportMain(this.user);

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: UserReportMobile(user),
      tablet: UserReportTablet(user),
      desktop: UserReportDesktop(user),
    );
  }
}
