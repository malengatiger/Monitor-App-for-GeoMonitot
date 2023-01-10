import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../bloc/project_bloc.dart';
import '../../../data/photo.dart';
import '../../../data/project.dart';
import '../../../data/video.dart';
import '../../../functions.dart';

class ProjectVideos extends StatefulWidget {


  final Project project;
  final bool refresh;
  final Function(Video) onVideoTapped;

  const ProjectVideos({super.key, required this.project, required this.refresh, required this.onVideoTapped});

  @override
  State<ProjectVideos> createState() => _ProjectPhotosState();
}

class _ProjectPhotosState extends State<ProjectVideos> {
  var videos = <Video>[];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    _subscribeToStreams();
    _getVideos();
  }

  void _subscribeToStreams() async {}
  void _getVideos() async {
    setState(() {
      loading = true;
    });
    videos = await projectBloc.getProjectVideos(
        projectId: widget.project.projectId!, forceRefresh: widget.refresh);
    videos.sort((a,b) => b.created!.compareTo(a.created!));
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.blue,
          height: 2,
        ),
        Expanded(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 1, crossAxisCount: 2, mainAxisSpacing: 1),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  var video = videos.elementAt(index);
                  var dt =
                  getFormattedDateShortestWithTime(video.created!, context);
                  return Stack(
                    children: [
                      SizedBox(
                        width: 300,
                        child: GestureDetector(
                          onTap: () {
                            widget.onVideoTapped(video);
                          },
                          child: CachedNetworkImage(
                              imageUrl: video.thumbnailUrl!, fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  );
                })),
      ],
    );
  }
}