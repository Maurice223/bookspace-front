import 'package:flutter/material.dart';
import 'package:bookspace/screens/stats_screen.dart';

// Pages utilisateur
import 'package:bookspace/screens/login_screen.dart';
import 'package:bookspace/screens/register_screen.dart';
import 'package:bookspace/screens/home_user_screen.dart';
import 'package:bookspace/screens/reserver_screen.dart';
import 'package:bookspace/screens/mes_reservations_screen.dart';
import 'package:bookspace/screens/splash_screen.dart';

// Pages admin
import 'package:bookspace/screens/home_admin_screen.dart';
import 'package:bookspace/screens/users_screen.dart';
import 'package:bookspace/screens/salles_screen.dart';
import 'package:bookspace/screens/add_salle_screen.dart';
import 'package:bookspace/screens/reservations_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash', // <- Page splash avant login
      routes: {
        '/splash': (context) => const SplashScreen(), // <- Splash

        // Pages publiques
        '/': (context) => const LoginScreen(),
        '/inscription': (context) => const RegisterScreen(),

        // Pages utilisateur avec email obligatoire
        '/home_user': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return HomeUserScreen(utilisateurEmail: args);
        },
        '/reserver': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return ReserverScreen(utilisateurEmail: args);
        },
        '/mes_reservations': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return MesReservationsScreen(utilisateurEmail: args);
        },

        // Pages admin
        '/home_admin': (context) => const HomeAdminScreen(),
        '/admin_users': (context) => AdminUsersScreen(),
        '/admin_salles': (context) => SallesScreen(),
        '/admin_add_salle': (context) => AddSallePage(),
        '/admin_reservations': (context) => AdminReservationsScreen(),
        '/admin_stats': (context) => const StatsScreen(),
      },
    );
  }
}
