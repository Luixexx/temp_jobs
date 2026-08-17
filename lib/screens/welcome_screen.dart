import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class _SlideData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}

class WelcomeScreen extends StatefulWidget {
  final VoidCallback? onExploreOffers;
  const WelcomeScreen({super.key, this.onExploreOffers});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _slides = const [
    _SlideData(
      icon: Icons.work_outline,
      title: 'Encuentra trabajos temporales',
      subtitle:
          'Cuidado de mayores, limpieza, chofer, plomería y más — cerca de ti.',
      gradient: [Color(0xFF114F98), Color(0xFF1E88E5)],
    ),
    _SlideData(
      icon: Icons.add_business_outlined,
      title: '¿Necesitas ayuda con algo?',
      subtitle:
          'Publica una oferta en minutos y elige entre los aplicantes al mejor candidato.',
      gradient: [Color(0xFF00897B), Color(0xFF26A69A)],
    ),
    _SlideData(
      icon: Icons.verified_user_outlined,
      title: 'Seguro y transparente',
      subtitle:
          'Calificaciones, contratos claros y pagos verificados en cada oferta.',
      gradient: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user != null
                        ? '¡Hola, ${user.firstName}! 👋'
                        : '¡Bienvenido!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: slide.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(slide.icon, size: 84, color: Colors.white),
                        const SizedBox(height: 24),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Indicador de puntos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Explorar ofertas'),
                  onPressed: widget.onExploreOffers,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
