// Bonus

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static const String _fileName = 'liked_movies.json';

  static Future<String> get _filePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_fileName';
  }

  static Future<Set<Map<String, dynamic>>> getLikedMovies() async {
    try {
      final path = await _filePath;
      final file = File(path);

      if (kDebugMode) {
        print('Getting liked movies from path: $path');
      }

      if (!await file.exists()) {
        if (kDebugMode) {
          print('File does not exist, creating new one');
        }
        await file.writeAsString(jsonEncode([]));
        return {};
      }

      final jsonString = await file.readAsString();
      if (kDebugMode) {
        print('Read from file: $jsonString');
      }
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toSet();
    } catch (e) {
      if (kDebugMode) {
        print('Error reading liked movies: $e');
      }
      return {};
    }
  }

  static Future<void> addLikedMovie(Map<String, dynamic> movie) async {
    try {
      if (kDebugMode) {
        print('Adding movie to liked: $movie');
      }
      final path = await _filePath;
      final file = File(path);

      Set<Map<String, dynamic>> movies = await getLikedMovies();
      movies.removeWhere((m) => m['id'] == movie['id']);

      movies.add(movie);

      await file.writeAsString(jsonEncode(movies.toList()));
      if (kDebugMode) {
        print('Successfully saved movie');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving liked movie: $e');
      }
      rethrow;
    }
  }

  static Future<void> removeLikedMovie(int movieId) async {
    try {
      final path = await _filePath;
      final file = File(path);

      Set<Map<String, dynamic>> movies = await getLikedMovies();
      movies.removeWhere((movie) => movie['id'] == movieId);

      await file.writeAsString(jsonEncode(movies.toList()));
    } catch (e) {
      rethrow;
    }
  }
}
