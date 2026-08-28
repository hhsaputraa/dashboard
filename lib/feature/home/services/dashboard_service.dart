import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dashboard/core/network/api_client.dart';
import 'package:dashboard/feature/auth/services/auth_service.dart';
import '../model/dashboard_data.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  /// Mengambil data dashboard bunga live dari backend Go / Oracle
  Future<DashboardData> fetchDashboardData({int idKantor = 0}) async {
    final queryParams = idKantor > 0 ? '?kantor=$idKantor' : '';
    final url = Uri.parse('${_apiClient.baseUrl}/api/dashboard/interest$queryParams');

    final headers = <String, String>{
      'Accept': 'application/json',
    };

    final token = _authService.currentToken.value;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final dataObj = body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        return DashboardData.fromJson(dataObj);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw const FormatException('Sesi login telah berakhir atau tidak memiliki izin akses.');
      } else if (response.statusCode >= 500) {
        throw const FormatException('Server database sedang mengalami gangguan (Internal Server Error).');
      } else {
        final body = jsonDecode(response.body);
        final errorMsg = body['message'] ?? body['error'] ?? 'Gagal memuat data (${response.statusCode})';
        throw FormatException(errorMsg.toString());
      }
    } on SocketException {
      throw const SocketException('Tidak dapat menghubungi server. Periksa koneksi internet Anda.');
    } on TimeoutException {
      throw TimeoutException('Koneksi ke server timeout (waktu habis). Silakan coba lagi.');
    } on http.ClientException {
      throw const SocketException('Gagal terhubung ke URL server. Pastikan alamat server atau tunnel aktif.');
    } on FormatException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kendala saat menghubungkan ke server.');
    }
  }
}
