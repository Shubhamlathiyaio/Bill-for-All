import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: 'https://fymjvddpstywkpzqjrro.supabase.co', anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5bWp2ZGRwc3R5d2twenFqcnJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ2MDM3MTYsImV4cCI6MjA5MDE3OTcxNn0.-jS0mTMjR0H_eeDY1UZVNKcRzsuj5o9No8x0HoAmuSE');

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: TodoPage());
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> todos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    final response = await supabase.from('todos').select();
    setState(() {
      todos = List<Map<String, dynamic>>.from(response);
      loading = false;
    });
  }

  Future<void> addTodo() async {
    if (_controller.text.isEmpty) return;

    await supabase.from('todos').insert({
      'title': _controller.text,
      'user_id': '11111111-1111-1111-1111-111111111111', // dummy UUID
      'status': 'pending',
    });

    _controller.clear();
    fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Todos")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: "Enter todo"),
                        ),
                      ),
                      IconButton(onPressed: addTodo, icon: const Icon(Icons.add)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return ListTile(title: Text(todo['title'] ?? ''), subtitle: Text(todo['status'] ?? ''));
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
