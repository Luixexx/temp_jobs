import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../services/offer_service.dart';
import 'offer_applicants_screen.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  final _offerService = OfferService();
  late Future<List<Offer>> _future;

  @override
  void initState() {
    super.initState();
    _future = _offerService.getMyOffers();
  }

  Future<void> _refresh() async {
    setState(() => _future = _offerService.getMyOffers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis ofertas publicadas')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Offer>>(
          future: _future,
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
                child: Text('Todavía no has publicado ninguna oferta'),
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
                  trailing: const Icon(Icons.people),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OfferApplicantsScreen(
                        offerId: offer.id,
                        offerTitle: offer.jobTypeName,
                      ),
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
