import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final supabase = Supabase.instance.client;

  late final Future<List<Map<String, dynamic>>> notesFuture;

  @override
  void initState() {
    super.initState();
    notesFuture = fetchNotes();
  }

  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final data = await supabase
        .from('notes')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes from Supabase')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

              return ListTile(
                title: Text(note['title'] ?? ''),
                subtitle: Text(note['content'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
