import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:test_router/library/ui/media/user_media_list/user_media_list_desktop.dart';
import 'package:test_router/library/ui/media/user_media_list/user_media_list_mobile.dart';
import 'package:test_router/library/ui/media/user_media_list/user_media_list_tablet.dart';

import '../../../api/sharedprefs.dart';
import '../../../bloc/user_bloc.dart';
import '../../../data/user.dart';
import '../../../functions.dart';

class UserMediaListMain extends StatefulWidget {
  final User user;

  const UserMediaListMain(this.user, {super.key});

  @override
  UserMediaListMainState createState() => UserMediaListMainState();
}

class UserMediaListMainState extends State<UserMediaListMain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var isBusy = false;
  User? user;

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
    user = widget.user;
    user ??= await Prefs.getUser();

    pp('MediaListMain: 💜 💜 💜 getting media for ${user!.name}');
    await userBloc.getPhotos(userId: user!.userId!, forceRefresh: true);
    await userBloc.getVideos(userId: user!.userId!, forceRefresh: true);
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
            mobile: UserMediaListMobile(user: user!),
            tablet: UserMediaListTablet(user!),
            desktop: UserMediaListDesktop(user!),
          );
  }
}
