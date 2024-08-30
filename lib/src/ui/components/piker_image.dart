import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PikerImage extends StatefulWidget {
  final double? height;
  final double? width;
  final double? fontSize;
  final Function(File) onImagePicked;
  final String? imageManga;
  const PikerImage({
    super.key,
    required this.onImagePicked,
    this.imageManga,
    this.height,
    this.width,
    this.fontSize,
  });

  @override
  State<PikerImage> createState() => _PikerImageState();
}

class _PikerImageState extends State<PikerImage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
    _setImage();
  }

  void _setImage() async {
    if (widget.imageManga != null) {
      final file = File(widget.imageManga!);
      if (await file.exists()) {
        setState(() {
          _image = file;
        });
      }
    }
  }

  @override
  void didUpdateWidget(PikerImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageManga != oldWidget.imageManga) {
      if (widget.imageManga != null) {
        setState(() {
          _image = File(widget.imageManga!);
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
      widget.onImagePicked(_image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        _pickImage(ImageSource.gallery);
      },
      child: SizedBox(
        height: widget.height ?? (widthScreen * (4 / 6)),
        width: widget.width ?? (widthScreen * (2 / 5)),
        child: Card(
          color: const Color.fromARGB(255, 36, 36, 36),
          child: _image == null
              ? Text(
                  "clique aqui para selecionar uma imagem",
                  style: TextStyle(fontSize: widget.fontSize ?? 30),
                  textAlign: TextAlign.center,
                )
              : ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Image.file(_image!),
                  ),
                ),
        ),
      ),
    );
  }
}
