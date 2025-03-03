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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  bool _isEditing = false;
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _databaseHelper.init().then((_) {
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _loadUsers() async {
    final users = await _databaseHelper.queryAllRows();
    setState(() {
      _users = users;
    });
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _ageController.clear();
      _isEditing = false;
      _editingId = null;
    });
  }

  void _prepareForEdit(Map<String, dynamic> user) {
    setState(() {
      _isEditing = true;
      _editingId = user[DatabaseHelper.columnId];
      _nameController.text = user[DatabaseHelper.columnName];
      _ageController.text = user[DatabaseHelper.columnAge].toString();
    });
  }

  void _saveUser() async {
    if (_nameController.text.isEmpty || _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please Fill All Fields')),
      );
      return;
    }

    // Prepare user data
    final Map<String, dynamic> userData = {
      DatabaseHelper.columnName: _nameController.text,
      DatabaseHelper.columnAge: int.tryParse(_ageController.text) ?? 0,
    };

    if (_isEditing && _editingId != null) {
      // Update existing user
      userData[DatabaseHelper.columnId] = _editingId;
      await _databaseHelper.update(userData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User Updated Successfully')),
      );
    } else {
      // Add new user
      await _databaseHelper.insert(userData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User Added Successfully')),
      );
    }

    _resetForm();
    _loadUsers();
  }

  void _deleteUser(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _databaseHelper.delete(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User Deleted Successfully')),
      );
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Demo'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: _resetForm,
              tooltip: 'Cancel Editing',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isEditing ? 'Update User' : 'Add New User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        hintText: 'Enter user name',
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                        hintText: 'Enter user age',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveUser,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(_isEditing ? 'Update' : 'Add User'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _users.isEmpty
                ? Center(
                    child: Text('No Users Found. Add Some Users!'),
                  )
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(user[DatabaseHelper.columnName]),
                          subtitle: Text('Age: ${user[DatabaseHelper.columnAge]}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _prepareForEdit(user),
                                tooltip: 'Edit User',
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteUser(user[DatabaseHelper.columnId]),
                                tooltip: 'Delete User',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}