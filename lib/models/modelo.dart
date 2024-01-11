import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'imagen.dart' as img;

typedef ClassifierLabels = List<String>;

class ClassifierModel {
  Interpreter interpreter;

  List<int> inputShape;
  List<int> outputShape;

  TensorType inputType;
  TensorType outputType;

  ClassifierModel({
    required this.interpreter,
    required this.inputShape,
    required this.outputShape,
    required this.inputType,
    required this.outputType,
  });
}

class ClassifierCategory {
  final String label;
  final double score;

  ClassifierCategory(this.label, this.score);

  @override
  String toString() {
    return 'Category{label: $label, score: $score}';
  }
}

class Classifier {
  final ClassifierLabels _labels;
  final ClassifierModel _model;

  Classifier._({
    required ClassifierLabels labels,
    required ClassifierModel model,
  })  : _labels = labels,
        _model = model;

  static Future<Classifier?> loadWith({
    required String labelsFileName,
    required String modelFileName,
  }) async {
    try {
      final labels = await _loadLabels(labelsFileName);
      final model = await _loadModel(modelFileName);
      return Classifier._(labels: labels, model: model);
    } catch (e) {
      debugPrint('Can\'t initialize Classifier: ${e.toString()}');
      if (e is Error) {
        debugPrintStack(stackTrace: e.stackTrace);
      }
      return null;
    }
  }

  static Future<ClassifierLabels> _loadLabels(String labelsFileName) async {
    // #1
    final fileString = await rootBundle.loadString(labelsFileName);
    var list = <String>[];
    final newLineList = fileString.split('\n');
    for (var i = 0; i < newLineList.length; i++) {
      var entry = newLineList[i].trim();
      if (entry.isNotEmpty) {
        list.add(entry);
      }
    }
    // #2
    final labels = list
        .map((label) => label.substring(label.indexOf(' ')).trim())
        .toList();
    return labels;
  }

  static Future<ClassifierModel> _loadModel(String modelFileName) async {
    // #1
    final interpreter = await Interpreter.fromAsset(modelFileName);

    // #2
    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;

    // #3
    final inputType = interpreter.getInputTensor(0).type;
    final outputType = interpreter.getOutputTensor(0).type;


    return ClassifierModel(
      interpreter: interpreter,
      inputShape: inputShape,
      outputShape: outputShape,
      inputType: inputType,
      outputType: outputType,
    );
  }

  List<Object> _preProcessInput(XFile image) {
    // #1
    final inputImageWidth = _model.inputShape[1];
    final inputImageHeight = _model.inputShape[2];
    final inputTensor =
        img.cargarImagen(image, inputImageWidth, inputImageHeight);
    // #6
    return inputTensor;
  }

  ClassifierCategory _postProcessOutput(List<dynamic> output) {
    // #1
    // #3
    Object probs = output[0];
    try {
      probs = (probs as List).cast<double>();
      int maxIndex = (probs).indexOf((probs as List<double>)
          .reduce((curr, next) => curr > next ? curr : next));
      return ClassifierCategory(_labels[maxIndex], probs[maxIndex]);
    } catch (e) {
      debugPrint('Can\'t cast output to List<double>: ${e.toString()}');
    }
    // encuentra la posicion del valor maximo
    return ClassifierCategory('None', 0.0);
  }

  Future<ClassifierCategory> predit(XFile? image) async {
    // #1
    final preprocessedImage = _preProcessInput(image!);
    // #2
    final output =
        List.filled(1 * _model.outputShape[1], 0).reshape(_model.outputShape);
    // #3
    // ignore: await_only_futures
    
    _model.interpreter.run(preprocessedImage, output);
    // #4
    final category = _postProcessOutput(output);
    _model.interpreter.close();
    return category;
  }

  String printModel() {
    debugPrint(_model.inputShape.toString());
    debugPrint(_model.outputShape.toString());
    debugPrint(_model.inputType.toString());
    debugPrint(_model.outputType.toString());
    debugPrint(_labels.toString());
    return 'Modelo';
  }
}
