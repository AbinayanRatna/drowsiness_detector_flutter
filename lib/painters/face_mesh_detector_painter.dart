import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'dart:math';
import 'coordinates_translator.dart';

class FaceMeshDetectorPainter extends CustomPainter {
  FaceMeshDetectorPainter({
    required this.meshes,
    required this.imageSize,
    required this.rotation,
    required this.cameraLensDirection,
    required this.timeEyeLidsClosed,
    required this.onUpdateTimeClosed,  // Define the onUpdateTimeClosed parameter
  });

  final List<FaceMesh> meshes;
  final Size imageSize;
  final player = AudioPlayer();

  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final int timeEyeLidsClosed;
  final ValueChanged<int> onUpdateTimeClosed;

  final List<int> leftEyeIndices = [158, 153];
  final List<int> rightEyeIndices = [386, 373];
  final double eyeClosureThreshold = 12.0;

  @override
  Future<void> paint(Canvas canvas, Size size) async {
    final Paint paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.red;
    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.white;

    for (final FaceMesh mesh in meshes) {
      void paintEyePoints(List<FaceMeshPoint> points, List<int> indices, Paint paint) {
        final List<Offset> eyePoints = <Offset>[];
        for (int i in indices) {
          final FaceMeshPoint point = points[i];
          final double x = translateX(
            point.x.toDouble(),
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          );
          final double y = translateY(
            point.y.toDouble(),
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          );
          eyePoints.add(Offset(x, y));
        }
        canvas.drawPoints(PointMode.points, eyePoints, paint);
      }

      double calculateDistance(Offset point1, Offset point2) {
        final dx = pow((point1.dx - point2.dx), 2);
        final dy = pow((point1.dy - point2.dy), 2);
        return sqrt(dx + dy);
      }

      bool isEyeClosed(List<FaceMeshPoint> points, List<int> eyeIndices, String eyeName) {
        if (eyeIndices.length < 2) return false;
        final point1 = Offset(
          translateX(points[eyeIndices[0]].x.toDouble(), size, imageSize, rotation, cameraLensDirection),
          translateY(points[eyeIndices[0]].y.toDouble(), size, imageSize, rotation, cameraLensDirection),
        );
        final point2 = Offset(
          translateX(points[eyeIndices[1]].x.toDouble(), size, imageSize, rotation, cameraLensDirection),
          translateY(points[eyeIndices[1]].y.toDouble(), size, imageSize, rotation, cameraLensDirection),
        );
        final distance = calculateDistance(point1, point2);
        print("$eyeName distance: ${distance.toString()}");
        return distance < eyeClosureThreshold;
      }

      if (meshes.isNotEmpty) {
        final FaceMesh mesh = meshes.first;
        bool leftEyeClosed = isEyeClosed(mesh.points, leftEyeIndices, 'Left Eye');
        bool rightEyeClosed = isEyeClosed(mesh.points, rightEyeIndices, 'Right Eye');

        if (rightEyeClosed && leftEyeClosed) {
          onUpdateTimeClosed(timeEyeLidsClosed + 1);
          print("times $timeEyeLidsClosed");
        } else {
          onUpdateTimeClosed(0); // Reset when eyes are open
        }
      }

      if(timeEyeLidsClosed>5){
        print("Driver is sleeping");
        await player.play(AssetSource("explosion.mp3"));
      }

      // Draw eye points
      paintEyePoints(mesh.points, leftEyeIndices, paint2);
      paintEyePoints(mesh.points, rightEyeIndices, paint2);
    }
  }

  @override
  bool shouldRepaint(FaceMeshDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.meshes != meshes || oldDelegate.timeEyeLidsClosed != timeEyeLidsClosed;
  }
}