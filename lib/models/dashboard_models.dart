// Modelos simplificados para el dashboard del tutor

class Alumno {
  final int id;
  final String nombre;
  final String correo;

  Alumno({
    required this.id,
    required this.nombre,
    required this.correo,
  });

  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'] ?? 0,
      nombre: json['usuario']['username'] ?? 'Sin nombre',
      correo: json['usuario']['correo'] ?? 'Sin correo',
    );
  }
}

class MateriaRiesgo {
  final int materiaId;
  final String nombre;
  final double examenesProm;
  final double tareasProm;
  final double asistenciaPct;
  final String prediccion;

  MateriaRiesgo({
    required this.materiaId,
    required this.nombre,
    required this.examenesProm,
    required this.tareasProm,
    required this.asistenciaPct,
    required this.prediccion,
  });

  factory MateriaRiesgo.fromJson(Map<String, dynamic> json) {
    return MateriaRiesgo(
      materiaId: json['materia_id'] ?? 0,
      nombre: json['materia'] ?? 'Sin nombre',
      examenesProm: (json['examenes_prom'] ?? 0).toDouble(),
      tareasProm: (json['tareas_prom'] ?? 0).toDouble(),
      asistenciaPct: (json['asistencia_pct'] ?? 0).toDouble(),
      prediccion: json['prediccion'] ?? 'regular',
    );
  }
}

class Tarea {
  final int id;
  final String titulo;
  final String materia;
  final String fechaEntrega;
  final double? nota;
  final String estado;

  Tarea({
    required this.id,
    required this.titulo,
    required this.materia,
    required this.fechaEntrega,
    this.nota,
    required this.estado,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'] ?? 0,
      titulo: json['tarea']['titulo'] ?? 'Sin título',
      materia: json['tarea']['materia']['nombre'] ?? 'Sin materia',
      fechaEntrega: json['fecha_entrega'] ?? 'Sin fecha',
      nota: json['nota']?.toDouble(),
      estado: json['estado'] ?? 'pendiente',
    );
  }
}

class Examen {
  final int id;
  final String titulo;
  final String materia;
  final String fecha;
  final double? nota;
  final String estado;

  Examen({
    required this.id,
    required this.titulo,
    required this.materia,
    required this.fecha,
    this.nota,
    required this.estado,
  });

  factory Examen.fromJson(Map<String, dynamic> json) {
    return Examen(
      id: json['id'] ?? 0,
      titulo: json['examen']['titulo'] ?? 'Sin título',
      materia: json['examen']['materia']['nombre'] ?? 'Sin materia',
      fecha: json['examen']['fecha'] ?? 'Sin fecha',
      nota: json['nota']?.toDouble(),
      estado: json['estado'] ?? 'pendiente',
    );
  }
}

class DashboardAlumno {
  final Alumno alumno;
  final List<MateriaRiesgo> materiasEnRiesgo;
  final List<Tarea> ultimasTareas;
  final List<Examen> ultimosExamenes;
  final List<Tarea> tareasPendientes;

  DashboardAlumno({
    required this.alumno,
    required this.materiasEnRiesgo,
    required this.ultimasTareas,
    required this.ultimosExamenes,
    required this.tareasPendientes,
  });

  factory DashboardAlumno.fromJson(Map<String, dynamic> json) {
    // Manejo seguro de listas
    List<dynamic> materiasRiesgoJson = json['materias_en_riesgo'] ?? [];
    List<dynamic> ultimasTareasJson = json['ultimas_tareas'] ?? [];
    List<dynamic> ultimosExamenesJson = json['ultimos_examenes'] ?? [];
    List<dynamic> tareasPendientesJson = json['tareas_pendientes'] ?? [];

    return DashboardAlumno(
      alumno: Alumno.fromJson(json['alumno'] ?? {}),
      materiasEnRiesgo: materiasRiesgoJson
          .map((e) => MateriaRiesgo.fromJson(e))
          .toList(),
      ultimasTareas: ultimasTareasJson
          .map((e) => Tarea.fromJson(e))
          .toList(),
      ultimosExamenes: ultimosExamenesJson
          .map((e) => Examen.fromJson(e))
          .toList(),
      tareasPendientes: tareasPendientesJson
          .map((e) => Tarea.fromJson(e))
          .toList(),
    );
  }
}
