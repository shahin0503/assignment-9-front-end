import 'dart:convert';

import 'package:assignment9/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TaskManagementPage extends StatefulWidget {
  const TaskManagementPage({super.key});

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  late List<dynamic> tasks = [];
  late String uid;

  @override
  void initState() {
    fetchTasks();
    super.initState();
  }

  Future<void> fetchTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid') ?? '';

    final response =
        await http.get(Uri.parse('http://10.1.86.148:8080/tasks/$uid'));
    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> responseData = json.decode(response.body);
        tasks = responseData;
        tasks.forEach((task) async {
          dynamic assignedUsers = task['assignedUsers'];
          if (assignedUsers is Map) {
            assignedUsers.keys.forEach((assignedUid) async {
              Map<String, dynamic> userDetails =
                  await fetchUserDetails(assignedUid);
            });
          }
        });
      });
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Map<String, dynamic>> fetchUserDetails(String uid) async {
    final response =
        await http.get(Uri.parse('http://10.1.86.148:8080/users/$uid'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final response =
        await http.delete(Uri.parse('http://10.1.86.148:8080/task/$taskId'));

    if (response.statusCode == 200) {
      fetchTasks();
    } else {
      throw Exception('Failed to delete task');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My created tasks'),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(assignTaskRoute);
              },
              child: const Text('Create task'))
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 200,
          childAspectRatio: 1,
        ),
        itemCount: tasks.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 3,
              child: Center(
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tasks[index]['taskName'] ?? '',
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                print(tasks[index]);
                                Navigator.of(context).pushNamed(assignTaskRoute,
                                    arguments: {'task': tasks[index]});
                              },
                              icon: const Icon(Icons.edit)),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete task'),
                                      content: const Text(
                                          'Are you sure you want to delete the task?'),
                                      actions: <Widget>[
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel')),
                                        TextButton(
                                            onPressed: () async {
                                              await deleteTask(
                                                  tasks[index]['taskId']);
                                              Navigator.of(context).pop();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Task deleted successfully!')),
                                              );
                                            },
                                            child: const Text('Delete'))
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.delete)),
                        ],
                      )
                    ],
                  ),
                  children: [
                    SingleChildScrollView(
                      child: Wrap(
                        spacing: 8.0, // spacing between chips
                        children: (tasks[index]['assignedUsers'] is Map
                                ? tasks[index]['assignedUsers'].keys
                                : [])
                            .map<Widget>((assignedUid) {
                          return FutureBuilder<Map<String, dynamic>>(
                            future: fetchUserDetails(assignedUid),
                            builder: (BuildContext context,
                                AsyncSnapshot<Map<String, dynamic>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Text('Error loading user details');
                              } else if (snapshot.hasData &&
                                  snapshot.data != null) {
                                Map<String, dynamic>? userDetails =
                                    snapshot.data!;

                                Map<String, dynamic>? fieldsProto =
                                    userDetails['_fieldsProto'];
                                String username = fieldsProto?['userName']
                                        ?['stringValue'] ??
                                    '';
                                String email =
                                    fieldsProto?['email']?['stringValue'] ?? '';

                                return Chip(
                                  label: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        username,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(email)
                                    ],
                                  ),
                                  shape: const StadiumBorder(),
                                );
                              } else {
                                return Container();
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
