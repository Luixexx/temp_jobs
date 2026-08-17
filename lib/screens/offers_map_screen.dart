import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/offer.dart';
import '../services/offer_service.dart';
import 'offer_detail_screen.dart';

class OffersMapScreen extends StatefulWidget {
  const OffersMapScreen({super.key});

  @override
  State<OffersMapScreen> createState() => _OffersMapScreenState();
}

class _OffersMapScreenState extends State<OffersMapScreen> {
  final _offerService = OfferService();
  List<Offer> _offersWithLocation = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final offers = await _offerService.getOffers();
      if (!mounted) return;
      setState(() {
        _offersWithLocation = offers.where((o) => o.hasLocation).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMsg = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showOfferPreview(Offer offer) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (offer.photo.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      offer.photo,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.jobTypeName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        offer.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OfferDetailScreen(offerId: offer.id),
                    ),
                  );
                },
                child: const Text('Ver detalle'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Centro por defecto: Santo Domingo
    const defaultCenter = LatLng(18.4861, -69.9312);

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de ofertas')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
          ? Center(child: Text('Error: $_errorMsg'))
          : Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: defaultCenter,
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.temp_jobs',
                    ),
                    MarkerLayer(
                      markers: _offersWithLocation.map((offer) {
                        return Marker(
                          point: LatLng(offer.latitude!, offer.longitude!),
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () => _showOfferPreview(offer),
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (_offersWithLocation.isEmpty)
                  Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Ninguna oferta tiene ubicación registrada todavía',
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    onPressed: _loadOffers,
                    child: const Icon(Icons.refresh),
                  ),
                ),
              ],
            ),
    );
  }
}
