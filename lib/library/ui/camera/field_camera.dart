// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_router/library/ui/media/list/media_list_main.dart';
import 'package:video_player/video_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../api/storage_bloc.dart';
import '../../data/project.dart';
import '../../data/project_position.dart';
import '../../functions.dart';
import '../../generic_functions.dart';

class FieldCamera extends StatefulWidget {
  final Project project;
  final ProjectPosition projectPosition;

  const FieldCamera({super.key, required this.project, required this.projectPosition});


  @override
  FieldCameraState createState() {
    return FieldCameraState();
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

class FieldCameraState extends State<FieldCamera>
    with WidgetsBindingObserver, TickerProviderStateMixin
    implements StorageBlocListener {
  CameraController? _cameraController;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;

  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;
  late AnimationController _focusModeControlRowAnimationController;
  late Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  static const mm = '🍎🍎🍎 FieldCamera 🍎 : ';

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    pp('$mm initState ....');
    //_ambiguate(WidgetsBinding.instance)?.addObserver(this);
    _getCameras();

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    //_ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
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
  bool _showGrid = false;
  final List<StorageMediaBag> _mediaBags = [];

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
                                       localVideoController
                                              .value.aspectRatio,

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
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  !cameraController.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          color: Colors.blue,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  !cameraController.value.isRecordingVideo
              ? onVideoRecordButtonPressed
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
                  ? onResumeButtonPressed
                  : onPauseButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  cameraController.value.isRecordingVideo
              ? onStopButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.pause_presentation),
          color:
              cameraController != null && cameraController.value.isPreviewPaused
                  ? Colors.red
                  : Colors.blue,
          onPressed:
              cameraController == null ? null : onPausePreviewButtonPressed,
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

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    pp('$mm onViewFinderTap ....');
    if (_cameraController == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    if (_cameraController != null) {
      _cameraController!.setExposurePoint(offset);
      _cameraController!.setFocusPoint(offset);
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
      await Future.wait([
        _cameraController!
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        _cameraController!
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        _cameraController!
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        _cameraController!
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  final List<File> _imageFiles = [];
  void onTakePictureButtonPressed() {
    pp('$mm ... onTakePictureButtonPressed ....');
    takePicture().then((XFile? file) async {
      if (videoController != null) {
        videoController!.dispose();
        videoController = null;
      }
      if (mounted) {
        setState(() {
          imageFile = file;
        });
        if (file != null) {
          pp('$mm onTakePictureButtonPressed 🔵🔵🔵 file saved: ${file.path} 🔵');
          File mImageFile = File(file.path);
          pp('$mm onTakePictureButtonPressed 🔵🔵🔵 file to upload, size: ${await mImageFile.length()} bytes🔵');
          _imageFiles.add(mImageFile);
          pp('$mm onTakePictureButtonPressed 🔵🔵🔵 files to upload: ${_imageFiles.length} bytes🔵');
          var thumbnailFile = await getThumbnail(mImageFile);

          storageBloc.uploadPhotoOrVideo(
              listener: this,
              file: mImageFile,
              thumbnailFile: thumbnailFile,
              project: widget.project,
              projectPosition: widget.projectPosition.position!,
              projectPositionId: widget.projectPosition.projectPositionId!,
              isVideo: false);

          showToast(
              context: context,
              message: 'Picture file saved',
              backgroundColor: Colors.teal,
              textStyle: Styles.whiteSmall,
              toastGravity: ToastGravity.TOP,
              duration: const Duration(seconds: 2));

          var mediaBag = StorageMediaBag(
              url: '',
              thumbnailUrl: '',
              isVideo: false,
              file: mImageFile,
              date: getFormattedDate(DateTime.now().toString()),
              thumbnailFile: thumbnailFile);
          _mediaBags.add(mediaBag);
          setState(() {});
        }
      }
    });
  }

  Future<File> getThumbnail(File file) async {
    img.Image? image = img.decodeImage(file.readAsBytesSync());
    var thumbnail = img.copyResize(image!, width: 160);
    final Directory directory = await getApplicationDocumentsDirectory();
    final File mFile = File(
        '${directory.path}/thumbnail${DateTime.now().millisecondsSinceEpoch}.jpg');
    var thumb = mFile..writeAsBytesSync(img.encodeJpg(thumbnail, quality: 90));
    var len = await thumb.length();
    pp('$mm ....... 💜  .... thumbnail generated: 😡 ${(len / 1024).toStringAsFixed(1)} KB');
    return thumb;
  }
  //
  // void onFlashModeButtonPressed() {
  //   pp('$mm onFlashModeButtonPressed ....');
  //   if (_flashModeControlRowAnimationController.value == 1) {
  //     _flashModeControlRowAnimationController.reverse();
  //   } else {
  //     _flashModeControlRowAnimationController.forward();
  //     _exposureModeControlRowAnimationController.reverse();
  //     _focusModeControlRowAnimationController.reverse();
  //   }
  // }
  //
  // void onExposureModeButtonPressed() {
  //   if (_exposureModeControlRowAnimationController.value == 1) {
  //     _exposureModeControlRowAnimationController.reverse();
  //   } else {
  //     _exposureModeControlRowAnimationController.forward();
  //     _flashModeControlRowAnimationController.reverse();
  //     _focusModeControlRowAnimationController.reverse();
  //   }
  // }
  //
  // void onFocusModeButtonPressed() {
  //   if (_focusModeControlRowAnimationController.value == 1) {
  //     _focusModeControlRowAnimationController.reverse();
  //   } else {
  //     _focusModeControlRowAnimationController.forward();
  //     _flashModeControlRowAnimationController.reverse();
  //     _exposureModeControlRowAnimationController.reverse();
  //   }
  // }
  //
  // void onAudioModeButtonPressed() {
  //   enableAudio = !enableAudio;
  //   if (controller != null) {
  //     _onNewCameraSelected(controller!.description);
  //   }
  // }
  //
  // void onCaptureOrientationLockButtonPressed() async {
  //   if (controller != null) {
  //     final CameraController cameraController = controller!;
  //     if (cameraController.value.isCaptureOrientationLocked) {
  //       await cameraController.unlockCaptureOrientation();
  //       showInSnackBar('Capture orientation unlocked');
  //     } else {
  //       await cameraController.lockCaptureOrientation();
  //       showInSnackBar(
  //           'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
  //     }
  //   }
  // }
  //
  // void onSetFlashModeButtonPressed(FlashMode mode) {
  //   setFlashMode(mode).then((_) {
  //     if (mounted) setState(() {});
  //     showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
  //   });
  // }
  //
  // void onSetExposureModeButtonPressed(ExposureMode mode) {
  //   setExposureMode(mode).then((_) {
  //     if (mounted) setState(() {});
  //     showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
  //   });
  // }
  //
  // void onSetFocusModeButtonPressed(FocusMode mode) {
  //   setFocusMode(mode).then((_) {
  //     if (mounted) setState(() {});
  //     showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
  //   });
  // }

  void onVideoRecordButtonPressed() {
    pp('$mm onVideoRecordButtonPressed 🥏 🥏 🥏 ....');
    startVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  void onStopButtonPressed() {
    pp('$mm onStopButtonPressed 🥏 🥏 🥏 call stopVideoRecording ....');
    stopVideoRecording().then((file) {
      if (mounted) setState(() {});
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        _startVideoPlayer();
      }
    });
  }

  Future<void> onPausePreviewButtonPressed() async {
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

  void onPauseButtonPressed() {
    pp('$mm onPauseButtonPressed 🥏 🥏 🥏 ');
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    pp('$mm startVideoRecording 🥏 🥏 🥏  ....');
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
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

  Future<XFile?> stopVideoRecording() async {
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

  Future<void> pauseVideoRecording() async {
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

  Future<void> resumeVideoRecording() async {
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

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }
    pp('$mm _startVideoPlayer .... 🥏 🥏 🥏 🥏 ');
    final VideoPlayerController vController =
        VideoPlayerController.file(File(videoFile!.path));
    videoPlayerListener = () {
      if (videoController != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    pp('$mm takePicture  🔵 ');
    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      pp('$mm takePicture:  🔵  🔵  🔵  file saved: ${file.path}  🔵 ');
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
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

  @override
  onError(String message) {
    showToast(
        message: message,
        context: context,
        backgroundColor: Colors.red,
        textStyle: Styles.whiteBoldSmall,
        duration: const Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Field Camera',style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.bodyMedium,
            fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: onListButtonPressed, icon: const Icon(Icons.list)),
        ],
      ),
      body: Stack(
        children: [
          _showGrid
              ? Container()
              : Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: _cameraController != null || _cameraController!.value.isRecordingVideo
                          ? Colors.redAccent
                          : Colors.grey,
                      width: 3.0,
                    ),
                  ),
                  child: Center(
                    child: _cameraPreviewWidget(),
                  ),
                ),
              ),
              _captureControlRowWidget(),
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
          _showGrid
              ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1),
            itemCount: _mediaBags.length,
            itemBuilder: (BuildContext context, int index) {
              var item = _mediaBags.elementAt(index);
              return SizedBox(
                height: 180,
                width: 180,
                child: item.isVideo
                    ? Image.asset(
                  'assets/video3.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.fill,
                )
                    : Image.file(
                  item.thumbnailFile!,
                  fit: BoxFit.fill,
                ),
              );
            },
          )
              : Container(),
          Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showGrid = !_showGrid;
                  });
                },
                child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.teal),
                    child: Center(
                      child: Text('${_mediaBags.length}',
                          style: Styles.whiteSmall),
                    )),
              )),
        ],
      ),
    );
  }


  void onListButtonPressed() {
    pp('$mm onListButtonPressed ...');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRightWithFade,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1500),
            child: MediaListMain(project: widget.project)));
  }
}

List<CameraDescription> cameras = [];

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
// TODO(ianh): Remove this once we roll stable in late 2021.
//T? _ambiguate<T>(T? value) => value;
