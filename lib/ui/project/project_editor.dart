import 'package:flutter/material.dart';

import '../../library/api/sharedprefs.dart';
import '../../library/bloc/admin_bloc.dart';
import '../../library/data/user.dart';
import '../../library/data/project.dart';
import '../../library/functions.dart';
import '../../library/snack.dart';

class ProjectEditor extends StatefulWidget {
  final Project? project;

  const ProjectEditor({super.key, this.project});

  @override
  ProjectEditorState createState() => ProjectEditorState();
}

class ProjectEditorState extends State<ProjectEditor>
     {
  User? user;
  Project? mProject;
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  bool isBusy = false;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    user = await Prefs.getUser();
    mProject = widget.project;
    if (mProject == null) {

    } else {
      nameController.text = mProject!.name!;
      descController.text = mProject!.description!;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('Project Editor'),
        backgroundColor: Colors.purple[300],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  user == null ? '' : '${user!.organizationName}',
                  style: Styles.whiteBoldMedium,
                  overflow: TextOverflow.clip,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.brown[100],
      body: isBusy
          ? const Center(
              child: SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 24,
                  backgroundColor: Colors.teal,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8),
              child: ListView(
                children: <Widget>[
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Project Details',
                            style: Styles.blackBoldLarge,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter Project Name',
                              labelText: 'Project Name',
                            ),
                            onChanged: _onNameChanged,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            controller: descController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: 'Enter Project Description',
                              labelText: 'Description',
                            ),
                            onChanged: _onDescChanged,
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          ElevatedButton(

                            onPressed: _submit,

                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 24.0, right: 24.0, top: 20, bottom: 20),
                              child: Text(
                                'Submit Project',
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
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.camera), label: 'Camera'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_library), label: 'Rating'),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_on), label: 'Location'),
        ],
        onTap: _onNavTapped,
      ),
    );
  }

  void _onNameChanged(String value) {
    mProject!.name = value;
  }

  void _onDescChanged(String value) {
    mProject!.description = value;
  }

  _submit() async {
    setState(() {
      isBusy = true;
    });
    if (mProject!.name == null || mProject!.name!.isEmpty) {
      _showError('Please enter Project name');
      return;
    }
    if (mProject!.description == null || mProject!.description!.isEmpty) {
      _showError('Please enter Project description');
      return;
    }
    try {
      mProject = await adminBloc.addProject(mProject!);

    } catch (e) {
      pp(e);
      _showError('$e');
    }
    setState(() {
      isBusy = false;
    });
    AppSnackbar.showSnackbar(
        scaffoldKey: _key,
        message: 'Project added',
        textColor: Colors.lightBlue,
        backgroundColor: Colors.black);
  }

  _showError(String message) {
    AppSnackbar.showErrorSnackbar(
        scaffoldKey: _key,
        message: message,
        actionLabel: 'Error');
  }


  void _onNavTapped(int value) {
    if (mProject!.projectId == null || mProject!.projectId!.isEmpty) {
      debugPrint('👎 👎 👎 NavTapped - project not ready yet');
      return;
    }
    switch (value) {
      case 0:
        // Navigator.push(
        //     context,
        //     PageTransition(
        //         type: PageTransitionType.scale,
        //         alignment: Alignment.topLeft,
        //         duration: const Duration(seconds: 1),
        //         child: CameraMain(
        //           project: mProject,
        //         )));
        break;
    }
  }
}
