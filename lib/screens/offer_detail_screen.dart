import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../services/offer_service.dart';
import '../services/application_service.dart';
import '../services/like_service.dart';

class OfferDetailScreen extends StatefulWidget {
  final String offerId;
  const OfferDetailScreen({super.key, required this.offerId});

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  final _offerService = OfferService();
  final _applicationService = ApplicationService();
  final _likeService = LikeService();
  late Future<Offer> _offerFuture;
  bool _isLiked = false;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _offerFuture = _offerService.getOfferDetail(widget.offerId);
  }

  Future<void> _toggleLike() async {
    setState(() => _isLiking = true);
    try {
      if (_isLiked) {
        await _likeService.unlike(widget.offerId);
      } else {
        await _likeService.like(widget.offerId);
      }
      setState(() => _isLiked = !_isLiked);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  Future<void> _showApplyDialog() async {
    final commentCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aplicar a esta oferta'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: commentCtrl,
            decoration: const InputDecoration(
              labelText: '¿Por qué te consideras apto?',
            ),
            maxLines: 3,
            validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _applicationService.apply(widget.offerId, commentCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('¡Aplicación enviada!')));
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
      appBar: AppBar(title: const Text('Detalle de la oferta')),
      body: FutureBuilder<Offer>(
        future: _offerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final offer = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (offer.photo.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      offer.photo,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  offer.jobTypeName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Chip(label: Text(offer.contractType)),
                const SizedBox(height: 12),
                Text(offer.description),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 4),
                    Expanded(child: Text(offer.address)),
                  ],
                ),
                if (offer.deadline != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.event, size: 18),
                      const SizedBox(width: 4),
                      Text('Fecha límite: ${offer.deadline}'),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: _isLiking ? null : _toggleLike,
                    ),
                    Text('${offer.likesCount} me gusta'),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Aplicar a esta oferta'),
                  onPressed: _showApplyDialog,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
