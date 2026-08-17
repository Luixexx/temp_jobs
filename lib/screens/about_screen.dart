import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class _TeamMember {
  final String name;
  final String matricula;
  final String phone;
  final String telegramUrl;
  final String photoAsset;

  const _TeamMember({
    required this.name,
    required this.matricula,
    required this.phone,
    required this.telegramUrl,
    required this.photoAsset,
  });
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _team = [
    _TeamMember(
      name: 'Daniel Beltre',
      matricula: '2023-1408',
      phone: '8492598338',
      telegramUrl: 'https://t.me/DanielBeltr3',
      photoAsset: 'assets/team/daniel.jpeg',
    ),
    _TeamMember(
      name: 'Willy Gerson Alcántara Muñoz',
      matricula: '2023-1076',
      phone: '8094077818',
      telegramUrl: 'https://t.me/ItzXitrax',
      photoAsset: 'assets/team/willy.jpeg',
    ),
    _TeamMember(
      name: 'Elvis Jesús Hernández Suárez',
      matricula: '2021-0805',
      phone: '8498698664',
      telegramUrl: 'https://t.me/ehernandez16031124',
      photoAsset: 'assets/team/elvis.jpeg',
    ),
    _TeamMember(
      name: 'Luis Elian Pérez',
      matricula: '2021-0119',
      phone: '8492122249',
      telegramUrl: 'https://t.me/Luise1234l',
      photoAsset: 'assets/team/luis.jpg',
    ),
    _TeamMember(
      name: 'Gerald José Pascual Matos',
      matricula: '2022-2148',
      phone: '8297190529',
      telegramUrl: 'https://t.me/+18297190529',
      photoAsset: 'assets/team/gerald.jpeg',
    ),
  ];

  Future<void> _call(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el marcador')),
      );
    }
  }

  Future<void> _openTelegram(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Telegram')),
      );
    }
  }

  String _formatPhone(String phone) {
    if (phone.length != 10) return phone;
    return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.groups_outlined, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Ocupa2',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Proyecto Final — Desarrollo de Aplicaciones Móviles\nITLA · Periodo 2-2026',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Equipo de desarrollo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ..._team.map(
            (member) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(member.photoAsset),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Matrícula: ${member.matricula}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _formatPhone(member.phone),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_outlined),
                      tooltip: 'Llamar',
                      onPressed: () => _call(context, member.phone),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_outlined),
                      tooltip: 'Telegram',
                      onPressed: () =>
                          _openTelegram(context, member.telegramUrl),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
