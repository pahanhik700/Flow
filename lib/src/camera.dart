import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';


//class CameraScreen extends StatefulWidget {
//  const CameraScreen({
//    super.key,
//    required this.camera,
//  });
//
//  final CameraDescription camera;
//
//  @override
//  State<CameraScreen> createState() => _CameraScreenState();
//}
//
//class _CameraScreenState extends State<CameraScreen> {
//  late CameraController _cameraController;
//  late Future<void> _initializeControllerFuture;
//
//  @override
//  void initState() {
//    _cameraController = CameraController(widget.camera, ResolutionPreset.ultraHigh,
//        imageFormatGroup: ImageFormatGroup.jpeg, enableAudio: false);
//    _initializeControllerFuture = _cameraController.initialize();
//    super.initState();
//  }
//
//  @override
//  void dispose() {
//    _cameraController.dispose();
//    super.dispose();
//  }
//
//  Future<void> _initCamera() async {
//    cameras = await availableCameras();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(title: const Text('Take a picture')),
//      body: FutureBuilder<void>(
//        future: _initializeControllerFuture,
//        builder: (context, snapshot) {
//          if (snapshot.connectionState == ConnectionState.done) {
//            return Center(child: CameraPreview(_cameraController));
//          } else {
//            return const Center(child: CircularProgressIndicator());
//          }
//        },
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () async {
//          try {
//            await _initializeControllerFuture;
//
//            final image = await _cameraController.takePicture();
//
//            if (!mounted) return;
//
//            await Navigator.of(context).push(
//              MaterialPageRoute(
//                builder: (context) => DisplayPictureScreen(
//                  imagePath: image.path,
//                ),
//              ),
//            );
//          } catch (e) {
//            print(e);
//          }
//        },
//        child: const Icon(Icons.camera_alt),
//      ),
//    );
//  }
//}
//class DisplayPictureScreen extends StatelessWidget {
//  final String imagePath;
//
//  const DisplayPictureScreen({super.key, required this.imagePath});
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(title: const Text('Display the Picture')),
//      // The image is stored as a file on the device. Use the `Image.file`
//      // constructor with the given path to display the image.
//      body: Center(child: Image.file(File(imagePath))),
//    );
//  }
//}


