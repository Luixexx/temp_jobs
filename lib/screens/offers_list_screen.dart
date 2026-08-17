import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../models/job_type.dart';
import '../services/offer_service.dart';
import '../services/catalog_service.dart';
import 'offer_detail_screen.dart';
import 'publish_offer_screen.dart';
import 'offers_map_screen.dart';

class OffersListScreen extends StatefulWidget {
  const OffersListScreen({super.key});

  @override
  State<OffersListScreen> createState() => _OffersListScreenState();
}

class _OffersListScreenState extends State<OffersListScreen> {
  final _offerService = OfferService();
  final _catalogService = CatalogService();

  late Future<List<Offer>> _offersFuture;
  List<JobType> _jobTypes = [];

  String? _selectedJobTypeKey;
  String? _selectedContractType;

  @override
  void initState() {
    super.initState();
    _offersFuture = _offerService.getOffers();
    _loadJobTypes();
  }

  Future<void> _loadJobTypes() async {
    try {
      final types = await _catalogService.getJobTypes();
      if (!mounted) return;
      setState(() => _jobTypes = types);
    } catch (_) {
      // Si falla, el filtro de tipo de trabajo simplemente no se muestra
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _offersFuture = _offerService.getOffers(
        jobTypeKey: _selectedJobTypeKey,
        contractType: _selectedContractType,
      );
    });
  }

  bool get _hasActiveFilters =>
      _selectedJobTypeKey != null || _selectedContractType != null;

  void _clearFilters() {
    setState(() {
      _selectedJobTypeKey = null;
      _selectedContractType = null;
    });
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas de empleo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Ver mapa de ofertas',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const OffersMapScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Publicar'),
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const PublishOfferScreen()),
          );
          if (created == true) _refresh();
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de trabajo',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedJobTypeKey,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ..._jobTypes.map(
                        (jt) => DropdownMenuItem(
                          value: jt.key,
                          child: Text(jt.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedJobTypeKey = value);
                      _refresh();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Contrato',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedContractType,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todos')),
                      DropdownMenuItem(
                        value: 'temporal',
                        child: Text('Temporal'),
                      ),
                      DropdownMenuItem(value: 'fijo', child: Text('Fijo')),
                      DropdownMenuItem(
                        value: 'horas',
                        child: Text('Por horas'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedContractType = value);
                      _refresh();
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.filter_alt_off, size: 18),
                  label: const Text('Quitar filtros'),
                  onPressed: _clearFilters,
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Offer>>(
                future: _offersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final offers = snapshot.data ?? [];
                  if (offers.isEmpty) {
                    return Center(
                      child: Text(
                        _hasActiveFilters
                            ? 'No hay ofertas con ese filtro'
                            : 'No hay ofertas publicadas todavía',
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return ListTile(
                        leading: offer.photo.isNotEmpty
                            ? Image.network(
                                offer.photo,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.work_outline, size: 40),
                        title: Text(offer.jobTypeName),
                        subtitle: Text(
                          offer.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text('${offer.likesCount}'),
                          ],
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                OfferDetailScreen(offerId: offer.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
