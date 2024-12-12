import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpHelper {
  static String baseUrl = "http://movie-night-api.onrender.com";

  static Future<Map<String, dynamic>> startSession(String? deviceId) async {
    try {
      if (deviceId == null || deviceId.isEmpty) {
        throw Exception('No device ID provided');
      }

      if (kDebugMode) {
        print('Starting session with device ID: $deviceId');
      }

      var response = await http
          .get(Uri.parse('$baseUrl/start-session?device_id=$deviceId'));

      if (kDebugMode) {
        print('Start session response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to start session: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error starting session: $e');
    }
  }

  static Future<Map<String, dynamic>> joinSession(
      String? deviceId, int code) async {
    try {
      var response = await http.get(
          Uri.parse('$baseUrl/join-session?device_id=$deviceId&code=$code'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to join session: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error joining session: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchMovies(int page) async {
    try {
      String tmdbApiKey = dotenv.env['API_KEY']!;

      var response = await http.get(Uri.parse(
          'https://api.themoviedb.org/3/movie/popular?api_key=$tmdbApiKey&page=$page'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load movies: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  static Future<Map<String, dynamic>> voteMovie(
      String? sessionId, int movieId, bool vote) async {
    try {
      if (sessionId == null || sessionId.isEmpty) {
        throw Exception('No session ID provided');
      }

      if (kDebugMode) {
        print('Sending vote request with session ID: $sessionId');
        print('Movie ID: $movieId');
        print('Vote: $vote');
      }

      var response = await http.get(Uri.parse(
          '$baseUrl/vote-movie?session_id=$sessionId&movie_id=$movieId&vote=$vote'));

      if (kDebugMode) {
        print('Vote response status code: ${response.statusCode}');
        print('Vote response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to vote on movie: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error voting on movie: $e');
    }
  }
}
