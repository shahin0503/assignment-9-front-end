import 'dart:convert';
import 'dart:developer';

import 'package:assignment9/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late List<dynamic> tasks = [];
  late String uid;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid') ?? '';

    final response =
        await http.get(Uri.parse('http://192.168.0.102:8080/task/$uid'));
    if (response.statusCode == 200) {
      setState(() {
        tasks = json.decode(response.body);
      });
      log(' task details:  $tasks');
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> updateTaskStatus(String taskId, bool newValue) async {
    final url = 'http://192.168.0.102:8080/task/$taskId';
    final Map<String, dynamic> data = {
      'assignedUsers': {uid: newValue}
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      // Task updated successfully, you can handle the response here if needed
      log('Task status updated successfully');
    } else {
      // Failed to update task status, handle the error
      log('Failed to update task status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your tasks'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.logout_outlined))
        ],
      ),
      floatingActionButton: ElevatedButton(
          onPressed: () async {
            await Navigator.pushNamed(
              context,
              assignTaskRoute,
            );
            fetchTasks();
          },
          child: const Text('Task Management')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 100,
          childAspectRatio: 1,
        ),
        itemCount: tasks.length,
        itemBuilder: (BuildContext context, int index) {
          bool isCompleted = tasks[index]['assignedUsers'][uid] ?? false;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 3,
              child: Center(
                child: ListTile(
                  title: Text(
                    tasks[index]['taskName'] ?? '',
                    style: TextStyle(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  leading: Checkbox(
                    value: isCompleted,
                    onChanged: (bool? value) {
                      setState(() {
                        isCompleted = value ?? false;
                        tasks[index]['assignedUsers'][uid] = isCompleted;
                        updateTaskStatus(tasks[index]['taskId'], isCompleted);
                      });
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
