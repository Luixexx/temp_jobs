import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedJobBackground extends StatefulWidget {
  final Widget child;

  final bool enableParticles;

  final double intensity;

  final Duration? orbMovementDuration;

  const AnimatedJobBackground({
    super.key,
    required this.child,
    this.enableParticles = true,
    this.intensity = 1.0,
    this.orbMovementDuration,
  });

  @override
  State<AnimatedJobBackground> createState() =>
      _AnimatedJobBackgroundState();
}

class _AnimatedJobBackgroundState extends State<AnimatedJobBackground>
    with TickerProviderStateMixin {
  static const Duration _defaultOrbDuration =
      Duration(seconds: 45);

  late final AnimationController _networkController;
  late final AnimationController _orbController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  Duration get _safeOrbDuration =>
      widget.orbMovementDuration ??
      _defaultOrbDuration;

  @override
  void initState() {
    super.initState();

    _networkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _orbController = AnimationController(
      vsync: this,
      duration: _safeOrbDuration,
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 13),
    )..repeat();
  }

  @override
  void didUpdateWidget(
    covariant AnimatedJobBackground oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    final oldDuration =
        oldWidget.orbMovementDuration ??
        _defaultOrbDuration;

    final newDuration =
        widget.orbMovementDuration ??
        _defaultOrbDuration;

    if (oldDuration != newDuration) {
      _orbController.duration = newDuration;

      if (!_orbController.isAnimating) {
        _orbController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _networkController.dispose();
    _orbController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark =
        theme.brightness == Brightness.dark;

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ??
            false;

    if (disableAnimations) {
      return _StaticBackground(
        isDark: isDark,
        child: widget.child,
      );
    }

    return ColoredBox(
      color: isDark
          ? const Color(0xFF071917)
          : const Color(0xFFC6DCD5),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: _BaseGradient(
              isDark: isDark,
            ),
          ),

          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _orbController,
                  _pulseController,
                ]),
                builder: (context, _) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _OrbPainter(
                      animationValue:
                          _orbController.value,
                      pulseValue:
                          _pulseController.value,
                      isDark:
                          isDark,
                      intensity:
                          widget.intensity,
                    ),
                  );
                },
              ),
            ),
          ),

          if (widget.enableParticles)
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation:
                      _networkController,
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter:
                          _NetworkPainter(
                        progress:
                            _networkController.value,
                        isDark:
                            isDark,
                        intensity:
                            widget.intensity,
                      ),
                    );
                  },
                ),
              ),
            ),

          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation:
                    _shimmerController,
                builder: (context, _) {
                  return _MovingLight(
                    progress:
                        _shimmerController.value,
                    isDark:
                        isDark,
                  );
                },
              ),
            ),
          ),

          widget.child,
        ],
      ),
    );
  }
}

// =============================================================================
// FONDO PREMIUM
// =============================================================================

class _BaseGradient extends StatelessWidget {
  final bool isDark;

  const _BaseGradient({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        // =========================================================================
        // BASE PRINCIPAL
        // =========================================================================

        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xFF071917),
                      Color(0xFF0B211E),
                      Color(0xFF102B27),
                      Color(0xFF12332E),
                      Color(0xFF0D2723),
                      Color(0xFF071816),
                    ]
                  : const [
                      Color(0xFFBFD6CF),
                      Color(0xFFC8DDD7),
                      Color(0xFFD3E5E0),
                      Color(0xFFC4DBD4),
                      Color(0xFFB8D0C8),
                      Color(0xFFC6DCD5),
                    ],
              stops: const [
                0.0,
                .18,
                .38,
                .58,
                .80,
                1.0,
              ],
            ),
          ),
        ),

        // =========================================================================
        // ILUMINACIÓN CENTRAL
        // =========================================================================

        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(
                .10,
                -.15,
              ),
              radius: 1.15,
              colors: isDark
                  ? [
                      const Color(
                        0xFF3DB9AA,
                      ).withValues(
                        alpha: .15,
                      ),
                      const Color(
                        0xFF168D80,
                      ).withValues(
                        alpha: .075,
                      ),
                      Colors.transparent,
                    ]
                  : [
                      const Color(
                        0xFFEAF5F2,
                      ).withValues(
                        alpha: .65,
                      ),
                      const Color(
                        0xFFB7D6CE,
                      ).withValues(
                        alpha: .28,
                      ),
                      const Color(
                        0xFF78AFA5,
                      ).withValues(
                        alpha: .10,
                      ),
                      Colors.transparent,
                    ],
              stops: const [
                0.0,
                .30,
                .65,
                1.0,
              ],
            ),
          ),
        ),

        // =========================================================================
        // LUZ INFERIOR IZQUIERDA
        // =========================================================================

        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(
                -.85,
                .70,
              ),
              radius: .90,
              colors: [
                (
                  isDark
                      ? const Color(
                          0xFF00695C,
                        )
                      : const Color(
                          0xFF4C8B7F,
                        )
                ).withValues(
                  alpha:
                      isDark
                          ? .075
                          : .10,
                ),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // =========================================================================
        // LUZ SUPERIOR DERECHA
        // =========================================================================

        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(
                .95,
                -.55,
              ),
              radius: .95,
              colors: [
                (
                  isDark
                      ? const Color(
                          0xFF26A69A,
                        )
                      : const Color(
                          0xFF6E9F96,
                        )
                ).withValues(
                  alpha:
                      isDark
                          ? .06
                          : .075,
                ),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // =========================================================================
        // GRADIENTE METÁLICO DIAGONAL
        // =========================================================================

        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(
                -1.0,
                -1.0,
              ),
              end: const Alignment(
                1.0,
                1.0,
              ),
              colors: [
                Colors.transparent,

                (
                  isDark
                      ? const Color(
                          0xFF80CBC4,
                        )
                      : const Color(
                          0xFFE6F1EE,
                        )
                ).withValues(
                  alpha:
                      isDark
                          ? .018
                          : .24,
                ),

                Colors.transparent,

                (
                  isDark
                      ? const Color(
                          0xFF4DB6AC,
                        )
                      : const Color(
                          0xFF4E8279,
                        )
                ).withValues(
                  alpha:
                      isDark
                          ? .023
                          : .055,
                ),

                Colors.transparent,

                (
                  isDark
                      ? const Color(
                          0xFF80CBC4,
                        )
                      : const Color(
                          0xFFDCEBE7,
                        )
                ).withValues(
                  alpha:
                      isDark
                          ? .012
                          : .18,
                ),

                Colors.transparent,
              ],
              stops: const [
                0.0,
                .18,
                .31,
                .49,
                .64,
                .82,
                1.0,
              ],
            ),
          ),
        ),

        // =========================================================================
        // SATINADO CENTRAL
        // =========================================================================

        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin:
                  Alignment.centerLeft,
              end:
                  Alignment.centerRight,
              colors: [
                Colors.transparent,

                (
                  isDark
                      ? const Color(
                          0xFF80CBC4,
                        )
                      : const Color(
                          0xFFE7F1EE,
                        )
                ).withValues(
                  alpha:
                      isDark
                          ? .009
                          : .22,
                ),

                Colors.transparent,

                (
                  isDark
                      ? const Color(
                          0xFF26A69A,
                        )
                      : const Color(
                          0xFF42746B,
                        )
                ).withValues(
                  alpha:
                      isDark
                          ? .013
                          : .040,
                ),

                Colors.transparent,
              ],
              stops: const [
                0.0,
                .26,
                .45,
                .72,
                1.0,
              ],
            ),
          ),
        ),

        // =========================================================================
        // VIÑETA
        // =========================================================================

        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center:
                  Alignment.center,
              radius:
                  1.05,
              colors: [
                Colors.transparent,
                Colors.transparent,

                (
                  isDark
                      ? const Color(
                          0xFF071B18,
                        )
                      : const Color(
                          0xFF3F7168,
                        )
                ).withValues(
                  alpha:
                      isDark
                          ? .08
                          : .065,
                ),
              ],
              stops: const [
                0.0,
                .68,
                1.0,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// ORBES
// =============================================================================

class _OrbPainter extends CustomPainter {
  final double animationValue;
  final double pulseValue;
  final bool isDark;
  final double intensity;

  _OrbPainter({
    required this.animationValue,
    required this.pulseValue,
    required this.isDark,
    required this.intensity,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // =========================================================================
    // COLORES
    // =========================================================================
    //
    // Light Mode:
    // verdes más oscuros para que los orbes
    // se perciban sobre el fondo claro.
    //
    // No son burbujas.
    // Son zonas de energía / luz difusa.
    // =========================================================================

    final primaryColor =
        isDark
            ? const Color(
                0xFF26A69A,
              )
            : const Color(
                0xFF2E6F65,
              );

    final secondaryColor =
        isDark
            ? const Color(
                0xFF80CBC4,
              )
            : const Color(
                0xFF3B7D72,
              );

    final accentColor =
        isDark
            ? const Color(
                0xFF00695C,
              )
            : const Color(
                0xFF245D55,
              );

    final time =
        animationValue *
        math.pi *
        2;

    // =========================================================================
    // ORBE 1
    // =========================================================================

    final orb1X =
        size.width * .18 +
        math.sin(time) *
            size.width *
            .16;

    final orb1Y =
        size.height * .18 +
        math.sin(time * 2) *
            size.height *
            .09;

    _drawOrb(
      canvas,
      Offset(
        orb1X,
        orb1Y,
      ),
      radius:
          size.width *
          (
            .30 +
            pulseValue * .025
          ),
      color:
          primaryColor,
      opacity:
          (
            isDark
                ? .11
                : .10
          ) *
          intensity,
      isDark:
          isDark,
    );

    // =========================================================================
    // ORBE 2
    // =========================================================================

    final orb2X =
        size.width * .80 +
        math.cos(time) *
            size.width *
            .17;

    final orb2Y =
        size.height * .36 +
        math.sin(time * 2) *
            size.height *
            .11;

    _drawOrb(
      canvas,
      Offset(
        orb2X,
        orb2Y,
      ),
      radius:
          size.width *
          (
            .27 +
            pulseValue * .020
          ),
      color:
          secondaryColor,
      opacity:
          (
            isDark
                ? .080
                : .085
          ) *
          intensity,
      isDark:
          isDark,
    );

    // =========================================================================
    // ORBE 3
    // =========================================================================

    final orb3X =
        size.width * .23 +
        math.cos(time) *
            size.width *
            .20;

    final orb3Y =
        size.height * .70 +
        math.sin(time * 2) *
            size.height *
            .10;

    _drawOrb(
      canvas,
      Offset(
        orb3X,
        orb3Y,
      ),
      radius:
          size.width *
          (
            .34 +
            pulseValue * .025
          ),
      color:
          accentColor,
      opacity:
          (
            isDark
                ? .12
                : .095
          ) *
          intensity,
      isDark:
          isDark,
    );

    // =========================================================================
    // ORBE 4
    // =========================================================================

    final orb4X =
        size.width * .78 +
        math.sin(time) *
            size.width *
            .14;

    final orb4Y =
        size.height * .82 +
        math.sin(time * 2) *
            size.height *
            .08;

    _drawOrb(
      canvas,
      Offset(
        orb4X,
        orb4Y,
      ),
      radius:
          size.width *
          (
            .21 +
            pulseValue * .018
          ),
      color:
          primaryColor,
      opacity:
          (
            isDark
                ? .075
                : .070
          ) *
          intensity,
      isDark:
          isDark,
    );

    // =========================================================================
    // ORBE 5
    // =========================================================================

    final orb5X =
        size.width * .50 +
        math.sin(
              time + math.pi,
            ) *
            size.width *
            .19;

    final orb5Y =
        size.height * .50 +
        math.sin(
              time * 2 +
                  math.pi / 2,
            ) *
            size.height *
            .12;

    _drawOrb(
      canvas,
      Offset(
        orb5X,
        orb5Y,
      ),
      radius:
          size.width *
          (
            .22 +
            pulseValue * .017
          ),
      color:
          secondaryColor,
      opacity:
          (
            isDark
                ? .055
                : .060
          ) *
          intensity,
      isDark:
          isDark,
    );
  }

  // =============================================================================
  // DIBUJO DEL ORBE
  // =============================================================================
  //
  // Sin borde brillante.
  // Sin reflejo desplazado.
  // Sin apariencia de vidrio.
  //
  // El efecto es:
  //
  // - energía difusa
  // - núcleo luminoso
  // - halo externo
  // - desvanecido progresivo
  //
  // =============================================================================

  void _drawOrb(
    Canvas canvas,
    Offset center, {
    required double radius,
    required Color color,
    required double opacity,
    required bool isDark,
  }) {
    final safeOpacity =
        opacity.clamp(
          0.0,
          1.0,
        );

    // =========================================================================
    // 1. HALO EXTERIOR
    // =========================================================================
    //
    // Crea la retroiluminación alrededor del orbe.
    // =========================================================================

    final outerRadius =
        radius * 1.50;

    final outerRect =
        Rect.fromCircle(
      center:
          center,
      radius:
          outerRadius,
    );

    final outerGradient =
        RadialGradient(
      center:
          Alignment.center,
      radius:
          1.0,
      colors: [
        color.withValues(
          alpha:
              safeOpacity *
              (isDark
                  ? .24
                  : .25),
        ),

        color.withValues(
          alpha:
              safeOpacity *
              .11,
        ),

        color.withValues(
          alpha:
              safeOpacity *
              .035,
        ),

        Colors.transparent,
      ],
      stops: const [
        0.0,
        .38,
        .70,
        1.0,
      ],
    );

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..shader =
            outerGradient.createShader(
              outerRect,
            ),
    );

    // =========================================================================
    // 2. ORBE PRINCIPAL
    // =========================================================================
    //
    // El gradiente está completamente CENTRADO.
    //
    // Esto es importante porque evita
    // que parezca una burbuja física.
    // =========================================================================

    final orbRect =
        Rect.fromCircle(
      center:
          center,
      radius:
          radius,
    );

    final orbGradient =
        RadialGradient(
      center:
          Alignment.center,
      radius:
          1.0,
      colors: [
        color.withValues(
          alpha:
              safeOpacity *
              1.00,
        ),

        color.withValues(
          alpha:
              safeOpacity *
              .78,
        ),

        color.withValues(
          alpha:
              safeOpacity *
              .48,
        ),

        color.withValues(
          alpha:
              safeOpacity *
              .22,
        ),

        color.withValues(
          alpha:
              safeOpacity *
              .07,
        ),

        Colors.transparent,
      ],
      stops: const [
        0.0,
        .20,
        .43,
        .64,
        .82,
        1.0,
      ],
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader =
            orbGradient.createShader(
              orbRect,
            ),
    );

    // =========================================================================
    // 3. NÚCLEO DE ENERGÍA
    // =========================================================================
    //
    // No es un reflejo.
    //
    // Está perfectamente centrado para
    // dar sensación de energía interna.
    // =========================================================================

    final coreRadius =
        radius * .48;

    final coreRect =
        Rect.fromCircle(
      center:
          center,
      radius:
          coreRadius,
    );

    final coreColor =
        isDark
            ? const Color(
                0xFF9AD8D0,
              )
            : const Color(
                0xFF2B665D,
              );

    final coreGradient =
        RadialGradient(
      center:
          Alignment.center,
      radius:
          1.0,
      colors: [
        coreColor.withValues(
          alpha:
              safeOpacity *
              (isDark
                  ? .28
                  : .18),
        ),

        coreColor.withValues(
          alpha:
              safeOpacity *
              .10,
        ),

        Colors.transparent,
      ],
      stops: const [
        0.0,
        .52,
        1.0,
      ],
    );

    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..shader =
            coreGradient.createShader(
              coreRect,
            ),
    );
  }

  @override
  bool shouldRepaint(
    covariant _OrbPainter oldDelegate,
  ) {
    return oldDelegate.animationValue !=
            animationValue ||
        oldDelegate.pulseValue !=
            pulseValue ||
        oldDelegate.isDark !=
            isDark ||
        oldDelegate.intensity !=
            intensity;
  }
}

// =============================================================================
// RED
// =============================================================================

class _NetworkPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final double intensity;

  _NetworkPainter({
    required this.progress,
    required this.isDark,
    required this.intensity,
  });

  static const _points = [
    Offset(.08, .17),
    Offset(.26, .09),
    Offset(.45, .19),
    Offset(.70, .08),
    Offset(.91, .20),

    Offset(.14, .37),
    Offset(.34, .31),
    Offset(.61, .38),
    Offset(.84, .34),

    Offset(.07, .58),
    Offset(.29, .53),
    Offset(.51, .61),
    Offset(.75, .54),
    Offset(.94, .64),

    Offset(.17, .78),
    Offset(.41, .83),
    Offset(.66, .75),
    Offset(.88, .87),
  ];

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final time =
        progress *
        math.pi *
        2;

    final animatedPoints =
        <Offset>[];

    for (
      int i = 0;
      i < _points.length;
      i++
    ) {
      final point =
          _points[i];

      final dx =
          math.sin(
            time +
                i * .8,
          ) *
          7;

      final dy =
          math.cos(
            time +
                i * .75,
          ) *
          6;

      animatedPoints.add(
        Offset(
          point.dx *
                  size.width +
              dx,
          point.dy *
                  size.height +
              dy,
        ),
      );
    }

    final baseLineColor =
        isDark
            ? const Color(
                0xFF4DB6AC,
              )
            : const Color(
                0xFF245D55,
              );

    const connectionDistance =
        150.0;

    for (
      int i = 0;
      i <
          animatedPoints.length;
      i++
    ) {
      for (
        int j = i + 1;
        j <
            animatedPoints.length;
        j++
      ) {
        final distance =
            (
              animatedPoints[i] -
                  animatedPoints[j]
            ).distance;

        if (
          distance <
              connectionDistance
        ) {
          final strength =
              1 -
              (
                distance /
                    connectionDistance
              );

          final alpha =
              (
                isDark
                    ? .055
                    : .070
              ) *
              intensity *
              strength;

          final paint =
              Paint()
                ..strokeWidth =
                    .6 +
                    strength *
                        .5
                ..style =
                    PaintingStyle
                        .stroke
                ..strokeCap =
                    StrokeCap.round
                ..color =
                    baseLineColor
                        .withValues(
                  alpha:
                      alpha.clamp(
                    0.0,
                    1.0,
                  ),
                );

          canvas.drawLine(
            animatedPoints[i],
            animatedPoints[j],
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _NetworkPainter oldDelegate,
  ) {
    return oldDelegate.progress !=
            progress ||
        oldDelegate.isDark !=
            isDark ||
        oldDelegate.intensity !=
            intensity;
  }
}

// =============================================================================
// BRILLO METÁLICO MÓVIL
// =============================================================================

class _MovingLight extends StatelessWidget {
  final double progress;
  final bool isDark;

  const _MovingLight({
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final position =
        -1.8 +
        progress *
            3.6;

    final screenSize =
        MediaQuery.sizeOf(
      context,
    );

    return IgnorePointer(
      child:
          Transform.translate(
        offset:
            Offset(
          screenSize.width *
              position,
          0,
        ),

        child:
            Transform.rotate(
          angle:
              -.25,

          child:
              Align(
            alignment:
                Alignment.center,

            child:
                Container(
              width:
                  170,

              height:
                  screenSize.height *
                      1.5,

              decoration:
                  BoxDecoration(
                gradient:
                    LinearGradient(
                  colors: [
                    Colors.transparent,

                    (
                      isDark
                          ? const Color(
                              0xFF80CBC4,
                            )
                          : const Color(
                              0xFF3E776D,
                            )
                    ).withValues(
                      alpha:
                          isDark
                              ? .018
                              : .025,
                    ),

                    (
                      isDark
                          ? const Color(
                              0xFFB2DFDB,
                            )
                          : const Color(
                              0xFFD8EAE5,
                            )
                    ).withValues(
                      alpha:
                          isDark
                              ? .010
                              : .095,
                    ),

                    (
                      isDark
                          ? const Color(
                              0xFF4DB6AC,
                            )
                          : const Color(
                              0xFF4B8177,
                            )
                    ).withValues(
                      alpha:
                          isDark
                              ? .013
                              : .020,
                    ),

                    Colors.transparent,
                  ],
                  stops: const [
                    0.0,
                    .37,
                    .50,
                    .63,
                    1.0,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FONDO ESTÁTICO
// =============================================================================

class _StaticBackground extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _StaticBackground({
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ColoredBox(
      color:
          isDark
              ? const Color(
                  0xFF071917,
                )
              : const Color(
                  0xFFC6DCD5,
                ),

      child:
          Stack(
        fit:
            StackFit.expand,

        children: [
          Positioned.fill(
            child:
                _BaseGradient(
              isDark:
                  isDark,
            ),
          ),

          // Orbe estático ambiental.
          Positioned(
            right:
                -110,

            top:
                -90,

            child:
                IgnorePointer(
              child:
                  Container(
                width:
                    330,

                height:
                    330,

                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,

                  gradient:
                      RadialGradient(
                    center:
                        Alignment.center,

                    colors: [
                      (
                        isDark
                            ? const Color(
                                0xFF009688,
                              )
                            : const Color(
                                0xFF2E6F65,
                              )
                      ).withValues(
                        alpha:
                            isDark
                                ? .10
                                : .08,
                      ),

                      (
                        isDark
                            ? const Color(
                                0xFF00695C,
                              )
                            : const Color(
                                0xFF3B7D72,
                              )
                      ).withValues(
                        alpha:
                            isDark
                                ? .035
                                : .025,
                      ),

                      Colors.transparent,
                    ],

                    stops: const [
                      0.0,
                      .45,
                      1.0,
                    ],
                  ),
                ),
              ),
            ),
          ),

          child,
        ],
      ),
    );
  }
}