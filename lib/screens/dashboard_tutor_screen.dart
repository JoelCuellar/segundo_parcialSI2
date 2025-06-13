import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';
import '../widgets/dashboard_widgets.dart';
import '../providers/auth_provider.dart';

class DashboardTutorScreen extends StatefulWidget {
  final DashboardService dashboardService;

  const DashboardTutorScreen({
    Key? key,
    required this.dashboardService,
  }) : super(key: key);

  @override
  State<DashboardTutorScreen> createState() => _DashboardTutorScreenState();
}

class _DashboardTutorScreenState extends State<DashboardTutorScreen> {
  late Future<List<DashboardAlumno>> _dashboardFuture;
  int _selectedAlumnoIndex = 0;

  // Paleta de colores
  static const Color colorBlanco = Color(0xFFFFFFFF);
  static const Color colorGrisOscuro = Color(0xFF23272F);
  static const Color colorGrisMedio = Color(0xFF4A5568);
  static const Color colorGrisClaro = Color(0xFF718096);
  static const Color colorGrisSutil = Color(0xFFE2E8F0);
  static const Color colorGrisBorde = Color(0xFFCBD5E0);
  static const Color colorGrisIcono = Color(0xFF9CA3AF);
  static const Color colorMagenta = Color(0xFFFF2EC4);
  static const Color colorAmarillo = Color(0xFFFFD600);
  static const Color colorNaranja = Color(0xFFFF8500);
  static const Color colorCyan = Color(0xFF00F6FF);
  static const Color colorVerde = Color(0xFF16FF6E);

  @override
  void initState() {
    super.initState();
    _dashboardFuture = widget.dashboardService.getDashboardTutor();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: colorGrisSutil,
      appBar: AppBar(
        title: const Text(
          'Dashboard Tutor',
          style: TextStyle(
            color: colorGrisOscuro,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorBlanco,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: colorMagenta),
            onPressed: () {
              setState(() {
                _dashboardFuture = widget.dashboardService.getDashboardTutor();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: colorGrisOscuro),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<DashboardAlumno>>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: colorMagenta,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: colorNaranja,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar los datos',
                    style: TextStyle(
                      color: colorGrisOscuro,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: colorGrisMedio,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _dashboardFuture = widget.dashboardService.getDashboardTutor();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorMagenta,
                      foregroundColor: colorBlanco,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_off,
                    color: colorGrisClaro,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes alumnos asignados',
                    style: TextStyle(
                      color: colorGrisOscuro,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          final alumnos = snapshot.data!;
          
          // Asegurarse de que el índice seleccionado sea válido
          if (_selectedAlumnoIndex >= alumnos.length) {
            _selectedAlumnoIndex = 0;
          }
          
          final selectedAlumno = alumnos[_selectedAlumnoIndex];

          return Column(
            children: [
              // Selector de alumno
              Container(
                padding: const EdgeInsets.all(16),
                color: colorBlanco,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecciona un alumno',
                      style: TextStyle(
                        color: colorGrisMedio,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colorGrisSutil.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorGrisBorde),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedAlumnoIndex,
                          icon: const Icon(Icons.keyboard_arrow_down, color: colorMagenta),
                          items: List.generate(alumnos.length, (index) {
                            final alumno = alumnos[index].alumno;
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Text(
                                alumno.nombre,
                                style: TextStyle(
                                  color: colorGrisOscuro,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                          onChanged: (int? newIndex) {
                            if (newIndex != null) {
                              setState(() {
                                _selectedAlumnoIndex = newIndex;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenido del dashboard
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información del alumno
                      AlumnoInfoCard(
                        alumno: selectedAlumno.alumno,
                        materiasRiesgo: selectedAlumno.materiasEnRiesgo.length,
                        tareasPendientes: selectedAlumno.tareasPendientes.length,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Materias en riesgo
                      MateriasRiesgoCard(
                        materiasRiesgo: selectedAlumno.materiasEnRiesgo,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Últimas tareas
                      UltimasTareasCard(
                        tareas: selectedAlumno.ultimasTareas,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Últimos exámenes
                      UltimosExamenesCard(
                        examenes: selectedAlumno.ultimosExamenes,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tareas pendientes
                      TareasPendientesCard(
                        tareas: selectedAlumno.tareasPendientes,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
