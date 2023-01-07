import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:page_transition/page_transition.dart';

import '../../../api/sharedprefs.dart';
import '../../../bloc/monitor_bloc.dart';
import '../../../data/user.dart';
import '../../../data/video.dart';
import '../../../functions.dart';
import '../../../snack.dart';
import '../../../data/photo.dart';
import '../../../data/project.dart';
import '../../project_monitor/project_monitor_mobile.dart';
import '../full_photo/full_photo_main.dart';
import '../video/video_main.dart';
import 'media_grid.dart';

class MediaListMobile extends StatefulWidget {
  final Project project;

  const MediaListMobile(this.project, {super.key});

  @override
  MediaListMobileState createState() => MediaListMobileState();
}

class MediaListMobileState extends State<MediaListMobile>
    with SingleTickerProviderStateMixin
    implements MediaGridListener {
  late AnimationController _controller;
  StreamSubscription<List<Photo>>? photoStreamSubscription;
  StreamSubscription<List<Video>>? videoStreamSubscription;
  var _photos = <Photo>[];
  var _videos = <Video>[];
  User? user;
  static const mm = '🔆🔆🔆 MediaListMobile 💜💜 ';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
  }

  void _listen() async {
    pp('$mm .................... Listening to streams from monitorBloc ....');
    user = await Prefs.getUser();

    photoStreamSubscription = monitorBloc.projectPhotoStream.listen((value) {
      pp('$mm Photos received from stream projectPhotoStream: 💙 ${value.length}');
      _photos = value;
      _processMedia();
      if (mounted) {
        setState(() {});
      }
    });

    videoStreamSubscription = monitorBloc.projectVideoStream.listen((value) {
      pp('$mm:Videos received from projectVideoStream: 🏈 ${value.length}');
      _videos = value;
      _processMedia();
      if (mounted) {
        setState(() {});
      }
    });

    if (mounted) {
      _refresh(false);
    }
  }

  Future<void> _refresh(bool forceRefresh) async {
    pp('$mm _MediaListMobileState: .......... _refresh ...');
    setState(() {
      isBusy = true;
    });
    try {
      await monitorBloc.refreshProjectData(
          projectId: widget.project.projectId!, forceRefresh: forceRefresh);
      _processMedia();
    } catch (e) {
      pp(e);
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _key, message: 'Data refresh failed: $e');
    }
    setState(() {
      isBusy = false;
    });
  }

  final _key = GlobalKey<ScaffoldState>();
  @override
  void dispose() {
    _controller.dispose();
    photoStreamSubscription!.cancel();
    videoStreamSubscription!.cancel();
    super.dispose();
  }

  void _processMedia() {
    pp('$mm _processMedia: create suitcases to hold photos and videos ...');
    _suitcases.clear();
    for (var element in _photos) {
      var sc = MediaBag(photo: element, date: element.created!);
      _suitcases.add(sc);
    }
    for (var element in _videos) {
      var sc = MediaBag(video: element, date: element.created!);
      _suitcases.add(sc);
    }
    if (_suitcases.isNotEmpty) {
      _suitcases.sort((a, b) => b.date!.compareTo(a.date!));
      latest = getFormattedDateShortest(_suitcases.first.date!, context);
      earliest = getFormattedDateShortest(_suitcases.last.date!, context);
    }
    pp('$mm _processMedia: created : ${_suitcases.length} suitcases');
    setState(() {

    });
  }

  String? latest, earliest;

  @override
  Widget build(BuildContext context) {
    return SafeArea(

        body: Stack(
          children: [
            _suitcases.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 120,
                        ),
                        Text(
                          'No Monitor Reports yet',
                          style: Styles.blackBoldMedium,
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        Card(
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: IconButton(
                                icon: const Icon(Icons.add_a_photo),
                                onPressed: _navigateToMonitor),
                          ),
                        )
                      ],
                    ),
                  )
                : MediaGrid(
                    imageList: _suitcases,
                    mediaGridListener: this,
                  )
          ],
        ),
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Container(),
          elevation: 16,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh,
                size: 20,
              ),
              onPressed: () {
                _refresh(true);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.add_a_photo,
                size: 20,
              ),
              onPressed: _navigateToMonitor,
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    widget.project.name == null ? '' : widget.project.name!,
                  style: GoogleFonts.lato(
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      fontWeight: FontWeight.w900)),

                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                backgroundColor: Colors.black,
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        width: 28,
                      ),
                      Text(
                        'Photos & Videos',
                        style: Styles.blackTiny,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '${_suitcases.length}',
                        style: Styles.whiteBoldSmall,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  // _suitcases.isEmpty
                  //     ? Container()
                  //     : Row(
                  //         children: [
                  //           Text(
                  //             'Latest:',
                  //             style: Styles.blackTiny,
                  //           ),
                  //           SizedBox(
                  //             width: 8,
                  //           ),
                  //           Text(
                  //             latest == null ? 'some date' : latest,
                  //             style: Styles.whiteBoldSmall,
                  //           ),
                  //           SizedBox(
                  //             width: 28,
                  //           ),
                  //           Text(
                  //             'Earliest:',
                  //             style: Styles.blackTiny,
                  //           ),
                  //           SizedBox(
                  //             width: 8,
                  //           ),
                  //           Text(
                  //             earliest == null ? 'some date' : earliest,
                  //             style: Styles.whiteBoldSmall,
                  //           )
                  //         ],
                  //       ),
                  // SizedBox(
                  //   height: 12,
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final _suitcases = <MediaBag>[];

  @override
  void onMediaSelected(MediaBag suitcase) {
    if (suitcase.video != null) {
      pp('MediaListMobile: 🦠 🦠 🦠 _onMediaTapped: Play video from 🦠 ${suitcase.video!.url} 🦠');
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.bottomRight,
              duration: const Duration(seconds: 1),
              child: VideoMain(suitcase.video!)));
    } else {
      pp('MediaListMobile: 🦠 🦠 🦠 _onMediaTapped: show full image from 🍎 ${suitcase.photo!.url} 🍎');
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.bottomRight,
              duration: const Duration(seconds: 1),
              child: FullPhotoMain(suitcase.photo!, widget.project)));
    }
  }

  void _navigateToMonitor() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1500),
            child: ProjectMonitorMobile(widget.project)));
  }

}

class MediaBag {
  Photo? photo;
  Video? video;
  String? date;

  MediaBag({this.photo, this.video, required this.date});
}
