import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'dart:math';
import 'coordinates_translator.dart';

class FaceMeshDetectorPainter extends CustomPainter {
  FaceMeshDetectorPainter(
      this.meshes,
      this.imageSize,
      this.rotation,
      this.cameraLensDirection,
      );

  final List<FaceMesh> meshes;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  // Define indices for left and right eye landmarks
  final List<int> leftEyeIndices = [ 158, 153];
  final List<int> rightEyeIndices = [ 386, 373];
  final double eyeClosureThreshold = 12.0; // Adjust this threshold as needed

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.red;
    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.white;

    for (final FaceMesh mesh in meshes) {
      // Paint only the eye landmarks based on their indices
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

      // Function to calculate the distance between two points
      double calculateDistance(Offset point1, Offset point2) {
        final dx = pow((point1.dx - point2.dx),2);
        final dy = pow((point1.dy - point2.dy),2);
        return sqrt(dx+dy);
      }

      // Detect eye closure
      bool isEyeClosed(List<FaceMeshPoint> points, List<int> eyeIndices,String eyeName) {
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

      // Paint eye points and detect if eyes are closed
       bool leftEyeClosed = isEyeClosed(mesh.points, leftEyeIndices,"left");
       bool rightEyeClosed = isEyeClosed(mesh.points, rightEyeIndices,"right");

      // Draw eye points
      paintEyePoints(mesh.points, leftEyeIndices, paint2);
      paintEyePoints(mesh.points, rightEyeIndices, paint2);

      // Print or use eye closure status
      if(leftEyeClosed && rightEyeClosed){
        print("Sleeping : true");
      }
    }
  }

  @override
  bool shouldRepaint(FaceMeshDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.meshes != meshes;
  }
}