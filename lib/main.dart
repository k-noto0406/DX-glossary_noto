import 'package:flutter/material.dart';

import 'postgre_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _addItem() async {
    await Postgres.insert(
        title: _titleController.text, description: _descriptionController.text);
    //　データの再取得
    await _refreshTodos();
  }

  // todo項目更新
  Future<void> _updateItem(int id) async {
    await Postgres.update(
        id: id,
        updateTitle: _titleController.text,
        updateDescription: _descriptionController.text);
    await _refreshTodos();
  }

  // todo項目削除
  Future<void> _deleteItem(int id) async {
    await Postgres.delete(id: id);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('リストを削除しました。'),
    ));
    await _refreshTodos();
  }

  @override
  void initState() {
    super.initState();
    _refreshTodos();
  }

  List<Map<String, dynamic>> _todos = [];
  Future<void> _refreshTodos() async {
    final data = await Postgres.getItem();
    setState(() {
      _todos = data!.map<Map<String, dynamic>>((row) {
        return {
          'id': row[0],
          'title': row[1],
          'description': row[2],
        };
      }).toList();
    });
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Future<void> _showForm(int? id) async {
    _titleController.clear();
    _descriptionController.clear();
    if (id != null) {
      final existingTodos = _todos.firstWhere((todo) => todo['id'] == id);
      _titleController.text = existingTodos['title'];
      _descriptionController.text = existingTodos['description'];
    }
    await showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 100,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'タイトル'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: '内容'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addItem();
                        } else {
                          await _updateItem(id);
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? '新規追加' : '更新'))
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('todoアプリ'),
      ),
      body: _todos.isEmpty
          ? const Center(
              child: Text('データがありません'),
            )
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) => Card(
                color: Colors.lightGreen,
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Text(_todos[index]['title']),
                  subtitle: Text(_todos[index]['description']),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () => _showForm(_todos[index]['id']),
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () => _deleteItem(_todos[index]['id']),
                            icon: const Icon(Icons.delete_forever_rounded))
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
        backgroundColor: Colors.lightGreen,
      ),
    );
  }
}
