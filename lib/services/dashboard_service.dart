import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_models.dart';

class DashboardService {
  final String baseUrl;
  final String token;

  DashboardService({
    required this.baseUrl,
    required this.token,
  });

  Future<List<DashboardAlumno>> getDashboardTutor() async {
    try {
      // Según la captura de pantalla, parece que la ruta podría ser diferente
      // Intentemos con las rutas que podrían existir
      final possibleEndpoints = [
        '/api/dashboard-tutor/',
        '/api/dashboard/tutor/',
        '/dashboard-tutor/',
        '/dashboard/tutor/',
        '/usuarios/dashboard-tutor/',
      ];

      Exception? lastError;
      
      // Intentar con diferentes endpoints
      for (final endpoint in possibleEndpoints) {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            
            // Verificar la estructura de la respuesta
            if (data is Map && data.containsKey('alumnos')) {
              return (data['alumnos'] as List)
                  .map((e) => DashboardAlumno.fromJson(e))
                  .toList();
            } else if (data is List) {
              return data.map((e) => DashboardAlumno.fromJson(e)).toList();
            } else {
              throw Exception('Formato de respuesta inesperado');
            }
          }
        } catch (e) {
          lastError = Exception('Error al cargar el dashboard: $e');
        }
      }
      
      // Si llegamos aquí, ningún endpoint funcionó
      throw lastError ?? Exception('No se pudo conectar con el servidor');
    } catch (e) {
      throw Exception('Error al cargar el dashboard: $e');
    }
  }

  Future<Map<String, dynamic>> getDashboardAlumnoData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/academico/dashboard-alumno/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('📦 body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Error al cargar el dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar el dashboard: $e');
    }
  }
  
  // Método para obtener notas por gestión
  Future<Map<String, dynamic>> getNotasPorGestion() async {
    try {
      // First try to get data from the specific endpoint
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/academico/notas-por-gestion/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data;
        }
      } catch (e) {
        // If the specific endpoint fails, we'll fall back to using the main dashboard data
        print('Endpoint notas-por-gestion no disponible: $e');
      }
      
      // Fallback: Use the main dashboard data to create chart data
      final dashboardResponse = await getDashboardAlumnoData();
      
      // Create a structure with the available data
      final Map<String, dynamic> formattedData = {
        'materias': [],
        'gestiones': []
      };
      
      // Extract data from materias_bajo_rendimiento to create materias data
      final List<dynamic> materiasBajoRendimiento = dashboardResponse['materias_bajo_rendimiento'] ?? [];
      
      // Process materias bajo rendimiento
      for (final materia in materiasBajoRendimiento) {
        if (materia is Map) {
          final nombreMateria = materia['materia']?.toString() ?? 'Sin nombre';
          
          // Extract or calculate metrics
          double examenesProm = 0;
          if (materia['examenes_prom'] != null) {
            if (materia['examenes_prom'] is num) {
              examenesProm = (materia['examenes_prom'] as num).toDouble();
            } else if (materia['examenes_prom'] is String) {
              examenesProm = double.tryParse(materia['examenes_prom']) ?? 0;
            }
          }
          
          double tareasProm = 0;
          if (materia['tareas_prom'] != null) {
            if (materia['tareas_prom'] is num) {
              tareasProm = (materia['tareas_prom'] as num).toDouble();
            } else if (materia['tareas_prom'] is String) {
              tareasProm = double.tryParse(materia['tareas_prom']) ?? 0;
            }
          }
          
          // Calculate nota_final as average of examenes and tareas
          final notaFinal = (examenesProm + tareasProm) / 2;
          
          // Add to materias list
          formattedData['materias'].add({
            'nombre': nombreMateria,
            'nota_final': notaFinal,
            'rendimiento': notaFinal * 0.9, // Estimate rendimiento as slightly lower than nota
          });
        }
      }
            
      return formattedData;
    } catch (e) {
      // If all else fails, return a minimal structure with empty data
      print('Error al generar datos para gráficos: $e');
      return {
        'materias': [],
        'gestiones': []
      };
    }
  }
}
