import 'package:flutter/material.dart';
import '../models/contract.dart';
import '../services/contract_service.dart';
import 'contract_detail_screen.dart';

class MyContractsScreen extends StatefulWidget {
  const MyContractsScreen({super.key});

  @override
  State<MyContractsScreen> createState() => _MyContractsScreenState();
}

class _MyContractsScreenState extends State<MyContractsScreen> {
  final _service = ContractService();
  late Future<List<Contract>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyContracts();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.getMyContracts());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange; // pending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis contratos')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Contract>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final contracts = snapshot.data ?? [];
            if (contracts.isEmpty) {
              return const Center(child: Text('Todavía no tienes contratos'));
            }
            return ListView.builder(
              itemCount: contracts.length,
              itemBuilder: (context, index) {
                final c = contracts[index];
                final otherParty = c.isContratante
                    ? c.contratado
                    : c.contratante;
                return ListTile(
                  title: Text(c.jobTypeName),
                  subtitle: Text(
                    '${c.isContratante ? "Contrataste a" : "Contratado por"}: ${otherParty.nombre}',
                  ),
                  trailing: Chip(
                    label: Text(c.status),
                    backgroundColor: _statusColor(
                      c.status,
                    ).withValues(alpha: 0.15),
                    labelStyle: TextStyle(color: _statusColor(c.status)),
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ContractDetailScreen(contractId: c.id),
                      ),
                    );
                    _refresh();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
