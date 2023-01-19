import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:developer' as debug;

class OcrManager {
  static Future<String> scanText(CameraImage availableImage) async {
    debug.log("scanning!...");

    final InputImageData metadata = InputImageData(
        inputImageFormat: InputImageFormat.yuv420,
        size: Size(
            availableImage.width.toDouble(), availableImage.height.toDouble()),
        planeData: availableImage.planes
            .map((currentPlane) => InputImagePlaneMetadata(
                bytesPerRow: currentPlane.bytesPerRow,
                height: currentPlane.height,
                width: currentPlane.width))
            .toList(),
        imageRotation: InputImageRotation.rotation90deg);

    final InputImage visionImage = InputImage.fromBytes(
        bytes: Uint8List.fromList(
          availableImage.planes.fold(
              <int>[],
              (List<int> previousValue, element) =>
                  previousValue..addAll(element.bytes)),
        ),
        inputImageData: metadata);

    final textRecognizer = TextRecognizer();
    final RecognizedText visionText =
        await textRecognizer.processImage(visionImage);

    debug.log("--------------------visionText:${visionText.text}");
    for (TextBlock block in visionText.blocks) {
      // final Rectangle<int> boundingBox = block.boundingBox;
      // final List<Point<int>> cornerPoints = block.cornerPoints;
      debug.log(block.text);
      //final List<RecognizedLanguage> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        debug.log(line.text);
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
          debug.log(element.text);
        }
      }
    }

    return visionText.text;
  }

  Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (var plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  InputImageData buildMetaData(CameraImage image) {
    return InputImageData(
      inputImageFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      imageRotation: InputImageRotation.rotation90deg,
      planeData: image.planes.map((Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      }).toList(),
    );
  }
}
