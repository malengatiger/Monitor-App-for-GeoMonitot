import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../api/sharedprefs.dart';
import '../../../bloc/monitor_bloc.dart';
import '../../../data/project.dart';
import '../../../functions.dart';
import 'media_list_desktop.dart';
import 'media_list_mobile.dart';
import 'media_list_tablet.dart';

class MediaListMain extends StatefulWidget {
  final Project project;

  const MediaListMain({super.key, required this.project});


  @override
  MediaListMainState createState() => MediaListMainState();
}

class MediaListMainState extends State<MediaListMain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var isBusy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getMedia();
  }

  void _getMedia() async {
    setState(() {
      isBusy = true;
    });

      pp('MediaListMain: 💜 💜 💜 getting media for PROJECT: ${widget.project!.name!}');
      await monitorBloc.refreshProjectData(
          projectId: widget.project!.projectId!, forceRefresh: false);

    setState(() {
      isBusy = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isBusy
        ? SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'Loading project media ...',
                  style: Styles.whiteSmall,
                ),
              ),
              body: const Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    backgroundColor: Colors.black,
                  ),
                ),
              ),
            ),
          )
        : ScreenTypeLayout(
            mobile: MediaListMobile(widget.project!),
            tablet: MediaListTablet(widget.project!),
            desktop: MediaListDesktop(widget.project!),
          );
  }
}
