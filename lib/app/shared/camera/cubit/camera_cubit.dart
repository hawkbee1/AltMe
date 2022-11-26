// import 'dart:ui';

import 'package:altme/app/app.dart';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:json_annotation/json_annotation.dart';

part 'camera_cubit.g.dart';
part 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  CameraCubit({
    required this.defaultConfig,
  }) : super(const CameraState());

  final CameraConfig defaultConfig;

  final logger = getLogger('CameraCubit');
  CameraController? cameraController;
  // FaceDetector? _faceDetector;

  Future<void> getCameraController() async {
    emit(state.copyWith(status: CameraStatus.initializing));
    final List<CameraDescription> cameras = await availableCameras();

    if (cameras.isEmpty) {
      emit(state.copyWith(status: CameraStatus.initializeFailed));
      return;
    }

    CameraDescription? _selectedCamera = cameras[0];
    try {
      if (defaultConfig.frontCameraAsDefault) {
        _selectedCamera = cameras.firstWhere(
          (description) =>
              description.lensDirection == CameraLensDirection.front,
        );
      } else {
        _selectedCamera = cameras.firstWhere(
          (description) =>
              description.lensDirection == CameraLensDirection.back,
        );
      }
    } catch (e, s) {
      emit(state.copyWith(status: CameraStatus.initializeFailed));
      logger.e('error: $e, stack: $s', e, s);
    }
    cameraController = CameraController(
      _selectedCamera ?? cameras[0],
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.yuv420,
      enableAudio: false,
    );
    await cameraController!.initialize();
    // _faceDetector = FaceDetector(
    //   options: FaceDetectorOptions(
    //     performanceMode: FaceDetectorMode.accurate,
    //     enableContours: true,
    //     enableLandmarks: true,
    //     enableClassification: true,
    //     enableTracking: true,
    //   ),
    // );

    // ignore: unawaited_futures
    // cameraController!.startImageStream(_startImageStream);

    emit(state.copyWith(status: CameraStatus.intialized));
  }

  Future<void> takePhoto() async {
    try {
      //await cameraController!.stopImageStream();
      final xFile = await cameraController!.takePicture();
      final photoCaptured = (await xFile.readAsBytes()).toList();
      final fixedImageBytes =
          img.encodeJpg(img.flipHorizontal(img.decodeImage(photoCaptured)!));
      emit(
        state.copyWith(
          status: CameraStatus.imageCaptured,
          data: fixedImageBytes,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(status: CameraStatus.error));
      logger.e('error : $e, stack: $s');
    }
  }

  Future<void> deleteCapturedImage() async {
    emit(state.copyWith(status: CameraStatus.intialized));
    // ignore: unawaited_futures
    // cameraController!.startImageStream(_startImageStream);
  }

  // void _startImageStream(CameraImage image) {
  //   final _firebaseImageMetadata = InputImageData(
  //     imageRotation: rotationIntToImageRotation(
  //       cameraController!.description.sensorOrientation,
  //     ),
  //     inputImageFormat:
  //         InputImageFormatValue.fromRawValue(image.format.raw as int) ??
  //             InputImageFormat.nv21,
  //     size: Size(image.width.toDouble(), image.height.toDouble()),
  //     planeData: image.planes.map(
  //       (Plane plane) {
  //         return InputImagePlaneMetadata(
  //           bytesPerRow: plane.bytesPerRow,
  //           height: plane.height,
  //           width: plane.width,
  //         );
  //       },
  //     ).toList(),
  //   );

  //   final InputImage inputImage = InputImage.fromBytes(
  //     bytes: image.planes[0].bytes,
  //     inputImageData: _firebaseImageMetadata,
  //   );
  //   try {
  //     _faceDetector!.processImage(inputImage).then((faces) {
  //       logger.i('facesLenght: ${faces.length}');
  //       // TODO(Taleb): here enable and disable capture button if face detected
  //     });
  //   } catch (e, s) {
  //     logger.e('error: $e, stack: $s');
  //   }
  // }

  // InputImageRotation rotationIntToImageRotation(int rotation) {
  //   switch (rotation) {
  //     case 90:
  //       return InputImageRotation.rotation90deg;
  //     case 180:
  //       return InputImageRotation.rotation180deg;
  //     case 270:
  //       return InputImageRotation.rotation270deg;
  //     default:
  //       return InputImageRotation.rotation0deg;
  //   }
  // }

  Future<void> dispose() async {
   // await cameraController?.stopImageStream();
    await cameraController?.dispose();
    // await _faceDetector?.close();
  }
}