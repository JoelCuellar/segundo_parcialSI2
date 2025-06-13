import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_tutor_screen.dart';
import 'screens/dashboard_alumno_screen.dart';
import 'services/dashboard_service.dart';
import 'providers/auth_provider.dart';

// Handler de background debe tener esta anotación
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📥 Notificación en background: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Registra el handler de background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initFirebaseMessaging();
  }

  void _initFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;

    // 1) Solicita permisos (Android 13+ y iOS)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Permisos notificaciones: ${settings.authorizationStatus}');

    // 2) Obtén token FCM
    final token = await messaging.getToken();
    print('🔑 Token FCM: $token');
    // TODO: envíalo a tu backend con el login

    // 3) Listener para mensajes en foreground
    FirebaseMessaging.onMessage.listen((msg) {
      print('🔔 Foreground: ${msg.notification?.title}');
      // Aquí podrías mostrar un diálogo o Snackbar si quieres
    });

    // 4) Listener cuando el usuario abre la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      print('📲 Abrió notificación: ${msg.notification?.title}');
      // Aquí podrías navegar a una pantalla específica
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Educativo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'SF Pro Display',
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isAuthenticated) return const LoginScreen();

    final service = DashboardService(
      baseUrl: 'https://parcial2-colegio-backend.onrender.com',
      token: auth.userData!.token,
    );

    return auth.isTutor
      ? DashboardTutorScreen(dashboardService: service)
      : DashboardAlumnoScreen(dashboardService: service);
  }
}
