import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageImage extends StatefulWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const StorageImage({super.key, required this.path, this.width, this.height, this.fit = BoxFit.cover});

  @override
  State<StorageImage> createState() => _StorageImageState();
}

class _StorageImageState extends State<StorageImage> {
  String? _url;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ref = FirebaseStorage.instance.ref(widget.path);
      final url = await ref.getDownloadURL();
      if (mounted) setState(() => _url = url);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        color: Colors.grey.shade200,
        width: widget.width,
        height: widget.height,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
    if (_url == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    return Image.network(
      _url!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}


