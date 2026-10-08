import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'storage_service.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../screens/login_screen.dart';

import 'package:flutter/foundation.dart';

class ApiService {
  // 10.0.2.2 is Android host loopback for local php artisan serve on port 8000
  static String get _defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    } catch (_) {}
    return 'http://localhost:8000/api';
  }

  static String baseUrl = _defaultBaseUrl;

  static Future<Map<String, String>> _headers() async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final token = await StorageService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      // Update last active time as the user is actively making requests
      StorageService.saveLastActive(DateTime.now());
    }
    return headers;
  }

  static void _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      // Clear token and details
      StorageService.clear();
      // Force redirect to login screen using the global navigatorKey
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  static Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await http.get(url, headers: await _headers());
    _checkUnauthorized(response);
    return response;
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await http.post(url, headers: await _headers(), body: jsonEncode(body));
    _checkUnauthorized(response);
    return response;
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await http.put(url, headers: await _headers(), body: jsonEncode(body));
    _checkUnauthorized(response);
    return response;
  }

  static Future<http.Response> delete(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await http.delete(url, headers: await _headers());
    _checkUnauthorized(response);
    return response;
  }

  // Upload method for multipart file submissions (savings receipt, credit goods photo, bill payment transfer)
  static Future<http.Response> multipart(
    String method,
    String path,
    Map<String, String> fields,
    Map<String, File> files,
  ) async {
    final url = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest(method, url);

    final token = await StorageService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
      // Update last active time as the user is actively making requests
      StorageService.saveLastActive(DateTime.now());
    }
    request.headers['Accept'] = 'application/json';

    request.fields.addAll(fields);

    for (var entry in files.entries) {
      final file = entry.value;
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      
      final multipartFile = http.MultipartFile(
        entry.key,
        stream,
        length,
        filename: file.path.split(Platform.pathSeparator).last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    _checkUnauthorized(response);
    return response;
  }
}
