import 'package:flutter/material.dart';
import 'helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper.init().then((_) {
      _loadUsers();
    });
  }

  void _loadUsers() async {
    final users = await _databaseHelper.queryAllRows();
    setState(() {
      _users = users;
    });
  }

  void _addUser() async {
    await _databaseHelper.insert({
      'name': 'Bharath Ashapu',
      'age': 30,
    });
    _loadUsers();
  }

  void _deleteUser(int id) async {
    await _databaseHelper.delete(id);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Demo'),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user['name']),
            subtitle: Text('Age: ${user['age']}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteUser(user['_id']);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: Icon(Icons.add),
      ),
    );
  }
}
