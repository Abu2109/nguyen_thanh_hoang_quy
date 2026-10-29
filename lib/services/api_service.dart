import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static const _storage = FlutterSecureStorage();

  static Future<dynamic> _request(String method, String path, {Map<String, dynamic>? body, bool authenticated = true}) async {
    if (!baseUrl.startsWith('https://')) throw Exception('Chưa cấu hình API HTTPS. Chạy với --dart-define=API_BASE_URL=https://TEN-MIEN-API');
    final token = authenticated ? await _storage.read(key: 'accessToken') : null;
    final request = http.Request(method, Uri.parse('$baseUrl$path'));
    request.headers['Content-Type'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) request.body = jsonEncode(body);
    final response = await http.Response.fromStream(await request.send()).timeout(const Duration(seconds: 25));
    dynamic data;
    try { data = jsonDecode(utf8.decode(response.bodyBytes)); } catch (_) { data = null; }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data is Map && data['message'] != null ? data['message'].toString() : 'HTTP ${response.statusCode}');
    }
    return data;
  }

  static Future<Map<String, dynamic>> login({required String username, required String password}) async {
    final data = Map<String, dynamic>.from(await _request('POST', '/api/Users/login', authenticated: false, body: {'username': username, 'password': password}));
    final token = data['accessToken'];
    if (token is! String || token.isEmpty) throw Exception('API không trả về accessToken');
    await _storage.write(key: 'accessToken', value: token);
    return data;
  }

  static Future<Map<String, dynamic>> register({required String username, required String fullName, required String email, required String password}) async =>
      Map<String, dynamic>.from(await _request('POST', '/api/Users/register', authenticated: false, body: {'username': username, 'fullName': fullName, 'email': email, 'password': password}));

  static Future<List<dynamic>> getChildren() async => List<dynamic>.from(await _request('GET', '/api/Children') as List);

  static Future<Map<String, dynamic>> createChild({required String username, required String fullName, required String password, String? birthDate}) async =>
      Map<String, dynamic>.from(await _request('POST', '/api/Children', body: {'username': username, 'fullName': fullName, 'password': password, 'birthDate': birthDate}));

  static Future<Map<String, dynamic>> updateChild({required int childId, required String fullName, String? birthDate}) async =>
      Map<String, dynamic>.from(await _request('PUT', '/api/Children/$childId', body: {'fullName': fullName, 'birthDate': birthDate}));

  static Future<Map<String, dynamic>> disableChild(int childId) async => Map<String, dynamic>.from(await _request('DELETE', '/api/Children/$childId'));
  static Future<Map<String, dynamic>> restoreChild(int childId) async => Map<String, dynamic>.from(await _request('PUT', '/api/Children/$childId/restore'));
  static Future<void> logout() => _storage.delete(key: 'accessToken');
}
