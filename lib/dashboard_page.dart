import 'package:assignment9/constants/routes.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.logout_outlined))
        ],
      ),
      floatingActionButton: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              assignTaskRoute,
            );
          },
          child: const Text('Assign Task')),
    );
  }
}
