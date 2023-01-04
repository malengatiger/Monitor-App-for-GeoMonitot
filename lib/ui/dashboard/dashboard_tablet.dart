import 'package:flutter/material.dart';
import '../../library/data/user.dart';

class DashboardTablet extends StatefulWidget {
  final User user;
  DashboardTablet({Key? key, required this.user}) : super(key: key);

  @override
  _DashboardTabletState createState() => _DashboardTabletState();
}

class _DashboardTabletState extends State<DashboardTablet>
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