
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'package:page_transition/page_transition.dart';

import '../../library/api/sharedprefs.dart';
import '../../library/data/user.dart';
import '../../library/functions.dart';
import '../../library/ui/signin.dart';
import '../dashboard/dashboard_main.dart';

class IntroMobile extends StatefulWidget {
  final User? user;
  IntroMobile({Key? key, this.user}) : super(key: key);
  @override
  _IntroMobileState createState() => _IntroMobileState();
}

class _IntroMobileState extends State<IntroMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  User? user;
  var lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ac sagittis lectus. Aliquam dictum elementum massa, '
      'eget mollis elit rhoncus ut.';

  var mList = <PageViewModel>[];
  void _buildPages(BuildContext context) {
    var page1 = PageViewModel(
      titleWidget: Text(
        "Welcome to The Digital Monitor",
        style: TextStyle(
            fontSize: Styles.medium, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
      ),
      bodyWidget: Text(
        "$lorem",
        style: Styles.blackSmall,
      ),
      image: Image.asset(
        "assets/intro/img4.jpeg",
        fit: BoxFit.cover,
      ),
    );
    var page2 = PageViewModel(
      titleWidget: Text(
        "Field Monitors are people too",
        style: TextStyle(
            fontSize: Styles.medium, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
      ),
      bodyWidget: Text(
        "$lorem",
        style: Styles.blackSmall,
      ),
      image: Image.asset("assets/intro/img5.jpeg", fit: BoxFit.cover),
    );
    var page3 = PageViewModel(
      titleWidget: Text(
        "Start using The Digital Monitor",
        style: TextStyle(
            fontSize: Styles.medium, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
      ),
      bodyWidget: Text(
        "$lorem",
        style: Styles.blackSmall,
      ),
      image: Image.asset("assets/intro/img6.jpeg", fit: BoxFit.cover),
    );
    mList.clear();
    setState(() {
      mList.add(page1);
      mList.add(page2);
      mList.add(page3);
    });
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    user = widget.user;
    super.initState();
    _getUser();

  }
  void _getUser() async {
    if (widget.user == null) {
      user = await Prefs.getUser();
      if (user != null) {
        _navigateToDashboard();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (mList.isEmpty) {
      _buildPages(context);
    }
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          leading: widget.user == null? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {
            Navigator.pop(context);
          },) : Container(),
          title: Text(
            'The Digital Monitor Platform',
            style: Styles.whiteSmall,
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Column(
              children: [
                user == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(
                            width: 48,
                          ),
                          TextButton(
                            onPressed: _navigateToSignIn,
                            child:
                                Text('Sign In', style: Styles.blackBoldSmall),
                          ),
                          const SizedBox(
                            width: 24,
                          ),
                        ],
                      )
                    : Text(user == null? '' : user!.name!, style: Styles.blackBoldMedium,),
                const SizedBox(
                  height: 24,
                )
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            IntroductionScreen(
              pages: mList,
              onDone: () {
                _navigateToDashboard();
              },
              showSkipButton: false,
              skip: const Icon(Icons.skip_next),
              next: const Icon(Icons.arrow_forward),
              done: user == null
                  ? Container()
                  : Text("Done",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      )),
              dotsDecorator: DotsDecorator(
                size: const Size.square(10.0),
                activeSize: const Size(20.0, 10.0),
                activeColor: Theme.of(context).primaryColor,
                color: Colors.black26,
                spacing: const EdgeInsets.symmetric(horizontal: 3.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDashboard() {
    if (user != null) {
      Navigator.pop(context);
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child: DashboardMain(user: user!,)));
    } else {
      pp('User is null,  🔆 🔆 🔆 🔆 cannot navigate to Dashboard');
    }
  }

  Future<void> _navigateToSignIn() async {
    var result = await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: const SignIn(UserType.orgAdministrator)));

    if (result is User) {
      pp(' 👌👌👌 Returned from sign in; will navigate to Dashboard :  👌👌👌 ${result.toJson()}');
      setState(() {
        user = result;
      });
      _navigateToDashboard();
    } else {
      pp(' 😡  😡  Returned from sign in is NOT a user :  😡 $result');
    }
  }

  final _key = GlobalKey<ScaffoldState>();

}
