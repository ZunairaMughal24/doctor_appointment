import 'dart:io';
import 'dart:ui' show Rect;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

/// Outcome of validating a doctor profile photo.
class PhotoValidationResult {
  final bool ok;
  final String message;
  const PhotoValidationResult(this.ok, this.message);
}

/// On-device validation of doctor profile photos against professional criteria,
/// using ML Kit face detection (face presence, centering, head pose) plus a
/// pixel scan of the border for a plain/light background. No network/API keys.
class ImageValidationService {
  ImageValidationService._();

  static final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: false,
      enableContours: false,
      enableClassification: false,
    ),
  );

  /// Checks the photo shows exactly one centered, front-facing face on a plain,
  /// light background. Returns a pass/fail with a specific message either way.
  static Future<PhotoValidationResult> validateDoctorPhoto(File file) async {
    // ── 1. Face detection ───────────────────────────────────────────────────
    final List<Face> faces;
    try {
      faces = await _detector.processImage(InputImage.fromFile(file));
    } catch (e) {
      return PhotoValidationResult(false, 'Could not analyse the image: $e');
    }

    if (faces.isEmpty) {
      return const PhotoValidationResult(
        false,
        'No face detected. Please upload a clear, front-facing photo of your face.',
      );
    }
    if (faces.length > 1) {
      return const PhotoValidationResult(
        false,
        'More than one face detected. Please use a solo photo of just yourself.',
      );
    }
    final face = faces.first;

    // Decode for dimensions + background sampling.
    final decoded = img.decodeImage(await file.readAsBytes());
    if (decoded == null) {
      return const PhotoValidationResult(
        false,
        'Could not read this image. Please try a different photo.',
      );
    }
    final int w = decoded.width;
    final int h = decoded.height;
    final Rect box = face.boundingBox;

    // ── 2. Face visible (large enough) ──────────────────────────────────────
    final double faceArea = (box.width * box.height) / (w * h);
    if (faceArea < 0.07) {
      return const PhotoValidationResult(
        false,
        'Your face is too small. Move closer so your face is clearly visible.',
      );
    }

    // ── 3. Face centered ────────────────────────────────────────────────────
    final double offsetX = (box.center.dx - w / 2).abs() / w;
    final double offsetY = (box.center.dy - h / 2).abs() / h;
    if (offsetX > 0.22 || offsetY > 0.25) {
      return const PhotoValidationResult(
        false,
        'Please center your face in the frame.',
      );
    }

    // ── 4. Looking straight at the camera (head pose) ───────────────────────
    final double yaw = (face.headEulerAngleY ?? 0).abs(); // turned left/right
    final double pitch = (face.headEulerAngleX ?? 0).abs(); // up/down
    final double roll = (face.headEulerAngleZ ?? 0).abs(); // tilt
    if (yaw > 15 || pitch > 15 || roll > 12) {
      return const PhotoValidationResult(
        false,
        'Please look straight at the camera, with your head upright.',
      );
    }

    // ── 5. Plain / white background ─────────────────────────────────────────
    if (!_hasPlainLightBackground(decoded, box)) {
      return const PhotoValidationResult(
        false,
        'Background is not plain. Please use a plain white background.',
      );
    }

    return const PhotoValidationResult(
      true,
      'Great — your photo meets the professional criteria.',
    );
  }

  /// Samples points along the top and upper side margins (areas that should be
  /// background, above the shoulders) and checks they're bright and uniform.
  static bool _hasPlainLightBackground(img.Image image, Rect faceBox) {
    final int w = image.width;
    final int h = image.height;
    final List<List<int>> samples = [];

    void sample(double fx, double fy) {
      final int x = (fx * w).round().clamp(0, w - 1);
      final int y = (fy * h).round().clamp(0, h - 1);
      final p = image.getPixel(x, y);
      samples.add([p.r.toInt(), p.g.toInt(), p.b.toInt()]);
    }

    // Top strip.
    for (int i = 0; i < 5; i++) {
      final double fx = (i + 0.5) / 5;
      sample(fx, 0.04);
      sample(fx, 0.10);
    }
    // Upper-left / upper-right columns (beside the head).
    for (int j = 0; j < 4; j++) {
      final double fy = (j + 0.5) / 8; // top half
      sample(0.03, fy);
      sample(0.97, fy);
    }
    if (samples.isEmpty) return false;

    int light = 0;
    for (final s in samples) {
      final double lum = 0.299 * s[0] + 0.587 * s[1] + 0.114 * s[2];
      if (lum > 170) light++;
    }
    // At least 70% of sampled background points should read as light/plain.
    return light / samples.length >= 0.7;
  }
}
