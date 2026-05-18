import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageRepository {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String?> uploadImage(File image, String path) async {
    try {
      final fileName = 'cheque_${DateTime.now().millisecondsSinceEpoch}';

      final ref = _firebaseStorage.ref('$path/$fileName');

      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      String? returnable = await snapshot.ref.getDownloadURL();
      print("returnable $returnable");
      return fileName;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<File?> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<String> downloadFile(String? filename) async {
    try {
      if (filename == null || filename.isEmpty) {
        throw Exception("Filename cannot be null or empty.");
      }
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$filename';
      // if (!await directory.exists()) {
      //   await directory.create(recursive: true);
      // }
      final fileDirectory = Directory(directory.path);
      if (!await fileDirectory.exists()) {
        await fileDirectory.create(recursive: true);
      }
      final ref = FirebaseStorage.instance.ref('images/$filename');

      print("============$filename==============");

      await ref.writeToFile(File(filePath));

      return filePath;
    } catch (e) {
      print('Error downloading file: $e');
      return '';
    }
  }
}
