import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../../data/video.dart';
import '../../functions.dart';

class PlayVideo extends StatefulWidget {
  const PlayVideo({Key? key, required this.video}) : super(key: key);

  final Video video;

  @override
  PlayVideoState createState() => PlayVideoState();
}

class PlayVideoState extends State<PlayVideo>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  static const mm = '🔵🔵🔵🔵 PlayVideoState 🍎 : ';

  int videoDurationInSeconds = 0;
  double videoDurationInMinutes = 0.0;
  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
    pp('PlayVideo initState: ${widget.video.toJson()}  🔵🔵');
    videoController = VideoPlayerController.network(widget.video.url!)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        pp('.......... doing shit with videoController ... setting state .... '
            '$videoController 🍎DURATION: ${videoController!.value.duration} seconds!');

        setState(() {
          if (videoController != null) {
            videoDurationInSeconds = videoController!.value.duration.inSeconds;
            videoDurationInMinutes = videoDurationInSeconds / 60;
            videoController!.value.isPlaying
                ? videoController!.pause()
                : videoController!.play();
          }
        });
      });
  }

  // Future<void> _startVideoPlayer() async {
  //
  //   pp('$mm _startVideoPlayer .... 🥏 🥏 🥏 🥏 video url: ${widget.video} }');
  //   videoController =
  //   //VideoPlayerController.file(File(widget.videoFile.path));
  //   videoController = VideoPlayerController.network(widget.video);
  //   videoPlayerListener = () {
  //     if (videoController != null) {
  //       // Refreshing the state to update video player with the correct ratio.
  //       if (mounted) setState(() {});
  //       videoController!.removeListener(videoPlayerListener!);
  //     }
  //   };
  //
  //   if (videoController != null) {
  //     videoController!.addListener(videoPlayerListener!);
  //     await videoController!.setLooping(false);
  //     await videoController!.initialize();
  //     //await videoController?.dispose();
  //     if (mounted) {
  //       await videoController!.play();
  //     }
  //   }
  //
  //
  // }

  @override
  void dispose() {
    _animationController.dispose();
    if (videoController != null) {
      pp('Disposing the videoController ... ');
      videoController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var m = getFormattedDateLongWithTime(widget.video.created!, context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Video Player'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Column(
              children: [
                Text(
                  '${widget.video.projectName}',
                  style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  m,
                  style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.bodySmall,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text('Video Duration',style: GoogleFonts.lato(
                        textStyle: Theme.of(context).textTheme.bodySmall,
                        fontWeight: FontWeight.normal, ),),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      videoDurationInMinutes > 1.0
                          ? '${videoDurationInMinutes.toStringAsFixed(2)} minutes'
                          : '$videoDurationInSeconds seconds',
                      style: GoogleFonts.lato(
                          textStyle: Theme.of(context).textTheme.bodySmall,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).primaryColorLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: videoController == null
            ? const Center(
                child: Text('Not ready yet!'),
              )
            : Center(
                child: videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: videoController!.value.aspectRatio,
                        child: GestureDetector(
                            onTap: () {
                              pp('$mm Tap happened! Pause the video if playing 🍎 ...');
                              if (videoController!.value.isPlaying) {
                                if (mounted) {
                                  setState(() {
                                    videoController!.pause();
                                  });
                                }
                              }

                            },
                            child: VideoPlayer(videoController!)),
                      )
                    : Center(
                        child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0)),
                            child: const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('Video is buffering ...'),
                            )),
                      ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              if (videoController != null) {
                videoController!.value.isPlaying
                    ? videoController!.pause()
                    : videoController!.play();
              }
            });
            //_startVideoPlayer();
          },
          child: Icon(
            videoController == null ? Icons.cached : Icons.play_arrow,
          ),
        ),
      ),
    );
  }
}
