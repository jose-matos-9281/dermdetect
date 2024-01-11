import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

List<Object> cargarImagen(XFile imagenInput , int widthSize , int heightSize) {
  // Cargar la imagen con la biblioteca image
  img.Image imagen = img.decodeImage(File(imagenInput.path).readAsBytesSync())!;

  // Redimensionar la imagen según los requisitos del modelo
  imagen = img.copyResize(imagen, width: widthSize, height: heightSize);


  // Normalizar los valores de los píxeles a un rango de 0 a 1
  List<List<List<double>>> inputData = [];
  for (int y = 0; y < imagen.height; y++) {
    List<List<double>> row = [];
    for (int x = 0; x < imagen.width; x++) {
      img.Pixel pixel = imagen.getPixel(x, y);
      List<double> pix = [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
      row.add(pix);
    }
    inputData.add(row);
  }// Imprimir el primer valor de la primera fila, columna y canal
  // Ejecutar la inferencia con el tensor normalizado
  return [inputData];
}

