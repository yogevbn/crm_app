import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class ImageHandlingService {
  final String basePath = 'assets/images/';

  // Generate the asset path based on model name and ID
  String getAssetPath(String modelName, String id) {
    return path.join(basePath, '${modelName.toLowerCase()}s', '$id.png');
  }

  // Save or replace image in assets directory
  Future<void> saveOrReplaceImage(
      File imageFile, String modelName, String id) async {
    final destinationPath = getAssetPath(modelName, id);
    final destinationFile = File(destinationPath);

    try {
      final directory = Directory(path.dirname(destinationPath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // If the image already exists, delete it to avoid duplicates
      if (await destinationFile.exists()) {
        await destinationFile.delete();
        print('Existing image at $destinationPath deleted');
      }

      // Copy the new image to the assets directory
      await imageFile.copy(destinationPath);
      print('Image saved to $destinationPath');
    } catch (e) {
      print('Error saving or replacing image: $e');
      throw Exception('Failed to save or replace image');
    }
  }

  // Delete image from assets directory
  Future<void> deleteImage(String modelName, String id) async {
    final imagePath = getAssetPath(modelName, id);
    final imageFile = File(imagePath);

    try {
      if (await imageFile.exists()) {
        await imageFile.delete();
        print('Image at $imagePath deleted');
      } else {
        print('Image at $imagePath does not exist');
      }
    } catch (e) {
      print('Error deleting image: $e');
      throw Exception('Failed to delete image');
    }
  }

  // Method to return an image widget based on model details or fallback icon
  Widget buildImageWidget({
    required String modelName,
    required String modelId,
    double width = 50,
    double height = 50,
  }) {
    final imagePath = getAssetPath(modelName, modelId);

    if (File(imagePath).existsSync()) {
      return Image.file(
        File(imagePath),
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    } else {
      return Icon(
        Icons.shopping_bag,
        size: width > height ? width : height,
      );
    }
  }
}
