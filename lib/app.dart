// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/resultado.dart';
import 'models/modelo.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            // color azul claro  de fondo
            backgroundColor: Colors.lightBlue[200],
            title: const Center(
              child: Text(
            'DermDetect',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          )),
        ),
        body: const MyWidget(),
      ),
    ));
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late ImagePicker _picker;
  XFile? _image;
  ClassifierCategory? _result;
  late Classifier? _classifier;
  bool _loading = false;
  bool _isLoadImage = false;
  @override
  void initState() {
    super.initState();
    _picker = ImagePicker(); // Lógica para inicializar el clasificador
  }

  Future _ejecutar() async {
    debugPrint('Ejecutando...');
    _classifier = await Classifier.loadWith(
      labelsFileName: 'assets/labels.txt',
      modelFileName: 'assets/model_peque.tflite',
    );
    if (_classifier == null) {
      debugPrint('Clasificador no cargado');
      return;
    }

    debugPrint('Clasificador cargado');
    if (_image != null) {
      final ClassifierCategory categoria = await _classifier!.predit(_image);
      debugPrint(categoria.toString());
      setState(() {
        _result = categoria;
        _loading = false;
      });
      debugPrint('Resultado: $_result');
    }
    _classifier = null;
    // cerrar el dialogo
  }

  Future<void> _cargarImagen() async {
    setState(() {
      _isLoadImage = true;
    });
    XFile? imagenSeleccionada =
        await _picker.pickImage(source: ImageSource.gallery);
    if (imagenSeleccionada != null) {
      setState(() {
        _image = imagenSeleccionada;
      });
    }
    setState(() {
      _isLoadImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        // color de fondo mas oscuro
        child: Container(
      color: Colors.lightBlue[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300.0,
            height: 300.0,
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Espacio para la imagen (puedes agregar tu widget de imagen aquí)
                MarcoImagen(image: _image),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _isLoadImage
                    ? null
                    : () async {
                        // Lógica para el botón 'Cargar'
                        await _cargarImagen();
                      },
                child: const Text('Cargar'),
                // disabled with isLoadImage
                // disabledColor: Colors.grey,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                  });
                  // Lógica para el botón 'Ejecutar'
                  // _ejecutar();
                  // setState(() {
                  //   _loading = false;
                  // });
                  Future.delayed(const Duration(seconds: 2), () async {
                    await _ejecutar();
                    setState(() {
                      _loading = false;
                    });
                  });
                },
                child: _loading
                    ? const Text('Espere ...')
                    : const Text('Ejecutar'),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Resultado(result: _result),
        ],
      ),
    ));
  }
}
