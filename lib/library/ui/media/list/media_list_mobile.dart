import 'dart:async';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../../api/sharedprefs.dart';
import '../../../bloc/organization_bloc.dart';
import '../../../bloc/project_bloc.dart';
import '../../../bloc/user_bloc.dart';
import '../../../data/organization.dart';
import '../../../data/user.dart';
import '../../../data/video.dart';
import '../../../functions.dart';
import '../../../snack.dart';
import '../../../data/photo.dart';
import '../../../data/project.dart';
import '../full_photo/full_photo_mobile.dart';
import 'helpers.dart';
import 'media_grid.dart';

class MediaListMobile extends StatefulWidget {
  final Organization? organization;
  final Project? project;
  final User? user;

  const MediaListMobile(
      {super.key, this.organization, this.project, this.user});

  @override
  MediaListMobileState createState() => MediaListMobileState();
}

class MediaListMobileState extends State<MediaListMobile>
    with TickerProviderStateMixin
    implements MediaGridListener {
  late AnimationController _animationController;
  StreamSubscription<List<Photo>>? photoStreamSubscription;
  StreamSubscription<List<Video>>? videoStreamSubscription;
  String? latest, earliest;
  late TabController _tabController;

  var _photos = <Photo>[];
  var _videos = <Video>[];
  User? user;
  static const mm = '🔆🔆🔆 MediaListMobile 💜💜 ';

  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 2000),
        reverseDuration: const Duration(milliseconds: 1000),
        vsync: this);
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    user = widget.user;
    _listen();
    // _tabController.animateTo(2);
  }

  Future<void> _listen() async {
    user ??= await Prefs.getUser();
    if (widget.organization != null) {
      _listenToOrgStreams();
      return;
    }
    if (widget.project != null) {
      _listenToProjectStreams();
      return;
    }

    if (user != null) {
      switch (user!.userType!) {
        case UserType.fieldMonitor:
          _listenToMonitorStreams();
          break;
        case UserType.orgAdministrator:
          _listenToOrgStreams();
          break;
        case UserType.orgExecutive:
          _listenToOrgStreams();
          break;
      }
    }
    if (mounted) {
      _refresh(false);
    }
  }

  void _listenToProjectStreams() async {
    pp('$mm .................... Listening to streams from userBloc ....');

    photoStreamSubscription = projectBloc.photoStream.listen((value) {
      pp('$mm Photos received from stream projectPhotoStream: 💙 ${value.length}');
      _photos = value;
      _processMedia();
      if (mounted) {
        setState(() {});
      }
    });

    videoStreamSubscription = projectBloc.videoStream.listen((value) {
      pp('$mm:Videos received from projectVideoStream: 🏈 ${value.length}');
      _videos = value;
      _processMedia();
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _listenToMonitorStreams() async {
    pp('$mm .................... Listening to streams from userBloc ....');

    photoStreamSubscription = userBloc.photoStream.listen((value) {
      pp('$mm Photos received from stream projectPhotoStream: 💙 ${value.length}');
      _photos = value;
      _processMedia();
      if (mounted) {
        setState(() {});
      }
    });

    videoStreamSubscription = userBloc.videoStream.listen((value) {
      pp('$mm:Videos received from projectVideoStream: 🏈 ${value.length}');
      _videos = value;
      _processMedia();
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _listenToOrgStreams() async {
    pp('$mm .................... Listening to streams from organizationBloc ....');
    user = await Prefs.getUser();

    photoStreamSubscription = organizationBloc.photoStream.listen((photos) {
      pp('$mm Photos received from stream photoStream: 💙 ${photos.length}');
      _photos = photos;
      _photos.sort((a, b) => b.created!.compareTo(a.created!));
      _processMedia();
      if (mounted) {
        setState(() {});
      }
    });

    videoStreamSubscription = organizationBloc.videoStream.listen((videos) {
      pp('$mm:Videos received from projectVideoStream: 🏈 ${videos.length}');
      _videos = videos;
      _videos.sort((a, b) => b.created!.compareTo(a.created!));
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
      if (user != null) {
        switch (user!.userType!) {
          case UserType.fieldMonitor:
            await projectBloc.refreshProjectData(
                projectId: widget.project!.projectId!,
                forceRefresh: forceRefresh);

            break;
          case UserType.orgAdministrator:
            organizationBloc.refreshOrganizationData(
                organizationId: user!.organizationId!,
                forceRefresh: forceRefresh);
            break;
          case UserType.orgExecutive:
            _listenToOrgStreams();
            break;
        }
      }
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
  bool _showPhotoDetail = false;
  Photo? selectedPhoto;
  @override
  void dispose() {
    _animationController.dispose();
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Photos & Videos',
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.bodyMedium,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(onPressed: (){
            pp('...... navigate to take photos');
          }, icon: const Icon(Icons.camera_alt)),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs:  [
            Card(
              elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0)),
                child:  Padding(
                  padding: const EdgeInsets.only(left:12.0,right: 12.0, top: 8, bottom: 8),
                  child: Text('Photos', style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.bodySmall,
                    fontWeight: FontWeight.normal,),),
                )),
            Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0)),
                child:  Padding(
                  padding: const EdgeInsets.only(left:12.0,right: 12.0, top: 8, bottom: 8),
                  child: Text('Videos', style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.bodySmall,
                    fontWeight: FontWeight.normal,),),
                )),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              Photos(
                organization: widget.organization,
                project: widget.project,
                user: widget.user,
                refresh: true,
                onPhotoTapped: (Photo photo) {
                  pp('🔷🔷🔷Photo has been tapped: ${photo.created!}');
                  selectedPhoto = photo;
                  setState(() {
                    _showPhotoDetail = true;
                  });
                  _animationController.forward();
                },
              ),
              Photos(
                organization: widget.organization,
                project: widget.project,
                user: widget.user,
                refresh: true,
                onPhotoTapped: (Photo photo) {
                  pp('🍎🍎🍎Photo has been tapped: ${photo.created!}');
                },
              ),
            ],
          ),
          _showPhotoDetail
              ? Positioned(
                  left: 28,
                  top: 48,
                  child: SizedBox(
                    width: 260,
                    child: GestureDetector(
                      onTap: () {
                        pp('🍏🍏🍏🍏Photo tapped - navigate to full photo');
                        _navigateToFullPhoto();
                      },
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (BuildContext context, Widget? child) {

                          return FadeScaleTransition(animation: _animationController, child: child,);
                        },
                        child: PhotoDetails(
                          photo: selectedPhoto!,
                          onClose: () {
                            _animationController.reverse().then((value) {
                              setState(() {
                                _showPhotoDetail = false;
                              });
                            });

                          },
                        ),
                      ),
                    ),
                  ))
              : const SizedBox(),
        ],
      ),
    ));
  }

  final _suitcases = <MediaBag>[];

  void _navigateToFullPhoto() {

    pp('... about to navigate after waiting 100 ms');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRightWithFade,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1500),
            child: FullPhotoMobile(photo: selectedPhoto!)));
    if (widget.project != null) {
      Future.delayed(const Duration(milliseconds: 100), () {

      });

    }
  }

  @override
  onMediaSelected(mediaBag) {
    // TODO: implement onMediaSelected
    throw UnimplementedError();
  }
}

class PhotoDetails extends StatelessWidget {
  const PhotoDetails({Key? key, required this.photo, required this.onClose}) : super(key: key);
  final Photo photo;
  final Function onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      // height: 420,
      child: Card(
        elevation: 8,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: (){
                  onClose();
                }, icon: const Icon(Icons.close)),
              ],),
              const SizedBox(
                height: 2,
              ),
              Text(photo.projectName!, style: GoogleFonts.lato(
                textStyle: Theme.of(context).textTheme.bodySmall,
                fontWeight: FontWeight.normal,),),
              const SizedBox(
                height: 0,
              ),
              Text(getFormattedDateShortWithTime(photo.created!, context), style: GoogleFonts.lato(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                fontWeight: FontWeight.w900,),),
               SizedBox(width: 220,
                 child: Card(
                   shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(16.0)),
                   child: CachedNetworkImage(
                       fit: BoxFit.cover,
                       fadeInCurve: Curves.easeIn,
                       fadeInDuration: const Duration(milliseconds: 1000),
                       imageUrl: photo.thumbnailUrl!),
                 ),),

            ],
          ),
        ),
      ),
    );
  }
}
