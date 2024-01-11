
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/modelo.dart';
import 'package:image_picker/image_picker.dart';

class Resultado extends StatelessWidget {
  const Resultado({
    super.key,
    this.result,
  });
  final ClassifierCategory? result;

  // hacer un getter de result
  String get resultado => result != null ? result!.label.toString() : 'No hay resultado';
  String get puntuacion => result != null ? result!.score.toString() : 'No hay puntuación';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resultado,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Score: $puntuacion',
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarcoImagen extends StatelessWidget {
  const MarcoImagen({
    super.key,
    required XFile? image,
  }) : _image = image;

  final XFile? _image;

  @override
  Widget build(BuildContext context) {
    return _image == null
        ? const Text('No hay imagen')
        : Expanded(
            child: Image.file(
              File(_image.path),
              fit: BoxFit.cover,
            ),
          );
  }
}
