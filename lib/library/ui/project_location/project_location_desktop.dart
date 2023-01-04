import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/project.dart';

class ProjectLocationDesktop extends StatefulWidget {
  final Project project;

  ProjectLocationDesktop(this.project);

  @override
  _ProjectLocationDesktopState createState() => _ProjectLocationDesktopState();
}

class _ProjectLocationDesktopState extends State<ProjectLocationDesktop>
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