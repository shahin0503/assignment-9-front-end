import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AssignTaskPage extends StatefulWidget {
  const AssignTaskPage({super.key});

  @override
  State<AssignTaskPage> createState() => _AssignTaskPageState();
}

class _AssignTaskPageState extends State<AssignTaskPage> {
  late TextEditingController _taskController;
  late List<dynamic> users = [];
  List<dynamic> selectedUsers = [];
  String? userUid;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController();
    fetchUsers();
    _getCurrentUser();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('http://192.168.0.102:8080/users'));
    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userUid = prefs.getString('uid');
  }

  void toggleUserSelection(dynamic user) {
    setState(() {
      var userData = user['data'];
      var userUid = userData['uid'];
      if (selectedUsers.contains(userUid)) {
        selectedUsers.remove(userUid);
      } else {
        selectedUsers.add(userUid);
      }
    });
  }

  Future<void> assignTask() async {
    String taskName = _taskController.text;
    Map<String, dynamic> assignedUsersMap = {
      for (var uid in selectedUsers) uid: false
    };

    Map<String, dynamic> data = {
      'taskName': taskName,
      'assignedUsers': assignedUsersMap,
      'creator': userUid,
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.102:8080/task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Handle success response from the API
        print('Task assigned successfully!');
      } else {
        // Handle error response from the API
        print('Failed to assign task: ${response.body}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error assigning task: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Task'),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                    hintText: 'Task Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: users == null
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: users.map<Widget>((user) {
                          var userData = user['data'];
                          String userName = userData['userName'];
                          String email = userData['email'];
                          return GestureDetector(
                            onTap: () {
                              toggleUserSelection(user);
                            },
                            child: Chip(
                              label: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(email)
                                ],
                              ),
                              shape: const StadiumBorder(),
                              backgroundColor:
                                  selectedUsers.contains(userData['uid'])
                                      ? Color.fromARGB(255, 166, 92, 201)
                                      : Colors.grey,
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
          onPressed: () async {
            await assignTask();
            setState(() {
              _taskController.clear();
              selectedUsers.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Task assigned successfully!')),
            );

            Navigator.of(context).pop();
          },
          child: const Text('Assign')),
    );
  }
}
