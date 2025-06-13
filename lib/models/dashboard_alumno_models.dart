
import 'package:flutter/material.dart';

class MateriaRendimiento {
  final int materiaId;
  final String materia;
  final int claseId;
  final int horarioId;
  final double examenesProm;
  final double tareasProm;
  final double asistenciaPct;

  MateriaRendimiento({
    required this.materiaId,
    required this.materia,
    required this.claseId,
    required this.horarioId,
    required this.examenesProm,
    required this.tareasProm,
    required this.asistenciaPct,
  });

  factory MateriaRendimiento.fromJson(Map<String, dynamic> json) {
    return MateriaRendimiento(
      materiaId: json['materia_id'] ?? 0,
      materia: json['materia'] ?? 'Sin nombre',
      claseId: json['clase_id'] ?? 0,
      horarioId: json['horario_id'] ?? 0,
      examenesProm: (json['examenes_prom'] ?? 0).toDouble(),
      tareasProm: (json['tareas_prom'] ?? 0).toDouble(),
      asistenciaPct: (json['asistencia_pct'] ?? 0).toDouble(),
    );
  }
}

class ClaseHoy {
  final int id;
  final String materia;
  final String profesor;
  final String horaInicio;
  final String horaFin;
  final String aula;

  ClaseHoy({
    required this.id,
    required this.materia,
    required this.profesor,
    required this.horaInicio,
    required this.horaFin,
    required this.aula,
  });

  factory ClaseHoy.fromJson(Map<String, dynamic> json) {
    final profesorMateria = json['profesor_materia'] ?? {};
    final profesor = profesorMateria['profesor'] ?? {};
    final materia = profesorMateria['materia'] ?? {};
    final horarios = json['horarios_dias'] ?? [];
    
    String horaInicio = '';
    String horaFin = '';
    
    if (horarios.isNotEmpty && horarios[0] is Map) {
      horaInicio = horarios[0]['hora_inicio'] ?? '';
      horaFin = horarios[0]['hora_fin'] ?? '';
    }

    return ClaseHoy(
      id: json['id'] ?? 0,
      materia: materia['nombre'] ?? 'Sin nombre',
      profesor: '${profesor['nombre'] ?? ''} ${profesor['apellido'] ?? ''}',
      horaInicio: horaInicio,
      horaFin: horaFin,
      aula: json['aula'] ?? 'Sin asignar',
    );
  }
}

// Tarea model for student dashboard
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
    final tarea = json['tarea'] ?? {};
    final materiaData = tarea['materia'] ?? {};
    
    return Tarea(
      id: json['id'] ?? 0,
      titulo: tarea['titulo'] ?? 'Sin título',
      materia: materiaData['nombre'] ?? 'Sin materia',
      fechaEntrega: json['fecha_entrega'] ?? 'Sin fecha',
      nota: json['nota']?.toDouble(),
      estado: json['estado'] ?? 'pendiente',
    );
  }
}

// Examen model for student dashboard
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
    final examen = json['examen'] ?? {};
    final materiaData = examen['materia'] ?? {};
    
    return Examen(
      id: json['id'] ?? 0,
      titulo: examen['titulo'] ?? 'Sin título',
      materia: materiaData['nombre'] ?? 'Sin materia',
      fecha: examen['fecha'] ?? 'Sin fecha',
      nota: json['nota']?.toDouble(),
      estado: json['estado'] ?? 'pendiente',
    );
  }
}

class DashboardAlumno {
  final List<MateriaRendimiento> materiasBajoRendimiento;
  final List<Tarea> ultimasTareas;
  final List<Examen> ultimosExamenes;
  final List<ClaseHoy> clasesHoy;

  DashboardAlumno({
    required this.materiasBajoRendimiento,
    required this.ultimasTareas,
    required this.ultimosExamenes,
    required this.clasesHoy,
  });

  factory DashboardAlumno.fromJson(Map<String, dynamic> json) {
    // Manejo seguro de listas
    List<dynamic> materiasBajoJson = json['materias_bajo_rendimiento'] ?? [];
    List<dynamic> ultimasTareasJson = json['ultimas_tareas'] ?? [];
    List<dynamic> ultimosExamenesJson = json['ultimos_examenes'] ?? [];
    List<dynamic> clasesHoyJson = json['clases_hoy'] ?? [];

    return DashboardAlumno(
      materiasBajoRendimiento: materiasBajoJson
          .map((e) => MateriaRendimiento.fromJson(e))
          .toList(),
      ultimasTareas: ultimasTareasJson
          .map((e) => Tarea.fromJson(e))
          .toList(),
      ultimosExamenes: ultimosExamenesJson
          .map((e) => Examen.fromJson(e))
          .toList(),
      clasesHoy: clasesHoyJson
          .map((e) => ClaseHoy.fromJson(e))
          .toList(),
    );
  }
}
