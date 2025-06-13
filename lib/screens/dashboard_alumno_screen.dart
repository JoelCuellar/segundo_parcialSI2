import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/dashboard_service.dart';
import '../providers/auth_provider.dart';

class DashboardAlumnoScreen extends StatefulWidget {
  final DashboardService dashboardService;

  const DashboardAlumnoScreen({
    Key? key,
    required this.dashboardService,
  }) : super(key: key);

  @override
  State<DashboardAlumnoScreen> createState() => _DashboardAlumnoScreenState();
}

class _DashboardAlumnoScreenState extends State<DashboardAlumnoScreen> with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _dashboardFuture;
  late Future<Map<String, dynamic>> _notasFuture;
  late TabController _tabController;

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
    _dashboardFuture = widget.dashboardService.getDashboardAlumnoData();
    _notasFuture = widget.dashboardService.getNotasPorGestion();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: colorGrisSutil,
      appBar: AppBar(
        title: const Text(
          'Mi Dashboard',
          style: TextStyle(
            color: colorGrisOscuro,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorBlanco,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorMagenta,
          unselectedLabelColor: colorGrisMedio,
          indicatorColor: colorMagenta,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Rendimiento'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: colorMagenta),
            onPressed: () {
              setState(() {
                _dashboardFuture = widget.dashboardService.getDashboardAlumnoData();
                _notasFuture = widget.dashboardService.getNotasPorGestion();
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Resumen
          _buildResumenTab(authProvider),
          
          // Tab 2: Rendimiento
          _buildRendimientoTab(),
        ],
      ),
    );
  }

  Widget _buildResumenTab(AuthProvider authProvider) {
    return FutureBuilder<Map<String, dynamic>>(
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
                      _dashboardFuture = widget.dashboardService.getDashboardAlumnoData();
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
        } else if (!snapshot.hasData) {
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
                  'No hay datos disponibles',
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

        final dashboardData = snapshot.data!;
        final materiasBajoRendimiento = dashboardData['materias_bajo_rendimiento'] as List<dynamic>? ?? [];
        final ultimasTareas = dashboardData['ultimas_tareas'] as List<dynamic>? ?? [];
        final ultimosExamenes = dashboardData['ultimos_examenes'] as List<dynamic>? ?? [];
        final clasesHoy = dashboardData['clases_hoy'] as List<dynamic>? ?? [];
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del alumno
              AlumnoInfoCard(
                nombre: authProvider.userData!.username,
                materiasBajo: materiasBajoRendimiento.length,
                clasesHoy: clasesHoy.length,
              ),
              
              const SizedBox(height: 16),
              
              // Clases de hoy
              ClasesHoyCard(
                clasesHoy: clasesHoy,
              ),
              
              const SizedBox(height: 16),
              
              // Materias en bajo rendimiento
              MateriasBajoRendimientoCard(
                materias: materiasBajoRendimiento,
              ),
              
              const SizedBox(height: 16),
              
              // Últimas tareas
              UltimasTareasCard(
                tareas: ultimasTareas,
              ),
              
              const SizedBox(height: 16),
              
              // Últimos exámenes
              UltimosExamenesCard(
                examenes: ultimosExamenes,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRendimientoTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _notasFuture,
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
                  'Error al cargar los datos de rendimiento',
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
                      _notasFuture = widget.dashboardService.getNotasPorGestion();
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
        } else if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bar_chart,
                  color: colorGrisClaro,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay datos de rendimiento disponibles',
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

        // Use the actual data from the API
        final notasData = snapshot.data!;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gráfico de rendimiento por materias
              RendimientoPorMateriasCard(notasData: notasData),
              
              const SizedBox(height: 16),
              
              // Gráfico de rendimiento por gestión
              RendimientoPorGestionCard(notasData: notasData),
            ],
          ),
        );
      },
    );
  }
}

class AlumnoInfoCard extends StatelessWidget {
  final String nombre;
  final int materiasBajo;
  final int clasesHoy;

  const AlumnoInfoCard({
    Key? key,
    required this.nombre,
    required this.materiasBajo,
    required this.clasesHoy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color colorBlanco = Color(0xFFFFFFFF);
    const Color colorGrisOscuro = Color(0xFF23272F);
    const Color colorGrisMedio = Color(0xFF4A5568);
    const Color colorGrisBorde = Color(0xFFCBD5E0);
    const Color colorNaranja = Color(0xFFFF8500);
    const Color colorCyan = Color(0xFF00F6FF);

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
                  backgroundColor: colorCyan.withOpacity(0.2),
                  child: Text(
                    nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'A',
                    style: const TextStyle(
                      color: colorCyan,
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
                        'Bienvenido,',
                        style: TextStyle(
                          color: colorGrisMedio,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        nombre,
                        style: const TextStyle(
                          color: colorGrisOscuro,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
                  value: materiasBajo.toString(),
                ),
                const SizedBox(width: 16),
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  color: colorCyan,
                  title: 'Clases hoy',
                  value: clasesHoy.toString(),
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
    const Color colorGrisOscuro = Color(0xFF23272F);
    const Color colorGrisMedio = Color(0xFF4A5568);

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

class ClasesHoyCard extends StatelessWidget {
  final List<dynamic> clasesHoy;

  const ClasesHoyCard({
    Key? key,
    required this.clasesHoy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color colorBlanco = Color(0xFFFFFFFF);
    const Color colorGrisOscuro = Color(0xFF23272F);
    const Color colorGrisMedio = Color(0xFF4A5568);
    const Color colorGrisClaro = Color(0xFF718096);
    const Color colorGrisSutil = Color(0xFFE2E8F0);
    const Color colorGrisBorde = Color(0xFFCBD5E0);
    const Color colorCyan = Color(0xFF00F6FF);

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
                const Icon(Icons.calendar_today, color: colorCyan),
                const SizedBox(width: 8),
                const Text(
                  'Clases de Hoy',
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
                    color: colorCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    clasesHoy.length.toString(),
                    style: const TextStyle(
                      color: colorCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (clasesHoy.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorGrisSutil.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.event_busy, color: colorGrisClaro),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No tienes clases programadas para hoy.',
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
                itemCount: clasesHoy.length,
                itemBuilder: (context, index) {
                  final clase = clasesHoy[index];
                  
                  // Manejo seguro de datos
                  final profesorMateria = clase is Map ? clase['profesor_materia'] : null;
                  final profesor = profesorMateria is Map ? profesorMateria['profesor'] : null;
                  final materia = profesorMateria is Map ? profesorMateria['materia'] : null;
                  final horariosDias = clase is Map ? clase['horarios_dias'] : null;
                  
                  String horaInicio = '';
                  String horaFin = '';
                  
                  if (horariosDias is List && horariosDias.isNotEmpty && horariosDias[0] is Map) {
                    horaInicio = horariosDias[0]['hora_inicio']?.toString() ?? '';
                    horaFin = horariosDias[0]['hora_fin']?.toString() ?? '';
                  }
                  
                  final nombreMateria = materia is Map ? materia['nombre']?.toString() ?? 'Sin nombre' : 'Sin nombre';
                  final nombreProfesor = profesor is Map 
                      ? '${profesor['nombre']?.toString() ?? ''} ${profesor['apellido']?.toString() ?? ''}'
                      : 'Sin profesor';
                  final aula = clase is Map ? clase['aula']?.toString() ?? 'Sin asignar' : 'Sin asignar';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorGrisSutil.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorCyan.withOpacity(0.3)),
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
                            Icons.school,
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
                                nombreMateria,
                                style: const TextStyle(
                                  color: colorGrisOscuro,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Prof. $nombreProfesor',
                                style: const TextStyle(
                                  color: colorGrisMedio,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Aula: $aula',
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
                            color: colorCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$horaInicio - $horaFin',
                            style: const TextStyle(
                              color: colorCyan,
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
}

class MateriasBajoRendimientoCard extends StatelessWidget {
  final List<dynamic> materias;

  const MateriasBajoRendimientoCard({
    Key? key,
    required this.materias,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color colorBlanco = Color(0xFFFFFFFF);
    const Color colorGrisOscuro = Color(0xFF23272F);
    const Color colorGrisMedio = Color(0xFF4A5568);
    const Color colorGrisClaro = Color(0xFF718096);
    const Color colorGrisSutil = Color(0xFFE2E8F0);
    const Color colorGrisBorde = Color(0xFFCBD5E0);
    const Color colorNaranja = Color(0xFFFF8500);
    const Color colorVerde = Color(0xFF16FF6E);

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
                    materias.length.toString(),
                    style: const TextStyle(
                      color: colorNaranja,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (materias.isEmpty)
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
                            'No tienes materias en riesgo actualmente.',
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
                itemCount: materias.length,
                itemBuilder: (context, index) {
                  final materia = materias[index];
                  
                  // Manejo seguro de datos
                  final nombreMateria = materia is Map ? materia['materia']?.toString() ?? 'Sin nombre' : 'Sin nombre';
                  
                  // Convertir valores a double de manera segura
                  double examenesProm = 0;
                  if (materia is Map && materia['examenes_prom'] != null) {
                    if (materia['examenes_prom'] is num) {
                      examenesProm = (materia['examenes_prom'] as num).toDouble();
                    } else if (materia['examenes_prom'] is String) {
                      examenesProm = double.tryParse(materia['examenes_prom']) ?? 0;
                    }
                  }
                  
                  double tareasProm = 0;
                  if (materia is Map && materia['tareas_prom'] != null) {
                    if (materia['tareas_prom'] is num) {
                      tareasProm = (materia['tareas_prom'] as num).toDouble();
                    } else if (materia['tareas_prom'] is String) {
                      tareasProm = double.tryParse(materia['tareas_prom']) ?? 0;
                    }
                  }
                  
                  double asistenciaPct = 0;
                  if (materia is Map && materia['asistencia_pct'] != null) {
                    if (materia['asistencia_pct'] is num) {
                      asistenciaPct = (materia['asistencia_pct'] as num).toDouble();
                    } else if (materia['asistencia_pct'] is String) {
                      asistenciaPct = double.tryParse(materia['asistencia_pct']) ?? 0;
                    }
                  }
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorNaranja.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorNaranja.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.book,
                              color: colorNaranja,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                nombreMateria,
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
                                color: colorNaranja,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'BAJO',
                                style: TextStyle(
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
                              value: examenesProm.toStringAsFixed(1),
                              icon: Icons.assignment,
                            ),
                            _buildMateriaInfoItem(
                              title: 'Tareas',
                              value: tareasProm.toStringAsFixed(1),
                              icon: Icons.task_alt,
                            ),
                            _buildMateriaInfoItem(
                              title: 'Asistencia',
                              value: '${asistenciaPct.toStringAsFixed(0)}%',
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
    const Color colorGrisOscuro = Color(0xFF23272F);
    const Color colorGrisMedio = Color(0xFF4A5568);
    const Color colorGrisClaro = Color(0xFF718096);

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
  final List<dynamic> tareas;

  const UltimasTareasCard({
    Key? key,
    required this.tareas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color colorBlanco = Color(0xFFFFFFFF);
    const Color colorGrisOscuro = Color(0xFF23272F);
    const Color colorGrisMedio = Color(0xFF4A5568);
    const Color colorGrisClaro = Color(0xFF718096);
    const Color colorGrisSutil = Color(0xFFE2E8F0);
    const Color colorGrisBorde = Color(0xFFCBD5E0);
    const Color colorMagenta = Color(0xFFFF2EC4);
    const Color colorAmarillo = Color(0xFFFFD600);
    const Color colorNaranja = Color(0xFFFF8500);
    const Color colorCyan = Color(0xFF00F6FF);
    const Color colorVerde = Color(0xFF16FF6E);

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
                  
                  // Manejo seguro de datos
                  final tareaData = tarea is Map ? tarea['tarea'] : null;
                  final materiaData = tareaData is Map ? tareaData['materia'] : null;
                  
                  final titulo = tareaData is Map ? tareaData['titulo']?.toString() ?? 'Sin título' : 'Sin título';
                  final materia = materiaData is Map ? materiaData['nombre']?.toString() ?? 'Sin materia' : 'Sin materia';
                  final fechaEntrega = tarea is Map ? tarea['fecha_entrega']?.toString() ?? 'Sin fecha' : 'Sin fecha';
                  
                  // Convertir nota a double de manera segura
                  double? nota;
                  if (tarea is Map && tarea['nota'] != null) {
                    if (tarea['nota'] is num) {
                      nota = (tarea['nota'] as num).toDouble();
                    } else if (tarea['nota'] is String) {
                      nota = double.tryParse(tarea['nota']);
                    }
                  }
                  
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
                                titulo,
                                style: const TextStyle(
                                  color: colorGrisOscuro,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                materia,
                                style: const TextStyle(
                                  color: colorGrisMedio,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Entregada: $fechaEntrega',
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
                            color: _getNotaColor(nota ?? 0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getNotaColor(nota ?? 0).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            nota?.toStringAsFixed(1) ?? 'N/A',
                            style: TextStyle(
                              color: _getNotaColor(nota ?? 0),
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
    const Color colorVerde = Color(0xFF16FF6E);
    const Color colorAmarillo = Color(0xFFFFD600);
    const Color colorNaranja = Color(0xFFFF8500);
    
    if (nota >= 80) return colorVerde;
    if (nota >= 60) return colorAmarillo;
    return colorNaranja;
  }
}

class UltimosExamenesCard extends StatelessWidget {
  final List<dynamic> examenes;

  const UltimosExamenesCard({
    Key? key,
    required this.examenes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color colorBlanco = Color(0xFFFFFFFF);
    const Color colorGrisOscuro = Color(0xFF23272F);
    const Color colorGrisMedio = Color(0xFF4A5568);
    const Color colorGrisClaro = Color(0xFF718096);
    const Color colorGrisSutil = Color(0xFFE2E8F0);
    const Color colorGrisBorde = Color(0xFFCBD5E0);
    const Color colorAmarillo = Color(0xFFFFD600);
    const Color colorNaranja = Color(0xFFFF8500);
    const Color colorCyan = Color(0xFF00F6FF);
    const Color colorVerde = Color(0xFF16FF6E);

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
                  
                  // Manejo seguro de datos
                  final examenData = examen is Map ? examen['examen'] : null;
                  final materiaData = examenData is Map ? examenData['materia'] : null;
                  
                  final titulo = examenData is Map ? examenData['titulo']?.toString() ?? 'Sin título' : 'Sin título';
                  final materia = materiaData is Map ? materiaData['nombre']?.toString() ?? 'Sin materia' : 'Sin materia';
                  final fecha = examenData is Map ? examenData['fecha']?.toString() ?? 'Sin fecha' : 'Sin fecha';
                  
                  // Convertir nota a double de manera segura
                  double? nota;
                  if (examen is Map && examen['nota'] != null) {
                    if (examen['nota'] is num) {
                      nota = (examen['nota'] as num).toDouble();
                    } else if (examen['nota'] is String) {
                      nota = double.tryParse(examen['nota']);
                    }
                  }
                  
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
                                titulo,
                                style: const TextStyle(
                                  color: colorGrisOscuro,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                materia,
                                style: const TextStyle(
                                  color: colorGrisMedio,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fecha: $fecha',
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
                            color: _getNotaColor(nota ?? 0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getNotaColor(nota ?? 0).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            nota?.toStringAsFixed(1) ?? 'N/A',
                            style: TextStyle(
                              color: _getNotaColor(nota ?? 0),
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
    const Color colorVerde = Color(0xFF16FF6E);
    const Color colorAmarillo = Color(0xFFFFD600);
    const Color colorNaranja = Color(0xFFFF8500);
    
    if (nota >= 80) return colorVerde;
    if (nota >= 60) return colorAmarillo;
    return colorNaranja;
  }
}

class RendimientoPorMateriasCard extends StatelessWidget {
  final Map<String, dynamic> notasData;

  const RendimientoPorMateriasCard({
    Key? key,
    required this.notasData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color colorBlanco = Color(0xFFFFFFFF);
    const Color colorGrisOscuro = Color(0xFF23272F);
    const Color colorGrisMedio = Color(0xFF4A5568);
    const Color colorGrisBorde = Color(0xFFCBD5E0);
    const Color colorMagenta = Color(0xFFFF2EC4);
    const Color colorCyan = Color(0xFF00F6FF);

    // Extract data from the API response
    final List<dynamic> materias = notasData['materias'] ?? [];
    
    // Create bar groups from actual data
    final List<BarChartGroupData> barGroups = [];
    
    for (int i = 0; i < materias.length; i++) {
      final materia = materias[i];
      final String nombre = materia['nombre'] ?? 'Sin nombre';
      final double notaFinal = (materia['nota_final'] ?? 0).toDouble();
      final double rendimiento = (materia['rendimiento'] ?? 0).toDouble();
      
      barGroups.add(_makeGroupData(i, notaFinal, rendimiento, nombre));
    }

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
                const Icon(Icons.bar_chart, color: colorMagenta),
                const SizedBox(width: 8),
                const Text(
                  'Rendimiento por Materias',
                  style: TextStyle(
                    color: colorGrisOscuro,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendItem(color: colorMagenta, label: 'Nota Final'),
                  SizedBox(width: 24),
                  _LegendItem(color: colorCyan, label: 'Rendimiento'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: barGroups.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay datos disponibles',
                          style: TextStyle(
                            color: colorGrisMedio,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: colorGrisOscuro.withOpacity(0.8),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                String materia = '';
                                if (groupIndex < materias.length) {
                                  materia = materias[groupIndex]['nombre'] ?? '';
                                }
                                return BarTooltipItem(
                                  '$materia\n',
                                  const TextStyle(
                                    color: colorBlanco,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: rodIndex == 0 
                                          ? 'Nota: ${rod.toY.round()}' 
                                          : 'Rendimiento: ${rod.toY.round()}',
                                      style: TextStyle(
                                        color: rodIndex == 0 ? colorMagenta : colorCyan,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  String text = '';
                                  if (value.toInt() < materias.length) {
                                    // Get first 3 letters of the subject name
                                    final nombre = materias[value.toInt()]['nombre'] ?? '';
                                    text = nombre.length > 3 ? nombre.substring(0, 3) : nombre;
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      text,
                                      style: const TextStyle(
                                        color: colorGrisMedio,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value % 20 != 0) return const SizedBox();
                                  return Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(
                                      color: colorGrisMedio,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 20,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: colorGrisBorde,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            },
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: barGroups,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2, String title) {
    const Color colorMagenta = Color(0xFFFF2EC4);
    const Color colorCyan = Color(0xFF00F6FF);
    
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: colorMagenta,
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        BarChartRodData(
          toY: y2,
          color: colorCyan,
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }
}

class RendimientoPorGestionCard extends StatelessWidget {
  final Map<String, dynamic> notasData;

  const RendimientoPorGestionCard({
    Key? key,
    required this.notasData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color colorBlanco = Color(0xFFFFFFFF);
    const Color colorGrisOscuro = Color(0xFF23272F);
    const Color colorGrisMedio = Color(0xFF4A5568);
    const Color colorGrisBorde = Color(0xFFCBD5E0);
    const Color colorMagenta = Color(0xFFFF2EC4);
    const Color colorCyan = Color(0xFF00F6FF);

    // Extract data from the API response
    final List<dynamic> gestiones = notasData['gestiones'] ?? [];
    
    // Create bar groups from actual data
    final List<BarChartGroupData> barGroups = [];
    
    for (int i = 0; i < gestiones.length; i++) {
      final gestion = gestiones[i];
      final String nombre = gestion['nombre'] ?? '';
      final double notaFinal = (gestion['nota_final'] ?? 0).toDouble();
      final double rendimiento = (gestion['rendimiento'] ?? 0).toDouble();
      
      barGroups.add(_makeGroupData(i, notaFinal, rendimiento, nombre));
    }

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
                const Icon(Icons.trending_up, color: colorCyan),
                const SizedBox(width: 8),
                const Text(
                  'Rendimiento por Gestión',
                  style: TextStyle(
                    color: colorGrisOscuro,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendItem(color: colorMagenta, label: 'Nota Final'),
                  SizedBox(width: 24),
                  _LegendItem(color: colorCyan, label: 'Rendimiento'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: barGroups.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay datos disponibles',
                          style: TextStyle(
                            color: colorGrisMedio,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: colorGrisOscuro.withOpacity(0.8),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                String gestion = '';
                                if (groupIndex < gestiones.length) {
                                  gestion = gestiones[groupIndex]['nombre'] ?? '';
                                }
                                return BarTooltipItem(
                                  '$gestion\n',
                                  const TextStyle(
                                    color: colorBlanco,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: rodIndex == 0 
                                          ? 'Nota: ${rod.toY.round()}' 
                                          : 'Rendimiento: ${rod.toY.round()}',
                                      style: TextStyle(
                                        color: rodIndex == 0 ? colorMagenta : colorCyan,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  String text = '';
                                  if (value.toInt() < gestiones.length) {
                                    text = gestiones[value.toInt()]['nombre'] ?? '';
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      text,
                                      style: const TextStyle(
                                        color: colorGrisMedio,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value % 20 != 0) return const SizedBox();
                                  return Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(
                                      color: colorGrisMedio,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 20,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: colorGrisBorde,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            },
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: barGroups,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2, String title) {
    const Color colorMagenta = Color(0xFFFF2EC4);
    const Color colorCyan = Color(0xFF00F6FF);
    
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: colorMagenta,
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        BarChartRodData(
          toY: y2,
          color: colorCyan,
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const Color colorGrisOscuro = Color(0xFF23272F);
    
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: colorGrisOscuro,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
