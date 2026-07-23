import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../services/like_service.dart';
import 'offer_detail_screen.dart';

class MyLikesScreen extends StatefulWidget {
  const MyLikesScreen({super.key});

  @override
  State<MyLikesScreen> createState() => _MyLikesScreenState();
}

class _MyLikesScreenState extends State<MyLikesScreen> {
  final _likeService = LikeService();
  late Future<List<Offer>> _future;

  @override
  void initState() {
    super.initState();
    _future = _likeService.getMyLikes();
  }

  Future<void> _refresh() async {
    setState(() => _future = _likeService.getMyLikes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis me gusta')),
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
                child: Text('No has dado me gusta a ninguna oferta'),
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
                  trailing: const Icon(Icons.favorite, color: Colors.red),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OfferDetailScreen(offerId: offer.id),
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
