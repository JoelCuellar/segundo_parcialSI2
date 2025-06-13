import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> login(String username, String password) async {
  final url = Uri.parse('https://parcial2-colegio-backend.onrender.com/login/'); 

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'password': password}),

  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final usuario = data['usuario'] as Map<String, dynamic>?;
    final String? rol = usuario?['rol'] as String?;

    if (rol == 'alumno' || rol == 'tutor') {
      return data;
    } else {
      throw Exception('Acceso denegado: rol no permitido');
    }
  } else {
    final body = jsonDecode(response.body);
    throw Exception(body['non_field_errors']?.first ?? 'Credenciales inválidas');
  }
}