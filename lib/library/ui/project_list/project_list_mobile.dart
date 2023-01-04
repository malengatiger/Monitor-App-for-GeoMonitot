import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:geo_monitor/library/api/sharedprefs.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/bloc/monitor_bloc.dart';
import 'package:geo_monitor/library/data/project.dart';
import 'package:geo_monitor/library/data/user.dart';
import 'package:geo_monitor/library/data/user.dart' as mon;
import 'package:geo_monitor/library/functions.dart';
import 'package:geo_monitor/library/ui/maps/org_map_mobile.dart';
import 'package:geo_monitor/library/ui/maps/project_map_mobile.dart';
import 'package:geo_monitor/library/ui/media/list/media_list_main.dart';
import 'package:geo_monitor/library/ui/project_edit/project_edit_main.dart';
import 'package:geo_monitor/library/ui/project_edit/project_edit_mobile.dart';
import 'package:geo_monitor/library/ui/project_location/project_location_main.dart';
import 'package:geo_monitor/library/ui/project_monitor/project_monitor_main.dart';
import 'package:geo_monitor/library/ui/project_monitor/project_monitor_mobile.dart';
import 'package:page_transition/page_transition.dart';

import '../../hive_util.dart';
import '../../snack.dart';

class ProjectListMobile extends StatefulWidget {
  final mon.User user;

  const ProjectListMobile(this.user, {super.key});

  @override
  ProjectListMobileState createState() => ProjectListMobileState();
}

class ProjectListMobileState extends State<ProjectListMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var projects = <Project>[];
  mon.User? user;
  bool isBusy = false;
  bool isProjectsByLocation = false;
  var userTypeLabel = 'Unknown User Type';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    user = widget.user;
    if (user == null) {
      _getUser();
    } else {
      _setUserType();
    }
    _listen();
    refreshProjects(false);
  }

  void _listen() {
    fcmBloc.projectStream.listen((Project project) {
      if (mounted) {
        AppSnackbar.showSnackbar(
            scaffoldKey: _key,
            message: 'Project added: ${project.name}',
            textColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor);
      }
    });
  }

  void _getUser() async {
    setState(() {
      isBusy = true;
    });
    user = await Prefs.getUser();
    _setUserType();
    setState(() {
      isBusy = false;
    });
  }

  void _setUserType() {
    setState(() {
      switch (user!.userType) {
        case FIELD_MONITOR:
          userTypeLabel = 'Field Monitor';
          break;
        case ORG_ADMINISTRATOR:
          userTypeLabel = 'Team Administrator';
          break;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future refreshProjects(bool forceRefresh) async {
    if (isBusy) return;

    if (mounted) {
      setState(() {
        isBusy = true;
      });
    }
    try {
      if (isProjectsByLocation) {
        pp('ProjectListMobile  🥏 🥏 🥏 getProjectsWithinRadius: $sliderValue km  🥏');
        projects = await monitorBloc.getProjectsWithinRadius(
            radiusInKM: sliderValue, checkUserOrg: true);
      } else {
        projects = await monitorBloc.getOrganizationProjects(
            organizationId: user!.organizationId!, forceRefresh: forceRefresh);
      }
    } catch (e) {
      print(e);
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _key, message: 'Data refresh failed: $e');
    }
    if (mounted) {
      setState(() {
        isBusy = false;
      });
    }
  }

  Project? _currentProject;
  bool openProjectActions = false;
  void _navigateToDetail(Project? p) {
    if (user!.userType == FIELD_MONITOR) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1500),
              child: ProjectEditMobile(p)));
    }
    if (user!.userType! == ORG_ADMINISTRATOR) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1500),
              child: ProjectEditMain(p)));
    }
  }

  void _navigateToProjectLocation(Project p) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1500),
            child: ProjectLocationMain(p)));
  }

  void _navigateToMedia(Project p) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1500),
            child: MediaListMain(p)));
  }

  Future<void> _navigateToOrgMap() async {
    pp('_navigateToOrgMap: ');

    var org = await hiveUtil.getOrganizationById(organizationId: widget.user.organizationId!);
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: OrganizationMapMobile(organization: org!,)));
    }

  }
  void _navigateToProjectMap(Project p) async {
    pp('_navigateToProjectMap: ');
    var pos = await hiveUtil.getProjectPositions(p.projectId!);
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: ProjectMapMobile(project: p, projectPositions: pos,)));
    }

  }

  List<FocusedMenuItem> getPopUpMenuItems(Project p) {
    List<FocusedMenuItem> menuItems = [];
    menuItems.add(
      FocusedMenuItem(
          title: Text('Project Map'),
          trailingIcon: Icon(
            Icons.map,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            _navigateToProjectMap(p);
          }),
    );
    menuItems.add(
      FocusedMenuItem(
          title: Text('Photos & Videos'),
          trailingIcon: Icon(
            Icons.camera,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            _navigateToMedia(p);
          }),
    );
    if (user!.userType == ORG_ADMINISTRATOR) {
      menuItems.add(FocusedMenuItem(
          title: Text('Add Project Location'),
          trailingIcon: Icon(
            Icons.location_pin,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            _navigateToProjectLocation(p);
          }));
    }
    if (user!.userType == ORG_ADMINISTRATOR) {
      menuItems.add(FocusedMenuItem(
          title: Text('Edit Project'),
          trailingIcon: Icon(
            Icons.create,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            _navigateToDetail(p);
          }));
    }
    return menuItems;
  }

  final _key = GlobalKey<ScaffoldState>();
  List<IconButton> _getActions() {
    List<IconButton> list = [];
    // list.add(IconButton(
    //   icon: Icon(Icons.settings),
    //   onPressed: () {
    //     themeBloc.changeToRandomTheme();
    //   },
    // ));
    list.add(IconButton(
      icon: isProjectsByLocation
          ? Icon(
              Icons.list,
              size: 24,
            )
          : Icon(
              Icons.location_pin,
              size: 20,
            ),
      onPressed: () {
        isProjectsByLocation = !isProjectsByLocation;
        refreshProjects(true);
      },
    ));
    if (projects.isNotEmpty) {
      list.add(
        IconButton(
          icon: Icon(Icons.map),
          onPressed: () {
           _navigateToOrgMap();
          },
        ),
      );
    }
    if (user!.userType == ORG_ADMINISTRATOR) {
      list.add(
        IconButton(
          icon: Icon(
            Icons.add,
            size: 20,
          ),
          onPressed: () {
            _navigateToDetail(null);
          },
        ),
      );
      // list.add(
      //   IconButton(
      //     icon: Icon(
      //       Icons.location_pin,
      //       size: 20,
      //     ),
      //     onPressed: () {
      //       _navigateToDetail(null);
      //     },
      //   ),
      // );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<Project>>(
          stream: monitorBloc.projectStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              projects = snapshot.data!;
            }
            return Scaffold(
                key: _key,
                appBar: AppBar(
                  title: Text(
                    'Projects',
                    style: Styles.whiteTiny,
                  ),
                  actions: _getActions(),
                  bottom: PreferredSize(
                    preferredSize:
                        Size.fromHeight(isProjectsByLocation ? 160 : 120),
                    child: Column(
                      children: [
                        Text(
                          user == null ? 'Unknown User' : user!.organizationName!,
                          style: Styles.blackBoldSmall,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Text(
                          user == null ? '' : '${user!.name}',
                          style: Styles.whiteSmall,
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          '$userTypeLabel',
                          style: Styles.blackTiny,
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            isProjectsByLocation
                                ? Row(
                                    children: [
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor: Colors.pink[700],
                                          inactiveTrackColor: Colors.pink[100],
                                          trackShape:
                                              const RoundedRectSliderTrackShape(),
                                          trackHeight: 4.0,
                                          thumbShape: const RoundSliderThumbShape(
                                              enabledThumbRadius: 12.0),
                                          thumbColor: Colors.pinkAccent,
                                          overlayColor:
                                              Colors.pink.withAlpha(32),
                                          overlayShape: const RoundSliderOverlayShape(
                                              overlayRadius: 28.0),
                                          tickMarkShape:
                                              const RoundSliderTickMarkShape(),
                                          activeTickMarkColor: Colors.pink[700],
                                          inactiveTickMarkColor:
                                              Colors.pink[100],
                                          valueIndicatorShape:
                                              PaddleSliderValueIndicatorShape(),
                                          valueIndicatorColor:
                                              Colors.pinkAccent,
                                          valueIndicatorTextStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        child: Slider(
                                          value: sliderValue,
                                          min: 10,
                                          max: 50,
                                          divisions: 5,
                                          label: '$sliderValue',
                                          onChanged: _onSliderChanged,
                                        ),
                                      ),
                                      // SizedBox(
                                      //   width: 8,
                                      // ),
                                      Text(
                                        '$sliderValue',
                                        style: Styles.whiteBoldSmall,
                                      )
                                    ],
                                  )
                                : Container(),
                            const SizedBox(
                              width: 24,
                            ),
                            Text(
                              'Projects',
                              style: Styles.blackTiny,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              '${projects.length}',
                              style: Styles.whiteBoldSmall,
                            ),
                            const SizedBox(
                              width: 24,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                backgroundColor: Colors.brown[100],
                body: isBusy
                    ? Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 100,
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                strokeWidth: 8,
                                backgroundColor: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(isProjectsByLocation
                                ? 'Finding Projects within $sliderValue KM'
                                : 'Finding Organization Projects'),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: projects.isEmpty
                            ? Center(
                                child: Text(
                                  'Projects Not Found',
                                  style: Styles.blackBoldMedium,
                                ),
                              )
                            : Stack(
                                children: [
                                  ListView.builder(
                                    itemCount: projects.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var selectedProject =
                                          projects.elementAt(index);

                                      return FocusedMenuHolder(
                                        menuOffset: 20,
                                        duration: const Duration(milliseconds: 300),
                                        menuItems:
                                            getPopUpMenuItems(selectedProject),
                                        animateMenuItems: true,
                                        openWithTap: true,
                                        onPressed: () {
                                          pp('.... 💛️ 💛️ 💛️ not sure what I pressed ...');
                                        },
                                        child: Card(
                                          elevation: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 12,
                                                ),
                                                Row(
                                                  children: [
                                                    Opacity(
                                                      opacity: 0.5,
                                                      child: Icon(
                                                        Icons.water_damage,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        selectedProject.name!,
                                                        style: Styles
                                                            .blackBoldSmall,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 12,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )));
          }),
    );
  }

  double sliderValue = 10.0;
  void _onSliderChanged(double value) {
    pp('ProjectListMobile  🥏 🥏 🥏 🥏 🥏 _onSliderChanged: $value');
    setState(() {
      sliderValue = value;
    });

    refreshProjects(false);
  }

  @override
  onClose() {
    ScaffoldMessenger.of(_key.currentState!.context).removeCurrentSnackBar();
  }
}
