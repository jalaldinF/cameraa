import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cameraa/utils/ocr_manager.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as debug;

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  bool isInitialized = false;
  CameraImage? cameraImage;
  bool isScanBusy = false;
  late Timer timer;
  String datee = 'No DATA';
  bool isLight = false;
  FlashMode flashMode = FlashMode.off;
  bool isFlashlightAvailbale = false;

  @override
  void dispose() {
    isInitialized = false;
    cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initCamera();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !isInitialized
        ? Container()
        : Scaffold(
            body: Stack(
              children: [
                CameraPreview(cameraController),
                Positioned(
                  top: 100,
                  left: 60,
                  child: ElevatedButton(
                      onPressed: () async {
                        // cameraController
                        //     .startImageStream((image) => cameraImage = image);
                        // if (!isScanBusy) {
                        //   isScanBusy = true;
                        //   OcrManager.scanText(cameraImage!)
                        //       .then((value) => debug.log(value));
                        //   isScanBusy = false;
                        // }   if (!isScanBusy) {
                        timer = Timer.periodic(const Duration(seconds: 3),
                            (currentTimer) async {
                          if (isScanBusy) {
                            debug.log("1.5 -------- isScanBusy, skipping...");
                            return;
                          }

                          debug.log("1 -------- isScanBusy = true");
                          isScanBusy = true;
                          if (cameraImage!.planes.isNotEmpty) {
                            OcrManager.scanText(cameraImage!)
                                .then((textVision) {
                              debug.log(textVision);
                              setState(() {
                                datee = textVision;
                              });

                              isScanBusy = false;
                            }).catchError((error) {
                              isScanBusy = false;
                            });
                          }
                        });

                        // OcrManager.scanText(cameraImage!)
                        //     .then((value) => debug.log('$value'));
                      },
                      child: const Text("Get Data")),
                ),
                Positioned(
                    top: 500,
                    left: 150,
                    child: Text(
                      datee,
                      style: const TextStyle(color: Colors.red, fontSize: 25),
                    )),
                Positioned(
                    top: 100,
                    left: 180,
                    child: ElevatedButton(
                      onPressed: () {
                        eneableLight();

                        // if (!isLight) {
                        //   setState(() {
                        //     flashMode = FlashMode.torch;
                        //     isLight = !isLight;
                        //   });
                        //   debug.log(
                        //       'Flash mode is $flashMode  Lisht is $isLight');
                        // } else {
                        //   setState(() {
                        //     flashMode = FlashMode.off;
                        //     isLight = !isLight;
                        //     debug.log(
                        //         'Flash mode is $flashMode  Lisht is $isLight');
                        //   });
                        // }
                        // await cameraController.setFlashMode(flashMode);
                      },
                      child: const Icon(Icons.electric_bolt),
                    )),
              ],
            ),
          );
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    cameraController.setFocusPoint(const Offset(55.5, 55.5));
    cameraController.initialize().then((value) {
      isInitialized = true;
      flashMode = cameraController.value.flashMode;
      cameraController.startImageStream(
        (image) => cameraImage = image,
      );

      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  eneableLight() async {
    if (!isLight) {
      setState(() {
        flashMode = FlashMode.torch;
        isLight = !isLight;
      });
      debug.log('Flash mode is $flashMode  Lisht is $isLight');
    } else {
      setState(() {
        flashMode = FlashMode.off;
        isLight = !isLight;
        debug.log('Flash mode is $flashMode  Lisht is $isLight');
      });
    }
    await cameraController.setFlashMode(flashMode);
  }
}
