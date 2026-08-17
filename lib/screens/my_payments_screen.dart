import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

class MyPaymentsScreen extends StatefulWidget {
  const MyPaymentsScreen({super.key});

  @override
  State<MyPaymentsScreen> createState() => _MyPaymentsScreenState();
}

class _MyPaymentsScreenState extends State<MyPaymentsScreen> {
  final _service = PaymentService();
  late Future<List<Payment>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyPayments();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.getMyPayments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis pagos')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Payment>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final payments = snapshot.data ?? [];
            if (payments.isEmpty) {
              return const Center(child: Text('Todavía no has hecho pagos'));
            }

            final total = payments
                .where((p) => p.status == 'approved')
                .fold<num>(0, (sum, p) => sum + p.amount);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total pagado',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$total ${payments.first.currency}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final p = payments[index];
                      final isApproved = p.status == 'approved';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isApproved
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          child: Icon(
                            isApproved ? Icons.check : Icons.close,
                            color: isApproved ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text('${p.amount} ${p.currency}'),
                        subtitle: Text(
                          p.cardLast4 != null
                              ? 'Tarjeta terminada en ${p.cardLast4}'
                              : (p.createdAt?.split('T').first ?? ''),
                        ),
                        trailing: Text(
                          isApproved ? 'Aprobado' : 'Rechazado',
                          style: TextStyle(
                            color: isApproved ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
