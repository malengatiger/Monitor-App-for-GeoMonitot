import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/project.dart';

class ProjectEditDesktop extends StatefulWidget {
  final Project? project;

  ProjectEditDesktop(this.project);

  @override
  _ProjectEditDesktopState createState() => _ProjectEditDesktopState();
}

class _ProjectEditDesktopState extends State<ProjectEditDesktop>
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
