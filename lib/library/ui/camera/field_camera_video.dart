// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:test_router/library/auth/app_auth.dart';
import 'package:test_router/library/bloc/cloud_storage_bloc.dart';
import 'package:test_router/library/emojis.dart';
import 'package:test_router/library/ui/camera/play_video.dart';
import 'package:test_router/library/ui/media/list/media_list_main.dart';
import 'package:video_player/video_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot;
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import '../../api/sharedprefs.dart';
import '../../data/project.dart';
import '../../data/project_position.dart';
import '../../data/user.dart';
import '../../data/video.dart';
import '../../functions.dart';
import '../../generic_functions.dart';
import '../../location/loc_bloc.dart';

class FieldVideoCamera extends StatefulWidget {
  final Project project;
  final ProjectPosition projectPosition;

  const FieldVideoCamera(
      {super.key, required this.project, required this.projectPosition});

  @override
  FieldVideoCameraState createState() {
    return FieldVideoCameraState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
    default:
      throw ArgumentError('Unknown lens direction');
  }
}

void logError(String code, String? message) {
  if (message != null) {
    pp('Error: $code\nError Message: $message');
  } else {
    pp('Error: $code');
  }
}

class FieldVideoCameraState extends State<FieldVideoCamera>
    with WidgetsBindingObserver, TickerProviderStateMixin
    implements StorageBlocListener {
  CameraController? _cameraController;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;

  late AnimationController _flashModeControlRowAnimationController;
  late AnimationController _exposureModeControlRowAnimationController;
  final double _minAvailableZoom = 1.0;
  final double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  static const mm = '🍎🍎🍎 FieldVideoCamera 🍎 : ';

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    _observeOrientation();
    _getCameras();

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    if (videoController != null) {
      videoController!.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    pp('$mm didChangeAppLifecycleState ....');
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      pp('$mm call onNewCameraSelected: 🥏 ....');
      _onNewCameraSelected(cameraController.description);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final bool _showGrid = false;

  void _getCameras() async {
    cameras = await availableCameras();
    pp('$mm Found ${cameras.length} cameras');
    for (var camera in cameras) {
      pp('$mm _getCameras:camera: ${camera.name}  🔵 ${camera.lensDirection.toString()}');
    }

    cameras = [cameras.first];
    _onNewCameraSelected(cameras.first);
    setState(() {});
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          _cameraController!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onTapDown: (details) => onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await _cameraController!.setZoomLevel(_currentScale);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;

    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            localVideoController == null && imageFile == null
                ? Container()
                : SizedBox(
                    width: 64.0,
                    height: 64.0,
                    child: (localVideoController == null)
                        ? Image.file(File(imageFile!.path))
                        : Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.pink)),
                            child: Center(
                              child: AspectRatio(
                                  aspectRatio:
                                      localVideoController.value.aspectRatio,
                                  child: VideoPlayer(localVideoController)),
                            ),
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    final CameraController? cameraController = _cameraController;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.videocam),
          color: Colors.blue,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  !cameraController.value.isRecordingVideo
              ? _onVideoRecordButtonPressed
              : null,
        ),
        IconButton(
          icon: cameraController != null &&
                  cameraController.value.isRecordingPaused
              ? const Icon(Icons.play_arrow)
              : const Icon(Icons.pause),
          color: Colors.blue,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  cameraController.value.isRecordingVideo
              ? (cameraController.value.isRecordingPaused)
                  ? _onResumeButtonPressed
                  : _onPauseButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  cameraController.value.isRecordingVideo
              ? _onStopButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.pause_presentation),
          color:
              cameraController != null && cameraController.value.isPreviewPaused
                  ? Colors.red
                  : Colors.blue,
          onPressed:
              cameraController == null ? null : _onPausePreviewButtonPressed,
        ),
      ],
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    //_scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  final zoomLevels = [1.0, 2.0, 3.0, 4.0, 5.0];
  int currentZoomIndex = 0;

  Future<void> onViewFinderTap(
      TapDownDetails details, BoxConstraints constraints) async {
    pp('$mm onViewFinderTap .... ${details.kind.toString()} BoxConstraints: $constraints');
    if (_cameraController == null) {
      return;
    }
    double zoomLevel = 1.0;
    switch (currentZoomIndex) {
      case 0:
        zoomLevel = zoomLevels.elementAt(0);
        break;
      case 1:
        zoomLevel = zoomLevels.elementAt(1);
        break;
      case 2:
        zoomLevel = zoomLevels.elementAt(2);
        break;
      case 3:
        zoomLevel = zoomLevels.elementAt(3);
        break;
      case 4:
        zoomLevel = zoomLevels.elementAt(4);
        break;
    }
    currentZoomIndex++;
    if (currentZoomIndex == zoomLevels.length) {
      currentZoomIndex == 0;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    pp('$mm onViewFinderTap distance: ${offset.distance}  distanceSquared: ${offset.distanceSquared} ');
    //offset.scale(2.0, 2.0);
    pp('$mm onViewFinderTap .... zoom level: $zoomLevel ');
    if (_cameraController != null) {
      _cameraController!.setExposurePoint(offset);
      _cameraController!.setFocusPoint(offset);
      //_cameraController!.setZoomLevel(zoomLevel);
    }
    setState(() {});

    var maxZoomLevel = await _cameraController!.getMaxZoomLevel();
    // just calling it dragIntensity for now, you can call it whatever you like.
    var dragIntensity = 9.0;
    if (dragIntensity < 1) {
      // 1 is the minimum zoom level required by the camController's method, hence setting 1 if the user zooms out (less than one is given to details when you zoom-out/pinch-in).
      _cameraController!.setZoomLevel(1);
    } else if (dragIntensity > 1 && dragIntensity < maxZoomLevel) {
      // self-explanatory, that if the maxZoomLevel exceeds, you will get an error (greater than one is given to details when you zoom-in/pinch-out).
      _cameraController!.setZoomLevel(dragIntensity);
    } else {
      // if it does exceed, you can provide the maxZoomLevel instead of dragIntensity (this block is executed whenever you zoom-in/pinch-out more than the max zoom level).
      _cameraController!.setZoomLevel(maxZoomLevel);
    }
  }

  void _onNewCameraSelected(CameraDescription cameraDescription) async {
    pp('$mm onNewCameraSelected .... cameraDescription: ${cameraDescription.name} ${cameraDescription.lensDirection}');
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    pp('$mm onNewCameraSelected .... setting up new cameraController with camera description');

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // If the controller is updated then update the UI.
    _cameraController!.addListener(() {
      if (mounted) setState(() {});
      if (_cameraController!.value.hasError) {
        showInSnackBar(
            'Camera error ${_cameraController!.value.errorDescription}');
      }
    });

    try {
      await _cameraController!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  // final List<File> _imageFiles = [];
  late StreamSubscription orientStreamSubscription;
  NativeDeviceOrientation? _deviceOrientation;

  Future<void> _observeOrientation() async {
    pp('${Emoji.blueDot} ........ _observeOrientation ... ');
    Stream<NativeDeviceOrientation> stream =
        NativeDeviceOrientationCommunicator()
            .onOrientationChanged(useSensor: true);
    orientStreamSubscription = stream.listen((event) {
      pp('${Emoji.blueDot}${Emoji.blueDot} orientation, name: ${event.name} 🔵 index: ${event.index}');
      _deviceOrientation = event;
      switch (_deviceOrientation!.name) {
        case 'landscapeLeft':
          if (mounted) {
            setState(() {
              landscapeLeft = true;
              landscapeRight = false;
            });
          }
          break;
        case 'landscapeRight':
          if (mounted) {
            setState(() {
              landscapeRight = true;
              landscapeLeft = false;
            });
          }
          break;
        case 'portraitUp':
          if (mounted) {
            setState(() {
              landscapeRight = false;
              landscapeLeft = false;
            });
          }
          break;
        case 'portraitDown':
          if (mounted) {
            setState(() {
              landscapeRight = false;
              landscapeLeft = false;
            });
          }
          break;
      }
    });
  }

  bool landscapeLeft = false;
  bool landscapeRight = false;
  Future<File> _getVideoThumbnail(File file) async {
    final Directory directory = await getApplicationDocumentsDirectory();

    var path = 'possibleVideoThumb.${DateTime.now().toIso8601String()}.jpg';
    final thumbFile = File('${directory.path}/$path');

    final data = await vt.VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: vt.ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    await thumbFile.writeAsBytes(data!);
    pp('$mm Video thumbnail created. length: ${await thumbFile.length()} 🔷🔷🔷');
    return thumbFile;
  }

  Future<File> _getThumbnail(
      {required File file, required bool isVideo}) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    if (isVideo) {
      var m = _getVideoThumbnail(file); //path to asset
      return m;
    }

    img.Image? image = img.decodeImage(file.readAsBytesSync());
    var thumbnail = img.copyResize(image!, width: 160);
    final File mFile = File(
        '${directory.path}/thumbnail${DateTime.now().millisecondsSinceEpoch}.jpg');
    var thumb = mFile..writeAsBytesSync(img.encodeJpg(thumbnail, quality: 90));
    var len = await thumb.length();
    pp('$mm ....... 💜 .... thumbnail generated: 😡 ${(len / 1024).toStringAsFixed(1)} KB');
    return thumb;
  }

  void _onVideoRecordButtonPressed() {
    pp('$mm onVideoRecordButtonPressed 🥏 🥏 🥏 ....');
    _startVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  bool videoIsReadyToPlay = false;
  void _onStopButtonPressed() {
    pp('$mm onStopButtonPressed 🥏 🥏 🥏 call stopVideoRecording ....');
    _stopVideoRecording().then((file) async {
      if (mounted) setState(() {});
      if (file != null) {
        var length = await file.length();
        pp('$mm onStopButtonPressed 🥏 🥏 🥏 maybe we should start uploading the video file ...');
        showInSnackBar(
            'Video has been recorded; length: ${length / 1024 / 1024} MB ');
        videoFile = file;
        var mFile = File(file.path);
        var thumb = await _getThumbnail(file: mFile, isVideo: true);

        //_startVideoPlayer();
        cloudStorageBloc.uploadPhotoOrVideo(
            listener: this,
            file: mFile,
            thumbnailFile: thumb,
            project: widget.project,
            projectPositionId: widget.projectPosition.projectPositionId!,
            projectPosition: widget.projectPosition.position!,
            isVideo: true,
            isLandscape: false);
      }
    });
  }

  Future<void> _onPausePreviewButtonPressed() async {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isPreviewPaused) {
      await cameraController.resumePreview();
    } else {
      await cameraController.pausePreview();
    }

    if (mounted) setState(() {});
  }

  void _onPauseButtonPressed() {
    pp('$mm onPauseButtonPressed 🥏 🥏 🥏 ');
    _pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    });
  }

  void _onResumeButtonPressed() {
    _resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    });
  }

  Future<void> _startVideoRecording() async {
    pp('$mm startVideoRecording 🥏 🥏 🥏  ....');
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: please select a camera first.');
      return;
    }
    pp('$mm startVideoRecording ....');
    if (cameraController.value.isRecordingVideo) {
      pp('$mm startVideoRecording .... A recording is already started, do nothing.');
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> _stopVideoRecording() async {
    final CameraController? cameraController = _cameraController;
    pp('$mm stopVideoRecording ....');
    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }
    pp('$mm stopVideoRecording ....');
    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> _pauseVideoRecording() async {
    final CameraController? cameraController = _cameraController;
    pp('$mm pauseVideoRecording ....');
    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _resumeVideoRecording() async {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }
    pp('$mm resumeVideoRecording ....');
    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  String? totalByteCount, bytesTransferred;
  String? fileUrl, thumbnailUrl;

  @override
  onFileProgress(int totalByteCount, int bytesTransferred) {
    pp('$mm 🍏file Upload progress: bytesTransferred: ${(bytesTransferred / 1024).toStringAsFixed(1)} KB '
        'of totalByteCount: ${(totalByteCount / 1024).toStringAsFixed(1)} KB');
    setState(() {
      this.totalByteCount = '${(totalByteCount / 1024).toStringAsFixed(1)} KB';
      this.bytesTransferred =
          '${(bytesTransferred / 1024).toStringAsFixed(1)} KB';
    });
  }

  @override
  onFileUploadComplete(String url, int totalByteCount, int bytesTransferred) {
    pp('$mm 🍏😡 file Upload has been completed 😡 bytesTransferred: ${(bytesTransferred / 1024).toStringAsFixed(1)} KB '
        'of totalByteCount: ${(totalByteCount / 1024).toStringAsFixed(1)} KB');
    pp('$mm 😡😡😡 this file url should be saved in DB .... 😡😡 $url 😡😡');
    if (mounted) {
      setState(() {});
    }
  }

  @override
  onThumbnailProgress(int totalByteCount, int bytesTransferred) {
    pp('$mm 🍏thumbnail Upload progress: bytesTransferred: ${(bytesTransferred / 1024).toStringAsFixed(1)} KB '
        'of totalByteCount: ${(totalByteCount / 1024).toStringAsFixed(1)} KB');
  }

  @override
  onThumbnailUploadComplete(
      String url, int totalByteCount, int bytesTransferred) async {
    pp('$mm 🍏thumbnail Upload has been completed 😡 bytesTransferred: ${(bytesTransferred / 1024).toStringAsFixed(1)} KB '
        'of totalByteCount: ${(totalByteCount / 1024).toStringAsFixed(1)} KB');
    setState(() {});
  }

  Video? _currentVideo;

  void _navigateToPlayer() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: PlayVideo(
              video: _currentVideo!,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Video Camera',
            style: GoogleFonts.lato(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
              onPressed: onListButtonPressed, icon: const Icon(Icons.list)),
        ],
      ),
      body: Stack(
        children: [
          landscapeLeft || landscapeRight? RotatedBox(
            quarterTurns: landscapeLeft? 1: 3,
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                child: SizedBox(height: 140, child: Column(
                  children:  [
                    const SizedBox(height: 24,),
                    Text('Careful Now!', style: GoogleFonts.lato(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      fontWeight: FontWeight.w900,
                    )),
                    const SizedBox(height: 12,),
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('You should keep your device in portrait mode to capture video!'),
                    ),
                  ],
                ),),
              ),
            ),
          ): Column(
            children: <Widget>[
              Container(
                height: 4,
                color: Colors.teal,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: _cameraController != null
                          ? Colors.redAccent
                          : Colors.teal,
                      width: 3.0,
                    ),
                  ),
                  child: Center(
                    child: _cameraPreviewWidget(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.videocam),
                    color: Colors.blue,
                    onPressed: _cameraController != null &&
                            _cameraController!.value.isInitialized &&
                            !_cameraController!.value.isRecordingVideo
                        ? _onVideoRecordButtonPressed
                        : null,
                  ),
                  IconButton(
                    icon: _cameraController != null &&
                            _cameraController!.value.isRecordingPaused
                        ? const Icon(Icons.play_arrow)
                        : const Icon(Icons.pause),
                    color: Colors.blue,
                    onPressed: _cameraController != null &&
                            _cameraController!.value.isInitialized &&
                            _cameraController!.value.isRecordingVideo
                        ? (_cameraController!.value.isRecordingPaused)
                            ? _onResumeButtonPressed
                            : _onPauseButtonPressed
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    color: Colors.red,
                    onPressed: _cameraController != null &&
                            _cameraController!.value.isInitialized &&
                            _cameraController!.value.isRecordingVideo
                        ? _onStopButtonPressed
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause_presentation),
                    color: _cameraController != null &&
                            _cameraController!.value.isPreviewPaused
                        ? Colors.red
                        : Colors.blue,
                    onPressed: _cameraController == null
                        ? null
                        : _onPausePreviewButtonPressed,
                  ),
                ],
              ),
              // _modeControlRowWidget(),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _thumbnailWidget(),
                  ],
                ),
              ),
            ],
          ),
          _showPlayUI
              ? Positioned(
                  bottom: 72,
                  left: 48,
                  child: SizedBox(
                    height: 160,
                    child: PlayVideoCard(
                        onPlayVideo: onPlayVideo, onClose: onClose),
                  ))
              : const SizedBox(),
        ],
      ),
    );
  }

  void onListButtonPressed() {
    pp('$mm onListButtonPressed ...');
    Navigator.of(context).pop();
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRightWithFade,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1500),
            child: MediaListMain(project: widget.project)));
  }

  late Isolate isolate;
  late ReceivePort receivePort = ReceivePort();
  double _elapsedSeconds = 0.0;
  bool _isUploading = false;

  Future<File> _processOrientation(
      File file, NativeDeviceOrientation deviceOrientation) async {
    pp('$mm _processOrientation: attempt to rotate image file ...');
    switch (deviceOrientation.name) {
      case 'landscapeLeft':
        pp('$mm landscapeLeft ....');
        break;
      case 'landscapeRight':
        pp('$mm landscapeRight ....');
        break;
      case 'portraitUp':
        return file;
      case 'portraitDown':
        return file;
    }
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    final File mFile = File(
        '${appDocumentDirectory.path}/rotatedImageFile${DateTime.now().millisecondsSinceEpoch}.jpg');

    final img.Image? capturedImage = img.decodeImage(await file.readAsBytes());
    var orientedImage = img.copyRotate(capturedImage!, angle: 270);

    await File(mFile.path).writeAsBytes(img.encodeJpg(orientedImage));

    final heightOrig = capturedImage.height;
    final widthOrig = capturedImage.width;

    final height = orientedImage.height;
    final width = orientedImage.width;

    pp('$mm _processOrientation: rotated file has 😡height: $height 😡width: $width, 🔵 '
        'original file size: height: $heightOrig width: $widthOrig');
    return mFile;
  }

  Future<void> _createIsolate(
      {required File file,
      required File thumbnailFile,
      required Project project,
      required bool isVideo,
      required ProjectPosition projectPosition,
      required NativeDeviceOrientation deviceOrientation}) async {
    try {
      var start = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        _isUploading = true;
      });
      String? token = await AppAuth.getAuthToken();
      String? url;
      pp('🐤🐤🐤🐤 Getting url via .env settings: ${url ?? 'NO URL YET'}');
      String? status = dot.dotenv.env['CURRENT_STATUS'];
      pp('🐤🐤🐤🐤 DataAPI: getUrl: Status from .env: $status');
      if (status == 'dev') {
        url = dot.dotenv.env['DEV_URL'];
        pp('$mm Status of the app is  DEVELOPMENT 🌎 🌎 🌎 $url');
      } else {
        url = dot.dotenv.env['PROD_URL'];
        pp('$mm Status of the app is PRODUCTION 🌎 🌎 🌎 $url');
      }
      file = await _processOrientation(file, deviceOrientation);
      receivePort = ReceivePort();
      var errorReceivePort = ReceivePort();
      var user = await Prefs.getUser();
      var distance = await locationBloc.getDistanceFromCurrentPosition(
          latitude: projectPosition.position!.coordinates[1],
          longitude: projectPosition.position!.coordinates[0]);
      UploadParameters params = UploadParameters(
        sendPort: receivePort.sendPort,
        file: file,
        thumbnailFile: thumbnailFile,
        project: project,
        projectPosition: projectPosition,
        isVideo: isVideo,
        deviceOrientation: deviceOrientation,
        urlPrefix: url!,
        user: user!,
        token: token!,
        distanceFromProjectPosition: distance,
      );

      //create channel for comms
      IsolateChannel channel =
          IsolateChannel(receivePort, receivePort.sendPort);
      channel.stream.listen((data) async {
        if (data != null) {
          if (data is String) {
            if (data == 'stop') {
              isolate.kill();
              p('${Emoji.blueDot} ${Emoji.blueDot} ${Emoji.blueDot} '
                  'isolate killed after channel received STOP message '
                  '{Emoji.blueDot} ${Emoji.blueDot} ${Emoji.blueDot} ${Emoji.redDot}');
              // sendFinishedMessage();
            }
          } else {
            switch (data['statusCode']) {
              case uploadBusy:
                p('${Emoji.heartBlue}${Emoji.heartBlue} Channel received a ${Emoji.redDot} UPLOAD_BUSY '
                    'message: ${data['message']}');
                break;

              case uploadFinished:
                p('${Emoji.heartBlue}${Emoji.heartBlue} Channel received a ${Emoji.redDot} UPLOAD_FINISHED '
                    'message ');
                isolate.kill();
                var end = DateTime.now().millisecondsSinceEpoch;
                var ms = end - start;
                _elapsedSeconds = ms / 1000;
                p('${Emoji.leaf} ${Emoji.redDot}${Emoji.redDot}${Emoji.redDot} isolate has been killed!');
                if (mounted) {
                  setState(() {
                    _isUploading = false;
                  });
                }
                if (mounted) {
                  // _animationController.reset();
                  // _animationController.forward();
                }
                break;
            }
          }
        }
      });

      pp('$mm spawning isolate ...');
      isolate = await Isolate.spawn<UploadParameters>(heavyTask, params,
          paused: true,
          onError: errorReceivePort.sendPort,
          onExit: receivePort.sendPort);

      isolate.addErrorListener(errorReceivePort.sendPort);
      isolate.resume(isolate.pauseCapability!);
      isolate.addOnExitListener(receivePort.sendPort);

      errorReceivePort.listen((e) {
        p('$mm ${Emoji.redDot}${Emoji.redDot} FieldVideoCamera: errorReceivePort: exception occurred: $e');
      });
    } catch (e) {
      p('$mm ${Emoji.redDot} we have a problem ${Emoji.redDot} ${Emoji.redDot}');
    }
  }

  @override
  onError(String message) {
    throw UnimplementedError();
  }

  String? url;
  bool _showPlayUI = false;

  onPlayVideo() {
    pp('$mm onPlayVideo navigate to player ...🔵🔵');
    _navigateToPlayer();
  }

  onClose() {
    pp('$mm onClose - close ui ...');
    setState(() {
      _showPlayUI = false;
    });
  }

  @override
  onVideoReady(Video video) {
    setState(() {
      _currentVideo = video;
      _showPlayUI = true;
    });
  }
}

List<CameraDescription> cameras = [];

class UploadParameters {
  late SendPort sendPort;
  late File file;
  late File thumbnailFile;
  late Project project;
  late ProjectPosition projectPosition;
  late bool isVideo;
  late String urlPrefix, token;
  late User user;
  late double distanceFromProjectPosition;
  late NativeDeviceOrientation deviceOrientation;

  UploadParameters(
      {required this.sendPort,
      required this.file,
      required this.thumbnailFile,
      required this.project,
      required this.projectPosition,
      required this.isVideo,
      required this.deviceOrientation,
      required this.urlPrefix,
      required this.token,
      required this.user,
      required this.distanceFromProjectPosition});
}

heavyTask(UploadParameters parameters) async {
  //cloudStorageBloc.uploadPhotoOrVideo(parameters);
}

class UploadMessage {
  late int statusCode;
  late String message;
  late String fileUrl, thumbnailUrl;
  int totalBytes = 0;
  int bytesTransferred = 0;

  UploadMessage(
      {required this.statusCode,
      required this.message,
      required this.totalBytes,
      required this.bytesTransferred,
      required this.fileUrl,
      required this.thumbnailUrl});

  UploadMessage.fromJson(Map data) {
    statusCode = data['statusCode'];
    message = data['message'];
    fileUrl = data['fileUrl'];
    thumbnailUrl = data['thumbnailUrl'];
    totalBytes = data['totalBytes'];
    bytesTransferred = data['bytesTransferred'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'statusCode': statusCode,
      'message': message,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'totalBytes': totalBytes,
      'bytesTransferred': bytesTransferred,
    };
    return map;
  }
}

class PlayVideoCard extends StatelessWidget {
  const PlayVideoCard(
      {Key? key, required this.onPlayVideo, required this.onClose})
      : super(key: key);
  final Function() onPlayVideo;
  final Function() onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        // color: Colors.teal,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        onClose();
                      },
                      icon: const Icon(Icons.close)),
                ],
              ),
              Text('Video is ready for review',
                  style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.bodySmall,
                    fontWeight: FontWeight.normal,
                  )),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: () {
                    onPlayVideo();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Play Video'),
                  )),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
