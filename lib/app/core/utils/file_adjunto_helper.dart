import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import '../../data/models/models.dart';

class FileAdjuntoHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<AdjuntoModel?> tomarFotoDesdeCamara() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo == null) return null;
      return _crearAdjuntoDesdeRuta(photo.path);
    } catch (e) {
      throw Exception('No fue posible tomar la foto: $e');
    }
  }

  static Future<AdjuntoModel?> grabarVideoDesdeCamara() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
        preferredCameraDevice: CameraDevice.rear,
      );
      if (video == null) return null;
      return _crearAdjuntoDesdeRuta(video.path);
    } catch (e) {
      throw Exception('No fue posible grabar el video: $e');
    }
  }

  static Future<AdjuntoModel?> seleccionarImagenGaleria() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return null;
      return _crearAdjuntoDesdeRuta(image.path);
    } catch (e) {
      throw Exception('No fue posible seleccionar imagen desde galería: $e');
    }
  }

  static Future<AdjuntoModel?> seleccionarVideoGaleria() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video == null) return null;
      return _crearAdjuntoDesdeRuta(video.path);
    } catch (e) {
      throw Exception('No fue posible seleccionar video desde galería: $e');
    }
  }

  static Future<AdjuntoModel?> seleccionarArchivo() async {
    try {
      final PlatformFile? picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'webp',
          'heic',
          'mp4',
          'mov',
          'avi',
          'mkv',
          '3gp',
        ],
      );

      if (picked == null) return null;
      if (picked.path == null || picked.path!.isEmpty) {
        throw Exception('No fue posible obtener la ruta del archivo seleccionado.');
      }

      final File file = File(picked.path!);

      if (!await file.exists()) {
        throw Exception('El archivo seleccionado no existe.');
      }

      final String mimeType =
          lookupMimeType(picked.path!) ?? 'application/octet-stream';

      if (!mimeType.startsWith('image/') && !mimeType.startsWith('video/')) {
        throw Exception('Solo se permiten archivos de imagen o video.');
      }

      final int tamanioBytes = picked.lengthSync() ??
          await picked.length() ??
          await file.length();

      final String extension = (picked.extension?.isNotEmpty ?? false)
          ? picked.extension!.toLowerCase()
          : _extraerExtension(picked.name);

      return AdjuntoModel(
        file: file,
        nombre: picked.name,
        mimeType: mimeType,
        tamanioBytes: tamanioBytes,
        extension: extension,
      );
    } catch (e) {
      throw Exception('No fue posible seleccionar imagen o video: $e');
    }
  }

  static Future<AdjuntoModel> _crearAdjuntoDesdeRuta(String path) async {
    final File file = File(path);

    if (!await file.exists()) {
      throw Exception('El archivo no existe.');
    }

    final String nombre = p.basename(path);
    final String mimeType =
        lookupMimeType(path) ?? 'application/octet-stream';

    if (!mimeType.startsWith('image/') && !mimeType.startsWith('video/')) {
      throw Exception('Solo se permiten archivos de imagen o video.');
    }

    final int tamanioBytes = await file.length();
    final String extension = _extraerExtension(nombre);

    return AdjuntoModel(
      file: file,
      nombre: nombre,
      mimeType: mimeType,
      tamanioBytes: tamanioBytes,
      extension: extension,
    );
  }

  static Future<AdjuntoModel> _mapearAdjunto(File file) async {
    if (!await file.exists()) {
      throw Exception('El archivo no existe.');
    }

    final int tamanio = await file.length();
    final String nombre = p.basename(file.path);
    final String mimeType =
        lookupMimeType(file.path) ?? 'application/octet-stream';

    if (!mimeType.startsWith('image/') && !mimeType.startsWith('video/')) {
      throw Exception('Solo se permiten archivos de imagen o video.');
    }

    return AdjuntoModel(
      file: file,
      nombre: nombre,
      mimeType: mimeType,
      tamanioBytes: tamanio,
      extension: _extraerExtension(nombre),
    );
  }

  static String _extraerExtension(String nombreArchivo) {
    return p.extension(nombreArchivo).replaceFirst('.', '').toLowerCase();
  }
}