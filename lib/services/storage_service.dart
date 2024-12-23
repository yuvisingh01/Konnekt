import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:path/path.dart' as p;

class StorageService {
  StorageService();

  final cloudinary = Cloudinary.signedConfig(
    cloudName: 'dvgw9rpq5',
    apiSecret: '8iFXV-cbbhdJAOtgdkitrLBysNs',
    apiKey: '729792317857578',
  );

  String? _uploadedImageUrl;
  String? get uploadedImageUrl {
    return _uploadedImageUrl;
  }

  Future<bool> uploadPFP(File file, String uid) async {
    try {
      // Upload the image to Cloudinary
      final response = await cloudinary.upload(
        file: file.path, // File path of the image to upload
        fileBytes: null, // Optional: Use for in-memory uploads
        fileName: '$uid${p.basenameWithoutExtension(file.path)}', // Optional: Filename for the uploaded image
        folder: 'users/pfps', // Optional: Folder in Cloudinary
      );
      if (response.isSuccessful) {
        print('Upload successful!');
        print('Image URL: ${response.secureUrl}');
        _uploadedImageUrl = response.secureUrl;
        return true;
      } else {
        print('Upload failed: ${response.error}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return false;
  }


  Future<bool>uploadImageToChat({required File file, required String chatId})async{
        try {
      // Upload the image to Cloudinary
      final response = await cloudinary.upload(
        file: file.path, // File path of the image to upload
        fileBytes: null, // Optional: Use for in-memory uploads
        fileName: '${DateTime.now().toIso8601String()}${p.basenameWithoutExtension(file.path)}', // Optional: Filename for the uploaded image
        folder: 'chats/$chatId', // Optional: Folder in Cloudinary
      );
      if (response.isSuccessful) {
        print('Upload successful!');
        print('Image URL: ${response.secureUrl}');
        _uploadedImageUrl = response.secureUrl;
        return true;
      } else {
        print('Upload failed: ${response.error}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return false;
  }
}
