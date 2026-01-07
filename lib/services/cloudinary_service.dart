
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dndgaxjmm',    
    'default_profile',   
    cache: false,
  );

  // رفع صورة البروفايل
  static Future<String> uploadProfile(File imageFile) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, folder: 'profiles'),
      );
      return response.secureUrl; // الرابط الجاهز
    } catch (e) {
      throw 'فشل رفع الصورة: $e';
    }
  }

  // رفع صورة بوست أو منتج أو نبات
  static Future<String> uploadPost(File imageFile) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, folder: 'posts'),
      );
      return response.secureUrl;
    } catch (e) {
      throw 'فشل رفع الصورة: $e';
    }
  }
}
