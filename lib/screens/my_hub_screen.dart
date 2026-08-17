import 'package:flutter/material.dart';
import 'my_offers_screen.dart';
import 'my_applications_screen.dart';
import 'my_contracts_screen.dart';
import 'my_likes_screen.dart';
import 'publish_offer_screen.dart';
import 'settings_screen.dart';
import 'news_list_screen.dart';
import 'videos_screen.dart';
import 'my_payments_screen.dart';

class MyHubScreen extends StatelessWidget {
  const MyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis cosas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HubCard(
            icon: Icons.add_circle_outline,
            title: 'Publicar oferta',
            subtitle: 'Crea una nueva oferta de empleo',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PublishOfferScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.work_history_outlined,
            title: 'Mis ofertas publicadas',
            subtitle: 'Ver aplicantes y elegir ganadores',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MyOffersScreen())),
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.list_alt_outlined,
            title: 'Mis aplicaciones',
            subtitle: 'Ofertas a las que has aplicado',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.assignment_outlined,
            title: 'Mis contratos',
            subtitle: 'Contratos activos, pendientes y finalizados',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyContractsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.favorite_border,
            title: 'Mis me gusta',
            subtitle: 'Ofertas guardadas',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MyLikesScreen())),
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.newspaper_outlined,
            title: 'Noticias de empleo',
            subtitle: 'Últimas novedades del sector laboral',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NewsListScreen())),
          ),

          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.play_circle_outline,
            title: 'Videos de empleo',
            subtitle: 'Tutoriales y capacitación en video',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const VideosScreen())),
          ),

          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.receipt_long_outlined,
            title: 'Mis pagos',
            subtitle: 'Historial de pagos realizados',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MyPaymentsScreen())),
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
