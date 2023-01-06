import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:uuid/uuid.dart';

import '../../api/data_api.dart';

import '../../api/sharedprefs.dart';
import '../../bloc/monitor_bloc.dart';
import '../../data/city.dart';
import '../../data/place_mark.dart';
import '../../data/position.dart' as mon;

import '../../functions.dart';
import '../../data/project.dart';
import '../../data/project_position.dart';
import '../../location/loc_bloc.dart';

class ProjectLocationMobile extends StatefulWidget {
  final Project project;

  const ProjectLocationMobile(this.project, {super.key});

  @override
  ProjectLocationMobileState createState() => ProjectLocationMobileState();
}

class ProjectLocationMobileState extends State<ProjectLocationMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var isBusy = false;
  List<ProjectPosition> _projectPositions = [];
  final _key = GlobalKey<ScaffoldState>();
  static const mx = '💙 💙 💙 ProjectLocation Mobile: 💙 : ';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getLocation();
    _getProjectPositions(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _isLocationWithinProjectMonitorDistance() async {
    pp('$mx calculating _isLocationWithinProjectMonitorDistance .... '
        '${widget.project.monitorMaxDistanceInMetres!} metres');
    var map = <double, ProjectPosition>{};
    for (var i = 0; i < _projectPositions.length; i++) {
      var projPos = _projectPositions.elementAt(i);
      var dist = await locationBloc.getDistanceFromCurrentPosition(
          latitude: projPos.position!.coordinates.elementAt(1),
          longitude: projPos.position!.coordinates.elementAt(0));

      map[dist] = projPos;
      pp('$mx Distance: 🌶 $dist metres 🌶 projectId: ${projPos.projectId} 🐊 projectPositionId: ${projPos.projectPositionId}');
    }
    if (map.isEmpty) {
      return false;
    }
    var list = map.keys.toList();
    list.sort();
    if (list.elementAt(0) < widget.project.monitorMaxDistanceInMetres!.toInt()) {
      return true;
    } else {
      return false;
    }
  }

  void _getProjectPositions(bool forceRefresh) async {
    try {
      _projectPositions = await monitorBloc.getProjectPositions(
          projectId: widget.project.projectId!, forceRefresh: forceRefresh);
      pp('$mx _projectPositions found: ${_projectPositions.length}; checking location within project monitorDistance...');
      _isLocationWithinProjectMonitorDistance();
    } catch (e) {
      pp(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data refresh failed: $e')));
    }
  }

  void _submit() async {
    await _getLocation();
    var isWithin = await _isLocationWithinProjectMonitorDistance();
    if (isWithin) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
            'This location is already recorded for ${widget.project.name}')));
      }
      return;
    }

    List<Placemark> placeMarks =
        await placemarkFromCoordinates(_position!.latitude, _position!.longitude);
    List<City> cities = await DataAPI.findCitiesByLocation(
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        radiusInKM: 10.0);
    pp('$mx Cities found for project position: ${cities.length}');

    if (_position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Current Location not available')));
      }
      return;
    }
    setState(() {
      isBusy = true;
    });
    try {
      pp('$mx submitting current position ..........');
      Placemark? pm;
      if (placeMarks.isNotEmpty) {
        pm = placeMarks.first;
        pp('$mx Placemark for project location: ${pm.toString()}');
      }
      var org = await Prefs.getUser();
      var loc = ProjectPosition(
          placemark: pm == null? null: PlaceMark.getPlaceMark(placemark: pm),
          projectName: widget.project.name,
          caption: 'tbd',
          organizationId: org!.organizationId,
          created: DateTime.now().toIso8601String(),
          position: mon.Position(
              type: 'Point',
              coordinates: [_position!.longitude, _position!.latitude]),
          projectId: widget.project.projectId,
          nearestCities: cities, projectPositionId: const Uuid().v4());
      try {
        var m = await DataAPI.addProjectPosition(position: loc);
        pp('$mx  _submit: new projectPosition added .........  🍅 ${m.toJson()} 🍅');
        await monitorBloc.getProjectPositions(
            projectId: widget.project.projectId!, forceRefresh: true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Project Position failed: $e')));
        }
      }
      setState(() {
        isBusy = false;
      });
      if (mounted) {
        Navigator.pop(context, loc);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e')));
      }

    }
  }

  Position? _position;

  Future _getLocation() async {
    setState(() {
      isBusy = true;
    });
    _position = await locationBloc.getLocation();
    setState(() {
      isBusy = false;
    });
    pp('🎽 🎽 🎽 _submit: current location found: .........  🍅 ${_position!.toJson()} 🍅');
    return _position;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(
            'Project Locations',
            style: Styles.whiteSmall,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(200),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    '${widget.project.name}',
                    style: Styles.blackBoldMedium,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    'Add a Project Location at this location that you are at. This location will be enabled for monitoring',
                    style: Styles.whiteSmall,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.brown[100],
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0)),
            child: Column(
              children: [
                const SizedBox(
                  height: 12,
                ),
                _position == null
                    ? Container()
                    : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Current Location',
                            style: Styles.greyLabelMedium,
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          Row(
                            children: [
                               SizedBox(width: 80,
                                 child: Text('Latitude', style: GoogleFonts.lato(
                                    textStyle: Theme.of(context).textTheme.bodyMedium, fontWeight: FontWeight.normal),),
                               ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                _position!.latitude.toStringAsFixed(6),
                                  style: GoogleFonts.secularOne(
                                      textStyle: Theme.of(context).textTheme.headline6,
                                      fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                               SizedBox(width: 80,
                                 child: Text('Longitude', style: GoogleFonts.lato(
                                    textStyle: Theme.of(context).textTheme.bodyMedium, fontWeight: FontWeight.normal),),
                               ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                _position!.longitude.toStringAsFixed(6),
                                style: GoogleFonts.lato(
                                    textStyle: Theme.of(context).textTheme.headline6,
                                    fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                const SizedBox(
                  height: 48,
                ),
                isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          backgroundColor: Colors.black,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _submit,

                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 12, bottom: 12),
                          child: Text(
                            'Add Project Location',
                            style: Styles.whiteSmall,
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 48,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
