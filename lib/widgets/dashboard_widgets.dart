import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';

// Paleta de colores
const Color colorBlanco = Color(0xFFFFFFFF);
const Color colorGrisOscuro = Color(0xFF23272F);
const Color colorGrisMedio = Color(0xFF4A5568);
const Color colorGrisClaro = Color(0xFF718096);
const Color colorGrisSutil = Color(0xFFE2E8F0);
const Color colorGrisBorde = Color(0xFFCBD5E0);
const Color colorGrisIcono = Color(0xFF9CA3AF);
const Color colorMagenta = Color(0xFFFF2EC4);
const Color colorAmarillo = Color(0xFFFFD600);
const Color colorNaranja = Color(0xFFFF8500);
const Color colorCyan = Color(0xFF00F6FF);
const Color colorVerde = Color(0xFF16FF6E);

class AlumnoInfoCard extends StatelessWidget {
  final Alumno alumno;
  final int materiasRiesgo;
  final int tareasPendientes;

  const AlumnoInfoCard({
    Key? key,
    required this.alumno,
    required this.materiasRiesgo,
    required this.tareasPendientes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: colorGrisBorde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colorMagenta.withOpacity(0.2),
                  child: Text(
                    alumno.nombre.isNotEmpty ? alumno.nombre.substring(0, 1).toUpperCase() : 'A',
                    style: const TextStyle(
                      color: colorMagenta,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alumno.nombre,
                        style: const TextStyle(
                          color: colorGrisOscuro,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alumno.correo,
                        style: const TextStyle(
                          color: colorGrisMedio,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: colorGrisBorde),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(
                  icon: Icons.warning_rounded,
                  color: colorNaranja,
                  title: 'Materias en riesgo',
                  value: materiasRiesgo.toString(),
                ),
                const SizedBox(width: 16),
                _buildInfoItem(
                  icon: Icons.assignment_late_outlined,
                  color: colorCyan,
                  title: 'Tareas pendientes',
                  value: tareasPendientes.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: colorGrisMedio,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: colorGrisOscuro,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MateriasRiesgoCard extends StatelessWidget {
  final List<MateriaRiesgo> materiasRiesgo;

  const MateriasRiesgoCard({
    Key? key,
    required this.materiasRiesgo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: colorGrisBorde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_rounded, color: colorNaranja),
                const SizedBox(width: 8),
                const Text(
                  'Materias en Riesgo',
                  style: TextStyle(
                    color: colorGrisOscuro,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorNaranja.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    materiasRiesgo.length.toString(),
                    style: const TextStyle(
                      color: colorNaranja,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (materiasRiesgo.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorGrisSutil.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: colorVerde),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Excelente!',
                            style: TextStyle(
                              color: colorGrisOscuro,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'El alumno no tiene materias en riesgo actualmente.',
                            style: TextStyle(
                              color: colorGrisMedio,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: materiasRiesgo.length,
                itemBuilder: (context, index) {
                  final materia = materiasRiesgo[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: materia.prediccion == 'bajo'
                          ? colorNaranja.withOpacity(0.1)
                          : colorAmarillo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: materia.prediccion == 'bajo'
                            ? colorNaranja.withOpacity(0.3)
                            : colorAmarillo.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.book,
                              color: materia.prediccion == 'bajo'
                                  ? colorNaranja
                                  : colorAmarillo,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                materia.nombre,
                                style: const TextStyle(
                                  color: colorGrisOscuro,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: materia.prediccion == 'bajo'
                                    ? colorNaranja
                                    : colorAmarillo,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                materia.prediccion.toUpperCase(),
                                style: const TextStyle(
                                  color: colorBlanco,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildMateriaInfoItem(
                              title: 'Exámenes',
                              value: materia.examenesProm.toStringAsFixed(1),
                              icon: Icons.assignment,
                            ),
                            _buildMateriaInfoItem(
                              title: 'Tareas',
                              value: materia.tareasProm.toStringAsFixed(1),
                              icon: Icons.task_alt,
                            ),
                            _buildMateriaInfoItem(
                              title: 'Asistencia',
                              value: '${materia.asistenciaPct.toStringAsFixed(0)}%',
                              icon: Icons.calendar_today,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMateriaInfoItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: colorGrisMedio, size: 16),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: colorGrisClaro,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: colorGrisOscuro,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UltimasTareasCard extends StatelessWidget {
  final List<Tarea> tareas;

  const UltimasTareasCard({
    Key? key,
    required this.tareas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: colorGrisBorde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_turned_in, color: colorMagenta),
                const SizedBox(width: 8),
                const Text(
                  'Últimas Tareas Calificadas',
                  style: TextStyle(
                    color: colorGrisOscuro,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tareas.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorGrisSutil.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: colorCyan),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No hay tareas calificadas recientemente.',
                        style: TextStyle(
                          color: colorGrisMedio,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tareas.length,
                itemBuilder: (context, index) {
                  final tarea = tareas[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorGrisSutil.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorMagenta.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.assignment,
                            color: colorMagenta,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tarea.titulo,
                                style: const TextStyle(
                                  color: colorGrisOscuro,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tarea.materia,
                                style: const TextStyle(
                                  color: colorGrisMedio,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Entregada: ${tarea.fechaEntrega}',
                                style: const TextStyle(
                                  color: colorGrisClaro,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getNotaColor(tarea.nota ?? 0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getNotaColor(tarea.nota ?? 0).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            tarea.nota?.toStringAsFixed(1) ?? 'N/A',
                            style: TextStyle(
                              color: _getNotaColor(tarea.nota ?? 0),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getNotaColor(double nota) {
    if (nota >= 80) return colorVerde;
    if (nota >= 60) return colorAmarillo;
    return colorNaranja;
  }
}

class UltimosExamenesCard extends StatelessWidget {
  final List<Examen> examenes;

  const UltimosExamenesCard({
    Key? key,
    required this.examenes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: colorGrisBorde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz, color: colorCyan),
                const SizedBox(width: 8),
                const Text(
                  'Últimos Exámenes',
                  style: TextStyle(
                    color: colorGrisOscuro,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (examenes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorGrisSutil.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: colorCyan),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No hay exámenes calificados recientemente.',
                        style: TextStyle(
                          color: colorGrisMedio,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: examenes.length,
                itemBuilder: (context, index) {
                  final examen = examenes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorGrisSutil.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.quiz,
                            color: colorCyan,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                examen.titulo,
                                style: const TextStyle(
                                  color: colorGrisOscuro,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                examen.materia,
                                style: const TextStyle(
                                  color: colorGrisMedio,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fecha: ${examen.fecha}',
                                style: const TextStyle(
                                  color: colorGrisClaro,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getNotaColor(examen.nota ?? 0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getNotaColor(examen.nota ?? 0).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            examen.nota?.toStringAsFixed(1) ?? 'N/A',
                            style: TextStyle(
                              color: _getNotaColor(examen.nota ?? 0),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getNotaColor(double nota) {
    if (nota >= 80) return colorVerde;
    if (nota >= 60) return colorAmarillo;
    return colorNaranja;
  }
}

class TareasPendientesCard extends StatelessWidget {
  final List<Tarea> tareas;

  const TareasPendientesCard({
    Key? key,
    required this.tareas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: colorGrisBorde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_late, color: colorAmarillo),
                const SizedBox(width: 8),
                const Text(
                  'Tareas Pendientes',
                  style: TextStyle(
                    color: colorGrisOscuro,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorAmarillo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tareas.length.toString(),
                    style: const TextStyle(
                      color: colorAmarillo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tareas.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorGrisSutil.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: colorVerde),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Al día!',
                            style: TextStyle(
                              color: colorGrisOscuro,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'El alumno no tiene tareas pendientes actualmente.',
                            style: TextStyle(
                              color: colorGrisMedio,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tareas.length,
                itemBuilder: (context, index) {
                  final tarea = tareas[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorGrisSutil.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getEstadoColor(tarea.estado).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getEstadoColor(tarea.estado).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getEstadoIcon(tarea.estado),
                            color: _getEstadoColor(tarea.estado),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tarea.titulo,
                                style: const TextStyle(
                                  color: colorGrisOscuro,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tarea.materia,
                                style: const TextStyle(
                                  color: colorGrisMedio,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fecha límite: ${tarea.fechaEntrega}',
                                style: const TextStyle(
                                  color: colorGrisClaro,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getEstadoColor(tarea.estado).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getEstadoText(tarea.estado),
                            style: TextStyle(
                              color: _getEstadoColor(tarea.estado),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return colorNaranja;
      case 'entregada':
        return colorAmarillo;
      default:
        return colorGrisMedio;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.assignment_late;
      case 'entregada':
        return Icons.assignment_turned_in;
      default:
        return Icons.assignment;
    }
  }

  String _getEstadoText(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'PENDIENTE';
      case 'entregada':
        return 'ENTREGADA';
      default:
        return estado.toUpperCase();
    }
  }
}
