import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_tutor_screen.dart';
import 'screens/dashboard_alumno_screen.dart';
import 'services/dashboard_service.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configura handler para mensajes en segundo plano
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

// Requerido para mensajes en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📥 Notificación en background: ${message.notification?.title}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _initFirebaseMessaging(); // Configura listeners y token

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

  void _initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Solicita permisos (solo en Android 13+ y iOS)
    await messaging.requestPermission();

    // Obtener token de dispositivo (lo puedes enviar a tu backend con el login)
    final token = await messaging.getToken();
    print('🔑 Token FCM: $token');

    // Listener para notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Notificación recibida en foreground: ${message.notification?.title}');
    });

    // Listener para cuando se toca la notificación y se abre la app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 Usuario abrió la notificación: ${message.notification?.title}');
    });
  }
  
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Si el usuario está autenticado, verificamos su rol
    if (authProvider.isAuthenticated) {
      // Creamos el servicio de dashboard
      final dashboardService = DashboardService(
        baseUrl: 'https://parcial2-colegio-backend.onrender.com',
        token: authProvider.userData!.token,
      );
      
      // Si es tutor, mostramos el dashboard de tutor
      if (authProvider.isTutor) {
        return DashboardTutorScreen(
          dashboardService: dashboardService,
        );
      } else {
        // Si es alumno, mostramos el dashboard de alumno
        return DashboardAlumnoScreen(
          dashboardService: dashboardService,
        );
      }
    }
    
    // Si no está autenticado, mostramos la pantalla de login
    return const LoginScreen();
  }
}
