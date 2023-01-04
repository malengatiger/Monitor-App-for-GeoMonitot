import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:geo_monitor/library/api/data_api.dart';
import 'package:geo_monitor/library/api/sharedprefs.dart';
import 'package:geo_monitor/library/data/project.dart';
import 'package:geo_monitor/library/data/user.dart';
import 'package:uuid/uuid.dart';

import '../../data/org_message.dart';
import '../../functions.dart';
import '../../snack.dart';

class MonitorMessage extends StatefulWidget {
  final Project project;
  final User user;

  const MonitorMessage({
    required this.project,
    required this.user,
  });

  @override
  MonitorMessageState createState() => MonitorMessageState();
}

class MonitorMessageState extends State<MonitorMessage> {
  String frequency = MONITOR_TWICE_A_DAY;
  bool isBusy = false;
  final _key = GlobalKey<ScaffoldState>();
  void _onRadioButtonSelected(String selected) {
    pp('MessageMobile :  🥦 🥦 🥦 _onRadioButtonSelected: 🍊 $selected 🍊');
    setState(() {
      frequency = selected;
    });
  }

  void _sendMessage() async {
    // if (frequency == null) {
    //   // AppSnackbar.showErrorSnackbar(
    //   //     scaffoldKey: widget.key, message: 'Please select frequency');
    //   return;
    // }

    setState(() {
      isBusy = true;
    });
    var admin = await Prefs.getUser();
    if (admin != null && admin.userId != widget.user.userId) {
      var msg = OrgMessage(
          name: widget.user.name,
          adminId: admin.userId,
          adminName: admin.name,
          projectName: widget.project.name,
          frequency: frequency,
          message: 'Please collect info',
          userId: widget.user.userId,
          created: DateTime.now().toUtc().toIso8601String(),
          projectId: widget.project.projectId,
          organizationId: widget.project.organizationId,
          orgMessageId: Uuid().v4());
      try {
        var res = await DataAPI.sendMessage(msg);
        pp('MessageMobile:  🏓  🏓  🏓 Response from server:  🏓 ${res.toJson()}  🏓');
      } catch (e) {
        // AppSnackbar.showErrorSnackbar(
        //     scaffoldKey: widget.key, message: 'Message Send failed : $e');
      }
      setState(() {
        isBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.app_registration,
            color: Theme.of(context).primaryColor,
          ),
          title: AnimatedContainer(
            duration: Duration(milliseconds: 1000),
            width:  300.0,
            child: Text(widget.project.name!,
              style: Styles.blackBoldSmall,
            ),
          ),
        ),
        SizedBox(
          height: 2,
        ),
        RadioButtonGroup(
          labelStyle: Styles.blackSmall,
          picked: frequency,
          labels: [
            MONITOR_ONCE_A_DAY,
            MONITOR_TWICE_A_DAY,
            // MONITOR_THREE_A_DAY,
            MONITOR_ONCE_A_WEEK
          ],
          onSelected: _onRadioButtonSelected,
        ),
        SizedBox(
          height: 4,
        ),
        isBusy
            ? Container(
                height: 24,
                width: 24,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    backgroundColor: Colors.pink[200],
                  ),
                ),
              )
            : widget.project == null
                ? Container()
                : ElevatedButton(
                    child: Text(
                      'Send Message',
                      style: Styles.whiteSmall,
                    ),
                    onPressed: _sendMessage),
        SizedBox(
          height: 12,
        )
      ],
    );
  }
}