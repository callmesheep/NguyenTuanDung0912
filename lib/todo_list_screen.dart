import 'package:flutter/material.dart';
import 'database_helper.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  void _refreshTasks() async {
    final tasks = await _dbHelper.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  void _addTask() async {
    await _dbHelper.insertTask({
      'title': 'New Task',
      'description': 'Description',
      'deadline': DateTime.now().toIso8601String(),
      'isDone': 0
    });
    _refreshTasks();
  }

  void _toggleTaskCompletion(int id, bool isDone) async {
    await _dbHelper.updateTask({'id': id, 'isDone': isDone ? 1 : 0});
    _refreshTasks();
  }

  void _deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách công việc'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addTask,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final isOverdue = DateTime.parse(task['deadline']).isBefore(DateTime.now());
          return ListTile(
            title: Text(task['title']),
            subtitle: Text(isOverdue ? 'Hết hạn' : 'Còn hạn'),
            trailing: Checkbox(
              value: task['isDone'] == 1,
              onChanged: (bool? value) {
                _toggleTaskCompletion(task['id'], value!);
              },
            ),
            onLongPress: () => _deleteTask(task['id']),
          );
        },
      ),
    );
  }
}