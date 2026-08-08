import 'package:flutter/material.dart';
import '../models/contract.dart';
import '../services/contract_service.dart';

class ContractDetailScreen extends StatefulWidget {
  final String contractId;
  const ContractDetailScreen({super.key, required this.contractId});

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  final _service = ContractService();
  late Future<Contract> _future;
  final _commentCtrl = TextEditingController();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _future = _service.getContractDetail(widget.contractId);
  }

  Future<void> _reloadAndWait() async {
    final updated = await _service.getContractDetail(widget.contractId);
    if (!mounted) return;
    setState(() {
      _future = Future.value(updated);
    });
  }

  Future<void> _showSnack(String msg) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _setTermsDialog() async {
    final salaryCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '3 meses');
    DateTime? startDate;
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Fijar términos del contrato'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: salaryCtrl,
                  decoration: const InputDecoration(labelText: 'Salario (DOP)'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: durationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Duración (ej: 3 meses)',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    startDate == null
                        ? 'Elegir fecha de inicio'
                        : 'Inicio: ${startDate!.toIso8601String().split('T').first}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null)
                      setDialogState(() => startDate = picked);
                  },
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
                if (formKey.currentState!.validate() && startDate != null) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await _service.setTerms(
        widget.contractId,
        salary: num.parse(salaryCtrl.text.trim()),
        startDate: startDate!.toIso8601String().split('T').first,
        duration: durationCtrl.text.trim(),
      );
      _showSnack('Términos guardados ✅');
      await _reloadAndWait();
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _accept() async {
    setState(() => _isProcessing = true);
    try {
      await _service.accept(widget.contractId);
      _showSnack('Contrato aceptado ✅');
      await _reloadAndWait();
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _isProcessing = true);
    try {
      await _service.reject(widget.contractId);
      _showSnack('Contrato rechazado');
      await _reloadAndWait();
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _isProcessing = true);
    try {
      await _service.addComment(widget.contractId, _commentCtrl.text.trim());
      _commentCtrl.clear();
      await _reloadAndWait();
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _cancelDialog() async {
    final justificationCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar contrato'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: justificationCtrl,
            decoration: const InputDecoration(labelText: 'Justificación'),
            maxLines: 2,
            validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Cancelar contrato'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await _service.cancel(widget.contractId, justificationCtrl.text.trim());
      _showSnack('Contrato cancelado');
      await _reloadAndWait();
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessing,
      child: Scaffold(
        appBar: AppBar(title: const Text('Detalle del contrato')),
        body: FutureBuilder<Contract>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final c = snapshot.data!;
            final otherParty = c.isContratante ? c.contratado : c.contratante;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.jobTypeName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Chip(label: Text(c.status)),
                  const SizedBox(height: 12),
                  Text(
                    c.isContratante
                        ? 'Contrataste a: ${otherParty.nombre} (${otherParty.email})'
                        : 'Contratante: ${otherParty.nombre} (${otherParty.email})',
                  ),
                  const SizedBox(height: 12),
                  if (c.hasTerms) ...[
                    Text('Salario: ${c.salary} ${c.currency ?? ''}'),
                    Text('Inicio: ${c.startDate}'),
                    Text('Duración: ${c.duration}'),
                  ] else
                    const Text(
                      'Aún no se han fijado los términos',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),

                  const SizedBox(height: 20),

                  // --- Acciones según rol y estado ---
                  if (c.status == 'pending' && c.isContratante)
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _setTermsDialog,
                      child: _isProcessing
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Fijar términos'),
                    ),

                  if (c.status == 'pending' && !c.isContratante && c.hasTerms)
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isProcessing ? null : _accept,
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Aceptar'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: _isProcessing ? null : _reject,
                          child: const Text('Rechazar'),
                        ),
                      ],
                    ),

                  if (c.status == 'pending' && !c.isContratante && !c.hasTerms)
                    const Text(
                      'Esperando que el contratante fije los términos...',
                    ),

                  if (c.status == 'active')
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      onPressed: _isProcessing ? null : _cancelDialog,
                      child: const Text('Cancelar contrato'),
                    ),

                  if (c.status == 'cancelled' &&
                      c.cancelJustification != null) ...[
                    const SizedBox(height: 8),
                    Text('Motivo de cancelación: ${c.cancelJustification}'),
                  ],

                  const Divider(height: 32),

                  // --- Comentarios (solo si activo) ---
                  Text(
                    'Comentarios',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...c.comments.map(
                    (cm) => ListTile(
                      dense: true,
                      title: Text(cm.body),
                      subtitle: Text(cm.by.nombre),
                    ),
                  ),
                  if (c.status == 'active')
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentCtrl,
                            enabled: !_isProcessing,
                            decoration: const InputDecoration(
                              hintText: 'Escribe un comentario',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _isProcessing ? null : _addComment,
                        ),
                      ],
                    ),

                  const Divider(height: 32),

                  // --- Fotos ---
                  Text('Fotos', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (c.photos.isEmpty) const Text('Sin fotos todavía'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: c.photos
                        .map(
                          (p) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              p.url,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
