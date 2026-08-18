import 'dart:io';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Lets the user pan/zoom/crop a picked (or already-selected) image before it
// becomes the home screen wallpaper. Pops with the saved cropped file's path
// on success, or null if the user backs out.
class WallpaperCropPage extends StatefulWidget {
  final Uint8List imageBytes;
  const WallpaperCropPage({super.key, required this.imageBytes});

  @override
  State<WallpaperCropPage> createState() => _WallpaperCropPageState();
}

class _WallpaperCropPageState extends State<WallpaperCropPage> {
  final _cropController = CropController();
  bool _isSaving = false;

  Future<void> _onCropped(Uint8List croppedBytes) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(croppedBytes);
      if (mounted) Navigator.pop(context, path);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not save cropped wallpaper: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Match the crop frame to the device's own screen aspect ratio, since
    // that's what the wallpaper is actually rendered at (BoxFit.cover on the
    // home screen background).
    final size = MediaQuery.of(context).size;
    final screenAspectRatio = size.width / size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Adjust Wallpaper", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.check, color: Colors.white, size: 28),
            onPressed: _isSaving
                ? null
                : () {
                    setState(() => _isSaving = true);
                    _cropController.crop();
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              controller: _cropController,
              image: widget.imageBytes,
              aspectRatio: screenAspectRatio,
              baseColor: Colors.black,
              maskColor: Colors.black.withOpacity(0.6),
              cornerDotBuilder: (size, edgeAlignment) => const DotControl(color: Colors.white),
              onCropped: _onCropped,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
            child: Text(
              "Pinch to zoom, drag to reposition. Tap the check mark when ready.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
