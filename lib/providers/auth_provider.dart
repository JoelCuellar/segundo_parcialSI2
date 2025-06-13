import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserData {
  final String token;
  final String username;
  final String role; // 'tutor', 'alumno', etc.
  final int userId;

  UserData({
    required this.token,
    required this.username,
    required this.role,
    required this.userId,
  });

  // Convertir a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'username': username,
      'role': role,
      'userId': userId,
    };
  }

  // Crear desde JSON para recuperación
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      token: json['token'],
      username: json['username'],
      role: json['role'],
      userId: json['userId'],
    );
  }
}

class AuthProvider extends ChangeNotifier {
  UserData? _userData;
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();
  final String baseUrl = 'https://parcial2-colegio-backend.onrender.com';

  UserData? get userData => _userData;
  bool get isAuthenticated => _userData != null;
  bool get isLoading => _isLoading;
  bool get isTutor => _userData?.role == 'tutor';

  // Constructor que intenta cargar datos guardados
  AuthProvider() {
    _loadUserData();
  }

  // Cargar datos de usuario del almacenamiento seguro
  Future<void> _loadUserData() async {
    try {
      final userDataString = await _storage.read(key: 'userData');
      if (userDataString != null) {
        final userDataJson = json.decode(userDataString);
        _userData = UserData.fromJson(userDataJson);
        notifyListeners();
      }
    } catch (e) {
      // Si hay error al cargar, simplemente continuamos sin usuario
      print('Error al cargar datos de usuario: $e');
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
  setLoading(true);

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);

      // ✅ Extraer token y datos del usuario desde la respuesta
      final token = data['tokens'];
      final usuario = data['usuario'];

      if (token == null || usuario == null) {
        throw Exception('Faltan datos en la respuesta del servidor');
      }

      final role = usuario['rol'] ?? 'alumno';
      final userId = usuario['id'] ?? 0;
      final username = usuario['username'] ?? '';

      _userData = UserData(
        token: token,
        username: username,
        role: role,
        userId: userId,
      );

      // ✅ Guardar en almacenamiento seguro
      await _storage.write(
        key: 'userData',
        value: json.encode(_userData!.toJson()),
      );

      setLoading(false);
      return true;
    } else {
      throw Exception('Credenciales inválidas');
    }
  } catch (e) {
    print('Error de login: $e');
    setLoading(false);
    return false;
  }
}



  Future<void> logout() async {
    try {
      // Intentar hacer logout en el servidor
      if (_userData != null) {
        await http.post(
          Uri.parse('$baseUrl/logout/'),
          headers: {
            'Authorization': 'Bearer ${_userData!.token}',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      print('Error al hacer logout en el servidor: $e');
    } finally {
      // Limpiar datos localmente independientemente del resultado
      _userData = null;
      await _storage.delete(key: 'userData');
      notifyListeners();
    }
  }
}
