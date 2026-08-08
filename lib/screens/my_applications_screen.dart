import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/application_service.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  final _service = ApplicationService();
  late Future<List<Application>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyApplications();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'winner':
        return Colors.green;
      case 'finalist':
        return Colors.blue;
      case 'discarded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'winner':
        return 'Ganador 🏆';
      case 'finalist':
        return 'Finalista';
      case 'discarded':
        return 'Descartado';
      default:
        return 'Aplicado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis aplicaciones')),
      body: FutureBuilder<List<Application>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final apps = snapshot.data ?? [];
          if (apps.isEmpty) {
            return const Center(
              child: Text('Todavía no has aplicado a ninguna oferta'),
            );
          }
          return ListView.builder(
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return ListTile(
                title: Text(app.offerJobTypeName ?? 'Oferta ${app.offerId}'),
                subtitle: Text(
                  app.comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Chip(
                  label: Text(_statusLabel(app.status)),
                  backgroundColor: _statusColor(
                    app.status,
                  ).withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: _statusColor(app.status)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
