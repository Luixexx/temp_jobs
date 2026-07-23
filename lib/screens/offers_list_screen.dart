import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../services/offer_service.dart';
import 'offer_detail_screen.dart';
import 'publish_offer_screen.dart';

class OffersListScreen extends StatefulWidget {
  const OffersListScreen({super.key});

  @override
  State<OffersListScreen> createState() => _OffersListScreenState();
}

class _OffersListScreenState extends State<OffersListScreen> {
  final _offerService = OfferService();

  late Future<List<Offer>> _offersFuture;

  @override
  void initState() {
    super.initState();
    _offersFuture = _offerService.getOffers();
  }

  Future<void> _refresh() async {
    setState(() {
      _offersFuture = _offerService.getOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ofertas de empleo')),
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
      body: RefreshIndicator(
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
              return const Center(
                child: Text('No hay ofertas publicadas todavía'),
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
                      const Icon(Icons.favorite, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text('${offer.likesCount}'),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OfferDetailScreen(offerId: offer.id),
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
