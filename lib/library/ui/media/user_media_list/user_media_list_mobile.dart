import 'dart:async';

import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';

import '../../../bloc/user_bloc.dart';
import '../../../data/video.dart';
import '../../../data/photo.dart';
import '../../../data/user.dart';

import '../../../functions.dart';
import '../../../generic_functions.dart';
import '../../../snack.dart';
import '../video/video_main.dart';

class UserMediaListMobile extends StatefulWidget {
  final User user;

  const UserMediaListMobile(this.user, {super.key});

  @override
  UserMediaListMobileState createState() => UserMediaListMobileState();
}

class UserMediaListMobileState extends State<UserMediaListMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  StreamSubscription<List<Photo>>? photoStreamSubscription;
  StreamSubscription<List<Video>>? videoStreamSubscription;

  var _photos = <Photo>[];
  var _videos = <Video>[];

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _refresh();
  }

  void _listen() async {
    pp('🔆 🔆 🔆 🔆 💜 💜 💜 Listening to streams from monitorBloc ....');

    photoStreamSubscription = userBloc.photoStream.listen((value) {
      pp('🔆 🔆 🔆 💜 💜 _MediaListMobileState: Photos from stream controller: 💙 ${value.length}');
      _photos = value;
      _processMedia();
      setState(() {});
    });
    videoStreamSubscription = userBloc.videoStream.listen((value) {
      pp('🔆 🔆 🔆 💜 💜 _MediaListMobileState: Videos from stream controller: 🏈 ${value.length}');
      _videos = value;
      _processMedia();
      setState(() {});
    });
    _refresh();
  }

  Future<void> _refresh() async {
    pp('🔆🔆🔆 💜 💜 _MediaListMobileState: _refresh ...');
    setState(() {
      isBusy = true;
    });
    try {
      _photos = await userBloc.getPhotos(
          userId: widget.user.userId!, forceRefresh: true);
      _videos = await userBloc.getVideos(
          userId: widget.user.userId!, forceRefresh: true);
      _processMedia();
    } catch (e) {
      p(e);
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
    suitcases.clear();
    for (var photo in _photos) {
      var sc = Suitcase(photo: photo, date: photo.created!);
      suitcases.add(sc);
    }
    for (var video in _videos) {
      var sc = Suitcase(video: video, date: video.created!);
      suitcases.add(sc);
    }
    if (suitcases.isNotEmpty) {
      suitcases.sort((a, b) => b.date!.compareTo(a.date!));
      latest = getFormattedDateShortest(suitcases.first.date!, context);
      earliest = getFormattedDateShortest(suitcases.last.date!, context);
    }
  }

  String? latest, earliest;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(
            widget.user.name!,
            style: Styles.whiteBoldSmall,
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh,
                size: 20,
              ),
              onPressed: _refresh,
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 8,
                                backgroundColor: Colors.black,
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        width: 28,
                      ),
                      Text(
                        'Digital Project Monitor',
                        style: Styles.whiteSmall,
                      ),
                      const SizedBox(
                        width: 64,
                      ),
                      Text(
                        '${suitcases.length}',
                        style: Styles.blackBoldSmall,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                    ],
                  ),
                  // SizedBox(
                  //   height: 28,
                  // ),
                  // Row(
                  //   children: [
                  //     Text(
                  //       'Latest:',
                  //       style: Styles.blackTiny,
                  //     ),
                  //     SizedBox(
                  //       width: 8,
                  //     ),
                  //     Text(
                  //       latest == null ? 'some date' : latest,
                  //       style: Styles.whiteBoldSmall,
                  //     ),
                  //     SizedBox(
                  //       width: 28,
                  //     ),
                  //     Text(
                  //       'Earliest:',
                  //       style: Styles.blackTiny,
                  //     ),
                  //     SizedBox(
                  //       width: 8,
                  //     ),
                  //     Text(
                  //       earliest == null ? 'some date' : earliest,
                  //       style: Styles.whiteBoldSmall,
                  //     )
                  //   ],
                  // ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.brown[100],
        body: Stack(
          children: [
            suitcases.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SizedBox(
                            height: 200,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'No User Media found',
                                  style: Styles.blackBoldSmall,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text(
                                    'Tap the button below to start adding photos and videos for the project'),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('Start Work')),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 1),
                    itemCount: suitcases.length,
                    itemBuilder: (BuildContext context, int index) {
                      var suitcase = suitcases.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          _onMediaTapped(suitcase);
                        },
                        child: SizedBox(
                          height: 120,
                          width: 120,
                          child: suitcase.video != null
                              ? Image.asset(
                                  'assets/video3.png',
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.fill,
                                )
                              : Image.network(
                                  suitcase.photo!.thumbnailUrl!,
                                  fit: BoxFit.fill,
                                ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  var suitcases = <Suitcase>[];

  void _onMediaTapped(Suitcase suitcase) {
    if (suitcase.video != null) {
      pp('🦠 🦠 🦠 _onMediaTapped: Play video from 🦠 ${suitcase.video!.url} 🦠');
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.bottomRight,
              duration: const Duration(seconds: 1),
              child: VideoMain(suitcase.video!)));
    } else {
      pp(' 🍎 🍎 🍎 _onMediaTapped: show full image from 🍎 ${suitcase.photo!.url!} 🍎');
      // Navigator.push(
      //     context,
      //     PageTransition(
      //         type: PageTransitionType.scale,
      //         alignment: Alignment.bottomRight,
      //         duration: Duration(seconds: 1),
      //         child: FullPhotoMain(suitcase.photo, )));
    }
  }
}

class Suitcase {
  Photo? photo;
  Video? video;
  String? date;

  Suitcase({this.photo, this.video, this.date});
}
