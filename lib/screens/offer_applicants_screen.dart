import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/application_service.dart';

class OfferApplicantsScreen extends StatefulWidget {
  final String offerId;
  final String offerTitle;
  const OfferApplicantsScreen({
    super.key,
    required this.offerId,
    required this.offerTitle,
  });

  @override
  State<OfferApplicantsScreen> createState() => _OfferApplicantsScreenState();
}

class _OfferApplicantsScreenState extends State<OfferApplicantsScreen> {
  final _service = ApplicationService();
  late Future<List<Application>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getOfferApplications(widget.offerId);
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.getOfferApplications(widget.offerId));
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

  Future<void> _rate(Application app) async {
    int rating = app.rating ?? 3;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Calificar aplicante'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return IconButton(
                icon: Icon(
                  star <= rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => setDialogState(() => rating = star),
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    await _updateStatus(app.id, rating: rating);
  }

  Future<void> _changeStatus(Application app, String newStatus) async {
    // Confirmación extra al elegir ganador, porque crea un contrato automáticamente
    if (newStatus == 'winner') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Elegir como ganador?'),
          content: const Text(
            'Esto creará automáticamente un contrato con esta persona. '
            'Podrás fijar los términos (salario, fecha, duración) después, desde Contratos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await _updateStatus(app.id, status: newStatus);
  }

  Future<void> _updateStatus(
    String applicationId, {
    int? rating,
    String? status,
  }) async {
    try {
      await _service.updateApplication(
        applicationId,
        rating: rating,
        status: status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Actualizado ✅')));
      _refresh();
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
      appBar: AppBar(title: Text('Aplicantes: ${widget.offerTitle}')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Application>>(
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
              return const Center(child: Text('Nadie ha aplicado todavía'));
            }
            return ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                app.applicantName?.isNotEmpty == true
                                    ? app.applicantName!
                                    : (app.applicantEmail ?? 'Aplicante'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(_statusLabel(app.status)),
                              backgroundColor: _statusColor(
                                app.status,
                              ).withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: _statusColor(app.status),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(app.comment),
                        const SizedBox(height: 8),
                        if (app.rating != null)
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < app.rating!
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 16,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () => _rate(app),
                              child: const Text('Calificar'),
                            ),
                            if (app.status != 'discarded')
                              OutlinedButton(
                                onPressed: () =>
                                    _changeStatus(app, 'discarded'),
                                child: const Text('Descartar'),
                              ),
                            if (app.status != 'finalist')
                              OutlinedButton(
                                onPressed: () => _changeStatus(app, 'finalist'),
                                child: const Text('Finalista'),
                              ),
                            if (app.status != 'winner')
                              ElevatedButton(
                                onPressed: () => _changeStatus(app, 'winner'),
                                child: const Text('Elegir ganador'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
