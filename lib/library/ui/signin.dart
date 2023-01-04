import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot;
import 'package:geo_monitor/library/auth/app_auth.dart';
import 'package:geo_monitor/library/data/user.dart';
import 'package:geo_monitor/library/functions.dart';

class SignIn extends StatefulWidget {
  final String type;

  const SignIn(this.type, {super.key});

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool isBusy = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(
          'Digital Monitor Platform',
          style: Styles.whiteSmall,
        ),
        // backgroundColor: Colors.brown[400],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              Text(widget.type, style: Styles.whiteBoldMedium),
              const SizedBox(
                height: 24,
              )
            ],
          ),
        ),
      ),
      // backgroundColor: Colors.brown[100],
      body: isBusy
          ? Center(
              child: SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 24,
                  backgroundColor: Colors.teal[800],
                ),
              ),
            )
          : ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 40,
                          ),
                          Text(
                            'Sign in',
                            style: Styles.blackBoldLarge,
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          TextField(
                            onChanged: _onEmailChanged,
                            keyboardType: TextInputType.emailAddress,
                            controller: emailCntr,
                            decoration: const InputDecoration(
                              hintText: 'Enter  email address',
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          TextField(
                            onChanged: _onPasswordChanged,
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            controller: pswdCntr,
                            decoration: const InputDecoration(
                              hintText: 'Enter password',
                            ),
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          ElevatedButton(
                            onPressed: _signIn,
                            // color: Colors.pink[700],
                            // elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'Submit Sign in credentials',
                                style: Styles.whiteSmall,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  TextEditingController emailCntr = TextEditingController();
  TextEditingController pswdCntr = TextEditingController();

  @override
  initState() {
    super.initState();
    _checkStatus();
  }

  //user: ORG_ADMINISTRATOR 🍎  org.qaf@monitor.com 🔵  Nicole Seleka
  //user: FIELD_MONITOR 🍎  monitor.zyp@monitor.com 🔵  Mmaphefo De sousa
  //user: EXECUTIVE 🍎  exec.uat@monitor.com 🔵  Andre Motau
  void _checkStatus() async {
    var status = dot.dotenv.env['CURRENT_STATUS'];
    pp('🥦🥦 Checking status ..... 🥦🥦 status: $status 🌸 🌸 🌸');
    if (status == 'dev') {
      pswdCntr.text = 'pass123';
      switch (widget.type) {
        case UserType.fieldMonitor:
          emailCntr.text = 'monitor.zyp@monitor.com';
          break;
        case UserType.orgExecutive:
          emailCntr.text = 'exec.uat@monitor.com';
          break;
        case UserType.orgAdministrator:
          emailCntr.text = 'org.qaf@monitor.com';
          break;
        default:
          emailCntr.text = 'org.qaf@monitor.com';
          break;

          break;
      }
    }


    setState(() {});
  }

  String email = '', password = '';
  void _onEmailChanged(String value) {
    email = value;
    pp(email);
  }

  void _signIn() async {
    email = emailCntr.text;
    password = pswdCntr.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credentials missing or invalid')));
      return;
    }
    setState(() {
      isBusy = true;
    });
    try {
      var user = await AppAuth.signIn(email, password, widget.type);
      if (!mounted) return;
      Navigator.pop(context, user);
      //do I want to gp to dashboard??
    } catch (e) {
      setState(() {
        isBusy = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
    }
  }

  void _onPasswordChanged(String value) {
    password = value;
    pp(password);
  }
}
