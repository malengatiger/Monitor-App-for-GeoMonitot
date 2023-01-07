import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:test_router/library/data/field_monitor_schedule.dart';
import 'package:test_router/library/data/project_position.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../library/api/sharedprefs.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/monitor_bloc.dart';
import '../../library/bloc/theme_bloc.dart';
import '../../library/data/org_message.dart';
import '../../library/data/photo.dart';
import '../../library/data/project.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import '../../library/geofence/geofencer_two.dart';
import '../../library/snack.dart';
import '../../library/ui/media/user_media_list/user_media_list_main.dart';
import '../../library/ui/message/message_main.dart';
import '../../library/ui/project_list/project_list_mobile.dart';
import '../../library/users/list/user_list_main.dart';
import '../intro/intro_mobile.dart';
import '../schedules/schedules_list_main.dart';

class DashboardMobile extends StatefulWidget {
  final User user;
  const DashboardMobile({Key? key, required this.user}) : super(key: key);

  @override
  DashboardMobileState createState() => DashboardMobileState();
}

class DashboardMobileState extends State<DashboardMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var isBusy = false;
  var _projects = <Project>[];
  var _users = <User>[];
  var _photos = <Photo>[];
  var _videos = <Video>[];
  var _projectPositions = <ProjectPosition>[];
  var _schedules = <FieldMonitorSchedule>[];
  User? user;

  late StreamSubscription<ConnectivityResult> subscription;

  static const nn = '🎽🎽🎽🎽🎽🎽 DashboardMobile: 🎽';
  static const mm = '🎽🎽🎽🎽🎽🎽 DashboardMobile: 🎽';
  bool networkAvailable = false;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setItems();
    _listenToStreams();
    _listenForFCM();
    _refreshData(false);
    _subscribeToConnectivity();
    _buildGeofences();
  }

  void _buildGeofences() async {
    pp('\n\n$nn _buildGeofences starting ........................');
    await geofencerTwo.buildGeofences();
    pp('$nn _buildGeofences done.\n');
  }

  void _subscribeToConnectivity() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      pp('$nn onConnectivityChanged: result index: ${result.index}');
      if (result.index == ConnectivityResult.mobile.index) {
        pp('$nn ConnectivityResult.mobile.index: ${result.index} - 🍎 MOBILE NETWORK is on!');
        networkAvailable = true;
      }
      if (result.index == ConnectivityResult.wifi.index) {
        pp('$nn ConnectivityResult.wifi.index:  ${result.index} - 🍎 WIFI is on!');
        networkAvailable = true;
      }
      if (result.index == ConnectivityResult.none.index) {
        pp('ConnectivityResult.none.index: ${result.index} = 🍎 NONE - AIRPLANE MODE?');
        networkAvailable = false;
      }
      setState(() {});
    });
  }

  void _listenToStreams() async {
    geofencerTwo.geofenceStream.listen((event) {
      pp('\n$nn geofenceEvent delivered by geofenceStream: ${event.projectName} ...');
      if (mounted) {
        showToast(
            message:
                'Geofence triggered: ${event.projectName} projectPositionId: ${event.projectPositionId}',
            context: context);
      }
    });
    monitorBloc.projectStream.listen((event) {
      if (mounted) {
        setState(() {
          _projects = event;
          pp('$nn projects delivered by stream: ${_projects.length} ...');
        });
      }
    });
    monitorBloc.usersStream.listen((event) {
      if (mounted) {
        setState(() {
          _users = event;
          pp('$mm users delivered by stream: ${_users.length} ...');
        });
      }
    });
    monitorBloc.photoStream.listen((event) {
      if (mounted) {
        setState(() {
          _photos = event;
          pp('$mm photos delivered by stream: ${_photos.length} ...');
        });
      }
    });
    monitorBloc.videoStream.listen((event) {
      if (mounted) {
        setState(() {
          _videos = event;
          pp('$mm videos delivered by stream: ${_videos.length} ...');
        });
      }
    });
    monitorBloc.projectPositionsStream.listen((event) {
      if (mounted) {
        setState(() {
          _projectPositions = event;
          pp('$mm projectPositions delivered by stream: ${_projectPositions.length} ...');
        });
      }
    });
    monitorBloc.fieldMonitorScheduleStream.listen((event) {
      if (mounted) {
        setState(() {
          _schedules = event;
          pp('$mm fieldMonitorSchedules delivered by stream: ${_schedules.length} ...');
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    subscription.cancel();
    super.dispose();
  }

  var items = <BottomNavigationBarItem>[];

  void _setItems() {
    // items
    //     .add(BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'));
    items.add(const BottomNavigationBarItem(
        icon: Icon(
          Icons.home,
        ),
        label: 'Projects'));
    items.add(const BottomNavigationBarItem(
        icon: Icon(
          Icons.person,
          color: Colors.pink,
        ),
        label: 'My Work'));
    items.add(const BottomNavigationBarItem(
        icon: Icon(
          Icons.send,
          color: Colors.blue,
        ),
        label: 'Send Message'));
  }

  void _refreshData(bool forceRefresh) async {
    pp('$mm ............... Refresh data ....');
    setState(() {
      isBusy = true;
    });
    try {
      user = await Prefs.getUser();
      //todo what kind of user is this? if monitor or admin or executive
      if (user != null) {
        switch (user!.userType) {
          case UserType.orgAdministrator:
            monitorBloc.refreshOrganizationData(
                organizationId: user!.organizationId!, forceRefresh: true);
            break;
          case UserType.fieldMonitor:
            monitorBloc.refreshUserData(
                userId: user!.userId!,
                organizationId: user!.organizationId!,
                forceRefresh: forceRefresh);
            break;
          case UserType.orgExecutive:
            monitorBloc.refreshOrganizationData(
                organizationId: user!.organizationId!, forceRefresh: true);
            break;
        }
      }
    } catch (e) {
      pp(e);
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _key, message: 'Dashboard refresh failed: $e');
    }
    setState(() {
      isBusy = false;
    });
  }

  void _listenForFCM() async {
    var android = UniversalPlatform.isAndroid;
    var ios = UniversalPlatform.isIOS;

    if (android || ios) {
      pp('DashboardMobile: 🍎 🍎 _listen to FCM message streams ... 🍎 🍎');
      fcmBloc.projectStream.listen((Project project) async {
        if (mounted) {
          pp('DashboardMobile: 🍎 🍎 showProjectSnackbar: ${project.name} ... 🍎 🍎');
          _projects = await monitorBloc.getOrganizationProjects(
              organizationId: user!.organizationId!, forceRefresh: false);
          setState(() {});
          // SpecialSnack.showProjectSnackbar(
          //     scaffoldKey: _key,
          //     textColor: Colors.white,
          //     backgroundColor: Theme.of(context).primaryColor,
          //     project: project,
          //     listener: this);
        }
      });

      fcmBloc.userStream.listen((User user) async {
        if (mounted) {
          pp('DashboardMobile: 🍎 🍎 showUserSnackbar: ${user.name} ... 🍎 🍎');
          _users = await monitorBloc.getOrganizationUsers(
              organizationId: user.organizationId!, forceRefresh: false);
          setState(() {});
          // SpecialSnack.showUserSnackbar(
          //     scaffoldKey: _key, user: user, listener: this);
        }
      });

      fcmBloc.messageStream.listen((OrgMessage message) {
        if (mounted) {
          pp('DashboardMobile: 🍎 🍎 showMessageSnackbar: ${message.message} ... 🍎 🍎');

          // SpecialSnack.showMessageSnackbar(
          //     scaffoldKey: _key, message: message, listener: this);
        }
      });
    } else {
      pp('App is running on the Web 👿 👿 👿  firebase messaging is OFF 👿 👿 👿');
    }
  }
  final _key = GlobalKey<ScaffoldState>();

  void _handleBottomNav(int value) {
    switch (value) {
      case 0:
        pp(' 🔆🔆🔆 Navigate to MonitorList');
        _navigateToProjectList();
        break;

      case 1:
        pp(' 🔆🔆🔆 Navigate to ScheduleList');
        _navigateToScheduleList();
        break;

      case 2:
        pp(' 🔆🔆🔆 Navigate to MessageSender');
        _navigateToMessageSender();
        break;
    }
  }

  void _navigateToProjectList() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: ProjectListMobile(widget.user)));
  }

  void _navigateToMessageSender() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: MessageMain(user: user)));
  }

  void _navigateToMediaList() {
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child: UserMediaListMain(user!)));
    }
  }

  void _navigateToScheduleList() {
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child: const SchedulesListMain()));
    }
  }

  void _navigateToIntro() {
    pp('$mm _navigateToIntro to Intro ....');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child: IntroMobile(
                user: widget.user,
              )));
    }
  }

  void _navigateToUserList() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: const UserListMain()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(
          'Digital Monitor',
          style: Styles.whiteTiny,
        ),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.info_outline,
                size: 20,
              ),
              onPressed: _navigateToIntro),
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 20,
            ),
            onPressed: () {
              themeBloc.changeToRandomTheme();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              size: 20,
            ),
            onPressed: () {
              _refreshData(true);
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  widget.user.organizationName!,
                  style: Styles.whiteBoldSmall,
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(
                   widget.user.name!,
                  style: Styles.whiteBoldMedium,
                ),
                user == null? const Text(''):Text(user!.userType!, style: Styles.whiteTiny),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
      // backgroundColor: Colors.brown[100],
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        onTap: _handleBottomNav,elevation: 8,
      ),
      body: isBusy
          ? const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  backgroundColor: Colors.amber,
                ),
              ),
            )
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    children: [
                      GestureDetector(
                        onTap: _navigateToProjectList,
                        child: Card(
                          // color: Colors.brown[50],
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 32,
                              ),
                              Text(
                                '${_projects.length}',
                                  style: GoogleFonts.secularOne(
                                      textStyle: Theme.of(context).textTheme.headline4,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Projects',
                                style: Styles.greyLabelSmall,
                              )
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToUserList,
                        child: Card(
                          // color: Colors.brown[50],
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 32,
                              ),
                              Text(
                                '${_users.length}',
                                style: GoogleFonts.secularOne(
                                    textStyle: Theme.of(context).textTheme.headline4,
                                    fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Users',
                                style: Styles.greyLabelSmall,
                              )
                            ],
                          ),
                        ),
                      ),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 32,
                            ),
                            Text(
                              '${_photos.length}',
                              style: GoogleFonts.secularOne(
                                  textStyle: Theme.of(context).textTheme.headline4,
                                  fontWeight: FontWeight.w900)),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Photos',
                              style: Styles.greyLabelSmall,
                            )
                          ],
                        ),
                      ),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 32,
                            ),
                            Text(
                              '${_videos.length}',
                                style: GoogleFonts.secularOne(
                                    textStyle: Theme.of(context).textTheme.headline4,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Videos',
                              style: Styles.greyLabelSmall,
                            )
                          ],
                        ),
                      ),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 32,
                            ),
                            Text(
                                '${_projectPositions.length}',
                                style: GoogleFonts.secularOne(
                                    textStyle: Theme.of(context).textTheme.headline4,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Locations',
                              style: Styles.greyLabelSmall,
                            )
                          ],
                        ),
                      ),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 32,
                            ),
                            Text(
                                '${_schedules.length}',
                                style: GoogleFonts.secularOne(
                                    textStyle: Theme.of(context).textTheme.headline4,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Schedules',
                              style: Styles.greyLabelSmall,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    ));
  }


}
