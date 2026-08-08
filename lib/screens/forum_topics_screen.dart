import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/forum.dart';
import '../services/forum_service.dart';
import '../providers/auth_provider.dart';
import 'forum_topic_detail_screen.dart';

class ForumTopicsScreen extends StatefulWidget {
  const ForumTopicsScreen({super.key});

  @override
  State<ForumTopicsScreen> createState() => _ForumTopicsScreenState();
}

class _ForumTopicsScreenState extends State<ForumTopicsScreen> {
  final _service = ForumService();

  List<ForumTopic> _topics = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final topics = await _service.getTopics();
      if (!mounted) return;
      setState(() => _topics = topics);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMsg = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createTopicDialog() async {
    final titleCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo tema'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              TextFormField(
                controller: descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final title = titleCtrl.text.trim();
    final description = descriptionCtrl.text.trim();

    try {
      await _service.createTopic(title, description);

      // Actualización optimista: insertamos el tema ya mismo en la lista,
      // sin esperar a que el servidor confirme que ya lo puede devolver.
      final me = context.read<AuthProvider>().user;
      final optimisticTopic = ForumTopic(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        author: ForumAuthor(
          id: me?.id ?? '',
          nombre: me?.nombre ?? me?.firstName ?? 'Yo',
        ),
        commentsCount: 0,
        createdAt: DateTime.now().toIso8601String(),
        lastActivityAt: DateTime.now().toIso8601String(),
      );

      if (!mounted) return;
      setState(() => _topics = [optimisticTopic, ..._topics]);

      // En segundo plano, sincronizamos con el servidor para reemplazar
      // el tema temporal por el real (con su id verdadero).
      _loadTopics();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foro')),
      body: RefreshIndicator(
        onRefresh: _loadTopics,
        child: _isLoading && _topics.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _errorMsg != null && _topics.isEmpty
            ? Center(child: Text('Error: $_errorMsg'))
            : _topics.isEmpty
            ? const Center(child: Text('Todavía no hay temas, ¡sé el primero!'))
            : ListView.builder(
                itemCount: _topics.length,
                itemBuilder: (context, index) {
                  final topic = _topics[index];
                  return ListTile(
                    title: Text(
                      topic.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Por ${topic.author.nombre} · ${topic.commentsCount} comentarios',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ForumTopicDetailScreen(topicId: topic.id),
                        ),
                      );
                      _loadTopics();
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo tema'),
        onPressed: _createTopicDialog,
      ),
    );
  }
}
