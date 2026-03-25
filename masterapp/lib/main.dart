import 'package:flutter/material.dart';
import 'pages/dashboard/dashboard.dart';
import 'pages/profile/profile.dart';
import 'pages/project_management/project_management.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BOMA Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF101D6E),
        ),
      ),

      // ✅ gunakan initialRoute + routes
      initialRoute: '/dashboard',

      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/profile': (context) => const ProfilePage(),
        '/project-management': (context) => const ProjectManagementPage(),
      },
    );
  }
}