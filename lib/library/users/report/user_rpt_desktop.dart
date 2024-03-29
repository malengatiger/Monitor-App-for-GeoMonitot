import 'package:flutter/material.dart';
import '../../data/user.dart';

class UserReportDesktop extends StatefulWidget {
  final User user;

  const UserReportDesktop(this.user, {super.key});

  @override
  UserReportDesktopState createState() => UserReportDesktopState();
}

class UserReportDesktopState extends State<UserReportDesktop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
