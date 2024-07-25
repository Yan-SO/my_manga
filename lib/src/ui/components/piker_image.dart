import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PikerImage extends StatefulWidget {
  final Function(File) onImagePicked;
  final String? imageManga;
  const PikerImage({super.key, required this.onImagePicked, this.imageManga});

  @override
  State<PikerImage> createState() => _PikerImageState();
}

class _PikerImageState extends State<PikerImage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.imageManga != null) {
      _image = File(widget.imageManga!);
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
        height: (widthScreen * (4 / 6)),
        width: (widthScreen * (2 / 5)),
        child: Card(
          color: Color.fromARGB(255, 36, 36, 36),
          child: _image == null
              ? const Text(
                  "clique aqui para selecionar uma imagem",
                  style: TextStyle(fontSize: 30),
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
