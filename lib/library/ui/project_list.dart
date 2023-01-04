import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/data_api.dart';
import 'package:geo_monitor/library/api/sharedprefs.dart';
import 'package:geo_monitor/library/data/project.dart';
import 'package:geo_monitor/library/data/user.dart';
import 'package:geo_monitor/library/functions.dart';

abstract class ProjectListener {
  onProjectSelected(Project project);
}

class ProjectList extends StatefulWidget {
  final ProjectListener listener;

  ProjectList(this.listener);

  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  User? user;
  bool isBusy = false;
  List<Project> projects = [];
  GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    user = await Prefs.getUser();
    setState(() {
      isBusy = true;
    });
    projects = await DataAPI.findProjectsByOrganization(user!.organizationId!);
    setState(() {
      isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Project List',
          style: Styles.whiteSmall,
        ),
        elevation: 8,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Text(
                          user == null ? 'Organization' : user!.organizationName!,
                          style: Styles.whiteBoldSmall,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          '${projects.length}',
                          style: Styles.blackBoldLarge,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Projects',
                          style: Styles.whiteSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.brown[100],
      body: isBusy
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 24,
                backgroundColor: Colors.yellow,
              ),
            )
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (BuildContext context, int index) {
                var p = projects.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
                  child: GestureDetector(
                    onTap: () {
                      widget.listener.onProjectSelected(p);
                    },
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12, top: 8),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.apps,
                                  color: getRandomColor(),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                    child: Text(p.name!,
                                        style: Styles.blackBoldMedium,
                                        overflow: TextOverflow.clip)),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: 32,
                                ),
                                Expanded(
                                    child: Text(p.description!,
                                        style: Styles.blackSmall,
                                        overflow: TextOverflow.clip)),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}