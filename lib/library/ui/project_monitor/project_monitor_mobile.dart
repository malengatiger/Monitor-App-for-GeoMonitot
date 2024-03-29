import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:page_transition/page_transition.dart';
import 'package:test_router/library/ui/camera/field_camera_video.dart';

import '../../bloc/project_bloc.dart';
import '../../functions.dart';
import '../../hive_util.dart';
import '../../data/project.dart';
import '../../data/project_position.dart';
import '../../location/loc_bloc.dart';
import '../camera/field_camera_photo.dart';
import '../project_location/project_location_main.dart';

class ProjectMonitorMobile extends StatefulWidget {
  final Project project;

  const ProjectMonitorMobile({super.key, required this.project});

  @override
  ProjectMonitorMobileState createState() => ProjectMonitorMobileState();
}

///Checks whether the device is within monitoring distance for the project
class ProjectMonitorMobileState extends State<ProjectMonitorMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var isBusy = false;
  final _key = GlobalKey<ScaffoldState>();
  var positions = <ProjectPosition>[];

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getProjectPositions();
  }

  void _getProjectPositions() async {
    setState(() {
      isBusy = true;
    });
    try {
      positions = await projectBloc.getProjectPositions(
          projectId: widget.project.projectId!, forceRefresh: false);
    } catch (e) {
      pp(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Data refresh failed: $e')));
    }

    setState(() {
      widget.project.projectPositions = positions;
      isBusy = false;
    });
    _checkProjectDistance();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          leading: const SizedBox(),
          title: Text(widget.project.organizationName!,
              style: GoogleFonts.lato(
                textStyle: Theme.of(context).textTheme.bodySmall,
                fontWeight: FontWeight.normal,
              )),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _checkProjectDistance,
            ),
            IconButton(
              icon: const Icon(Icons.directions),
              onPressed: _navigateToDirections,
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(200),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(widget.project.name!,
                      style: GoogleFonts.lato(
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        fontWeight: FontWeight.normal,
                      )),
                  const SizedBox(
                    height: 60,
                  ),
                  Text(
                    'The project should be monitored only when the device is within a radius of',
                    style: GoogleFonts.lato(
                      textStyle: Theme.of(context).textTheme.bodySmall,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text('${widget.project.monitorMaxDistanceInMetres}',
                      style: GoogleFonts.secularOne(
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        fontWeight: FontWeight.w900,
                      )),
                  const SizedBox(
                    height: 0,
                  ),
                  const Text('metres'),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  isWithinDistance
                      ? SizedBox(
                          height: 180,
                          child: Column(
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(8),
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).primaryColor)),
                                onPressed: () async {
                                  isWithinDistance =
                                      await _checkProjectDistance();
                                  if (isWithinDistance) {
                                    _startPhotoMonitoring();
                                  } else {
                                    setState(() {});
                                    _showError();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    'Start Photo Monitor',
                                    style: GoogleFonts.lato(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(8),
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).primaryColor)),
                                onPressed: () async {
                                  isWithinDistance =
                                      await _checkProjectDistance();
                                  if (isWithinDistance) {
                                    _startVideoMonitoring();
                                  } else {
                                    setState(() {});
                                    _showError();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    'Start Video Monitor',
                                    style: GoogleFonts.lato(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              TextButton(onPressed: (){
                                Navigator.of(context).pop();
                              }, child: const Text('Cancel')),
                            ],
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 4,
                  ),
                  isBusy
                      ? Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                backgroundColor: Colors.yellowAccent,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Checking project location',
                              style: Styles.blackTiny,
                            )
                          ],
                        )
                      : Container(),
                  const SizedBox(
                    height: 4,
                  ),
                  isWithinDistance
                      ? Text(
                          'We are ready to start creating photos and videos for ${widget.project.name} \n🍎',
                          style: GoogleFonts.lato(
                            textStyle: Theme.of(context).textTheme.bodyMedium,
                            fontWeight: FontWeight.normal,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                'Device is too far from ${widget.project.name} for monitoring capabilities. Please move closer!',
                                style: GoogleFonts.lato(
                                  textStyle: Theme.of(context).textTheme.bodyMedium,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 32,),
                              TextButton(onPressed: (){
                                Navigator.of(context).pop();
                              }, child: const Text('Cancel')),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ignore: missing_return
  Future<ProjectPosition?> _findNearestProjectPosition() async {
    var bags = <BagX>[];
    var positions =
        await hiveUtil.getProjectPositions(widget.project.projectId!);
    if (positions.isEmpty) {
      _navigateToProjectLocation();
    } else {
      if (positions.length == 1) {
        return positions.first;
      }
      for (var pos in positions) {
        var distance = await locationBloc.getDistanceFromCurrentPosition(
            latitude: pos.position!.coordinates[1],
            longitude: pos.position!.coordinates[0]);
        bags.add(BagX(distance, pos));
      }
      bags.sort((a, b) => a.distance.compareTo(b.distance));
    }
    return bags.first.position;
  }

  bool isWithinDistance = false;
  ProjectPosition? nearestProjectPosition;
  static const mm = '🍏 🍏 🍏 ProjectMonitorMobile: 🍏 : ';

  Future<bool> _checkProjectDistance() async {
    pp('$mm _checkProjectDistance ... ');
    setState(() {
      isBusy = true;
    });
    nearestProjectPosition = await _findNearestProjectPosition();
    if (nearestProjectPosition != null) {
      var distance = await locationBloc.getDistanceFromCurrentPosition(
          latitude: nearestProjectPosition!.position!.coordinates[1],
          longitude: nearestProjectPosition!.position!.coordinates[0]);

      pp("$mm App is ${distance.toStringAsFixed(1)} metres from the project point; widget.project.monitorMaxDistanceInMetres: "
          "${widget.project.monitorMaxDistanceInMetres}");
      if (distance > widget.project.monitorMaxDistanceInMetres!) {
        pp("🔆🔆🔆 App is ${distance.toStringAsFixed(1)} metres is greater than allowed project.monitorMaxDistanceInMetres: "
            "🍎 ${widget.project.monitorMaxDistanceInMetres} metres");
        isWithinDistance = false;
      } else {
        isWithinDistance = true;
        pp('🌸 🌸 🌸 The app is within the allowable project.monitorMaxDistanceInMetres of '
            '${widget.project.monitorMaxDistanceInMetres} metres');
      }
      setState(() {
        isBusy = false;
      });
      return isWithinDistance;
    } else {
      pp('$mm _checkProjectDistance ... 🚾 🚾 🚾 WE ARE NOT CLOSE TO THIS PROJECT POSITIONS!');
      isWithinDistance = false;
    }
    setState(() {
      isBusy = false;
    });
    return false;
  }

  void _startPhotoMonitoring() async {
    pp('🍏 🍏 Start Photo Monitoring this project after checking that the device is within '
        ' 🍎 ${widget.project.monitorMaxDistanceInMetres} metres 🍎 of a project point within ${widget.project.name}');
    Navigator.of(context).pop();
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: FieldPhotoCamera(
              project: widget.project,
              projectPosition: nearestProjectPosition!,
            )));
  }

  void _startVideoMonitoring() async {
    pp('🍏 🍏 Start Video Monitoring this project after checking that the device is within '
        ' 🍎 ${widget.project.monitorMaxDistanceInMetres} metres 🍎 of a project point within ${widget.project.name}');
    Navigator.of(context).pop();
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: FieldVideoCamera(
              project: widget.project,
              projectPosition: nearestProjectPosition!,
            )));
  }

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'You are too far from the project for monitoring to work properly')));
    setState(() {
      isBusy = false;
    });
  }

  void _navigateToDirections() async {
    pp('🏖 🍎 🍎 🍎 start Google Maps Directions .....');
    nearestProjectPosition = await _findNearestProjectPosition();
    if (nearestProjectPosition != null) {
      pp('🏖 🍎 🍎 🍎 start Google Maps Directions ..... '
          'nearestProjectPosition: ${nearestProjectPosition!.toJson()}');
      var destination =
          '${nearestProjectPosition!.position!.coordinates[1]},${nearestProjectPosition!.position!.coordinates[0]}';
      var position = await locationBloc.getLocation();
      var origin = '${position.latitude},${position.longitude}';

      final AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: Uri.encodeFull(
              "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving&dir_action=navigate"),
          package: 'com.google.android.apps.maps');
      intent.launch();
    }
  }

  void _navigateToProjectLocation() async {
    pp('🏖 🍎 🍎 🍎 ... _navigateToProjectLocation ....');
    var projectPosition = await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: ProjectLocationMain(widget.project)));
    if (projectPosition != null) {
      if (projectPosition is ProjectPosition) {
        widget.project.projectPositions ??= [];
        widget.project.projectPositions!.add(projectPosition);
        _checkProjectDistance();
      }
    }
  }
}

class BagX {
  double distance;
  ProjectPosition position;

  BagX(this.distance, this.position);
}
