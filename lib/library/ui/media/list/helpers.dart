import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_router/library/bloc/organization_bloc.dart';
import 'package:test_router/library/functions.dart';

import '../../../api/sharedprefs.dart';
import '../../../bloc/project_bloc.dart';
import '../../../bloc/user_bloc.dart';
import '../../../data/organization.dart';
import '../../../data/photo.dart';
import '../../../data/project.dart';
import '../../../data/user.dart';
import '../../../data/video.dart';

class MediaBag {
  Photo? photo;
  Video? video;
  String? date;

  MediaBag({this.photo, this.video, required this.date});
}

class Photos extends StatefulWidget {
  const Photos(
      {Key? key,
      this.organization,
      this.project,
      this.user,
      required this.refresh,
      required this.onPhotoTapped})
      : super(key: key);

  final Organization? organization;
  final Project? project;
  final User? user;
  final bool refresh;
  final Function(Photo) onPhotoTapped;

  @override
  State<Photos> createState() => _PhotosState();
}

class _PhotosState extends State<Photos> {
  var photos = <Photo>[];
  @override
  void initState() {
    super.initState();
    _subscribeToStreams();
    _getPhotos();
  }

  void _subscribeToStreams() async {}
  void _getPhotos() async {
    if (widget.organization != null) {
      photos = await organizationBloc.getPhotos(
          organizationId: widget.organization!.organizationId!,
          forceRefresh: widget.refresh);
    } else if (widget.project != null) {
      photos = await projectBloc.getPhotos(
          projectId: widget.project!.projectId!, forceRefresh: widget.refresh);
    } else if (widget.user != null) {
      photos = await userBloc.getPhotos(
          userId: widget.user!.userId!, forceRefresh: widget.refresh);
    } else {
      var user = await Prefs.getUser();
      if (user != null) {
        photos =
            await userBloc.getPhotos(userId: user.userId!, forceRefresh: true);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.blue,
          height: 2,
        ),
        // Expanded(
        //   child: GridView.custom(
        //     padding: const EdgeInsets.only(
        //       bottom: 2,
        //       left: 2,
        //       right: 2,
        //     ),
        //     gridDelegate: SliverQuiltedGridDelegate(
        //       crossAxisCount: 2,
        //       mainAxisSpacing: 0,
        //       crossAxisSpacing: 0,
        //       repeatPattern: QuiltedGridRepeatPattern.inverted,
        //       pattern: const [
        //         QuiltedGridTile(2, 1),
        //         QuiltedGridTile(2, 1),
        //         QuiltedGridTile(1, 2),
        //         QuiltedGridTile(1, 2),
        //       ],
        //     ),
        //     childrenDelegate: SliverChildBuilderDelegate(
        //       (context, index) {
        //         var photo = photos.elementAt(index);
        //         return Stack(
        //           children: [
        //             Container(
        //               color: Colors.pink,
        //               child: CachedNetworkImage(
        //                   fit: BoxFit.fill, imageUrl: photo.thumbnailUrl!),
        //             ),
        //           ],
        //         );
        //       },
        //       childCount: photos.length,
        //     ),
        //   ),
        // ),
        Expanded(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 1, crossAxisCount: 2, mainAxisSpacing: 1),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  var photo = photos.elementAt(index);
                  var dt =
                      getFormattedDateShortestWithTime(photo.created!, context);
                  return Stack(
                    children: [
                      SizedBox(
                        width: 300,
                        child: GestureDetector(
                          onTap: () {
                            widget.onPhotoTapped(photo);
                          },
                          child: CachedNetworkImage(
                              imageUrl: photo.thumbnailUrl!, fit: BoxFit.cover),
                        ),
                      ),
                      // Positioned(
                      //   child: Container(
                      //     color: Colors.black38,
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Text(
                      //         dt,
                      //         style: GoogleFonts.lato(
                      //             textStyle:
                      //                 Theme.of(context).textTheme.bodySmall,
                      //             fontWeight: FontWeight.normal,
                      //             fontSize: 10),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Positioned(
                      //   bottom: 8, left: 0,
                      //   child: Container(
                      //     color: Colors.black38,
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: Text(
                      //             photo.projectName!,
                      //             overflow: TextOverflow.ellipsis,
                      //             style: GoogleFonts.lato(
                      //                 textStyle:
                      //                 Theme.of(context).textTheme.bodySmall,
                      //                 fontWeight: FontWeight.normal,
                      //                 fontSize: 11),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  );
                })),
      ],
    );
  }
}
