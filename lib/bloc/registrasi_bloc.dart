import 'dart:convert';
import 'package:tokokita/helpers/api.dart';
import 'package:tokokita/helpers/api_url.dart';

class RegistrasiBloc {
  static Future<Map<String, dynamic>> registrasi({
    String? nama,
    String? email,
    String? password,
  }) async {
    String apiUrl = ApiUrl.registrasi;
    var body = {"nama": nama, "email": email, "password": password};
    try {
      var response = await Api().post(apiUrl, body);
      var jsonObj = json.decode(response.body);
      return {
        'status': jsonObj['status'],
        'message': jsonObj['message'] ?? 'Email sudah terdaftar',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}