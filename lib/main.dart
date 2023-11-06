import 'package:assignment9/task/assign_task_page.dart';
import 'package:assignment9/auth/login_page.dart';
import 'package:assignment9/auth/signup_page.dart';
import 'package:assignment9/constants/routes.dart';
import 'package:assignment9/task/dashboard_page.dart';
import 'package:assignment9/task/task_management_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SignUpPage(),
      routes: {
        loginRoute: (context) => const LoginPage(),
        signUpRoute: (context) => const SignUpPage(),
        dashboardRoute: (context) => const DashboardPage(),
        assignTaskRoute: (context) => const AssignTaskPage(),
        taskManagementRoute: (context) => const TaskManagementPage(),
      },
    );
  }
}
