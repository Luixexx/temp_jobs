import 'package:flutter/material.dart';
import '../models/forum.dart';
import '../services/forum_service.dart';

class ForumTopicDetailScreen extends StatefulWidget {
  final String topicId;
  const ForumTopicDetailScreen({super.key, required this.topicId});

  @override
  State<ForumTopicDetailScreen> createState() => _ForumTopicDetailScreenState();
}

class _ForumTopicDetailScreenState extends State<ForumTopicDetailScreen> {
  final _service = ForumService();
  late Future<ForumTopicDetail> _future;
  final _commentCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _future = _service.getTopicDetail(widget.topicId);
  }

  Future<void> _reload() async {
    final updated = await _service.getTopicDetail(widget.topicId);
    if (!mounted) return;
    setState(() {
      _future = Future.value(updated);
    });
  }

  Future<void> _sendComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _isSending = true);
    try {
      await _service.addComment(widget.topicId, _commentCtrl.text.trim());
      _commentCtrl.clear();
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tema')),
      body: FutureBuilder<ForumTopicDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final topic = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      topic.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Por ${topic.author.nombre}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text(topic.description),
                    const Divider(height: 32),
                    Text(
                      'Comentarios (${topic.comments.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (topic.comments.isEmpty)
                      const Text('Sé el primero en comentar'),
                    ...topic.comments.map(
                      (c) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(c.body),
                          subtitle: Text(c.author.nombre),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentCtrl,
                        enabled: !_isSending,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un comentario...',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      onPressed: _isSending ? null : _sendComment,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
