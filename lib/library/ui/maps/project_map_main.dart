import 'package:flutter/material.dart';

import 'package:responsive_builder/responsive_builder.dart';
import 'package:test_router/library/ui/maps/project_map_desktop.dart';
import 'package:test_router/library/ui/maps/project_map_mobile.dart';
import 'package:test_router/library/ui/maps/project_map_tablet.dart';

import '../../bloc/project_bloc.dart';
import '../../data/photo.dart';
import '../../data/project.dart';
import '../../data/project_position.dart';
import '../../functions.dart';



class ProjectMapMain extends StatefulWidget {
  final Project project;
  final Photo? photo;

  const ProjectMapMain({super.key, required this.project, this.photo});

  @override
  ProjectMapMainState createState() => ProjectMapMainState();
}

class ProjectMapMainState extends State<ProjectMapMain> {
  var isBusy = false;
  var _positions = <ProjectPosition>[];
  final _key = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _getProjectPositions();
  }

  void _getProjectPositions() async {
    setState(() {
      isBusy = true;
    });
    try {
      _positions = await projectBloc.getProjectPositions(
          projectId: widget.project.projectId!, forceRefresh: false);
    } catch (e) {
      pp(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data refresh failed: $e')));
    }
    setState(() {
      isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isBusy
        ? SafeArea(
            child: Scaffold(
              key: _key,
              appBar: AppBar(
                title: Text(
                  'Loading Project locations',
                  style: Styles.whiteTiny,
                ),
              ),
              body: const Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 12,
                    backgroundColor: Colors.black,
                  ),
                ),
              ),
            ),
          )
        : ScreenTypeLayout(
            mobile: ProjectMapMobile(
              project: widget.project,
              projectPositions: _positions,
              photo: widget.photo,
            ),
            tablet: ProjectMapTablet(
              project: widget.project,
              projectPositions: _positions,
            ),
            desktop: ProjectMapDesktop(
              project: widget.project,
              projectPositions: _positions,
            ),
          );
  }
}
