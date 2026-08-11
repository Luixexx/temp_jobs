import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;

  final IconData? icon;

  final bool isLoading;

  final bool isOutlined;

  final bool expand;

  final double height;

  final Color? accentColor;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.expand = true,
    this.height = 56,
    this.accentColor,
  });

  @override
  State<AnimatedButton> createState() =>
      _AnimatedActionButtonState();
}

class _AnimatedActionButtonState
    extends State<AnimatedButton> {
  bool _isPressed = false;

  bool get _enabled =>
      widget.onPressed != null &&
      !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark =
        theme.brightness == Brightness.dark;

    final accent =
        widget.accentColor ??
        (
          isDark
              ? const Color(0xFF4DB6AC)
              : const Color(0xFF2E6F65)
        );

    final accentStrong =
        isDark
            ? const Color(0xFF00796B)
            : const Color(0xFF245D55);

    final textColor =
        widget.isOutlined
            ? accent
            : Colors.white;

    final disabledColor =
        isDark
            ? const Color(0xFF29413D)
            : const Color(0xFFA8BDB7);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown:
          !_enabled
              ? null
              : (_) {
                  setState(() {
                    _isPressed = true;
                  });
                },

      onTapUp:
          !_enabled
              ? null
              : (_) {
                  setState(() {
                    _isPressed = false;
                  });
                },

      onTapCancel:
          !_enabled
              ? null
              : () {
                  setState(() {
                    _isPressed = false;
                  });
                },

      onTap:
          _enabled
              ? widget.onPressed
              : null,

      child: AnimatedScale(
        scale:
            _isPressed
                ? .975
                : 1,

        duration:
            const Duration(
          milliseconds: 120,
        ),

        curve:
            Curves.easeOut,

        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 220,
          ),

          curve:
              Curves.easeOutCubic,

          width:
              widget.expand
                  ? double.infinity
                  : null,

          height:
              widget.height,

          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              18,
            ),

            border:
                widget.isOutlined
                    ? Border.all(
                        color:
                            _enabled
                                ? accent.withValues(
                                    alpha: .55,
                                  )
                                : disabledColor,
                        width: 1.2,
                      )
                    : null,

            gradient:
                widget.isOutlined
                    ? null
                    : LinearGradient(
                        begin:
                            Alignment.topLeft,
                        end:
                            Alignment.bottomRight,

                        colors:
                            _enabled
                                ? [
                                    accent,
                                    accentStrong,
                                  ]
                                : [
                                    disabledColor,
                                    disabledColor,
                                  ],
                      ),

            color:
                widget.isOutlined
                    ? (
                      isDark
                          ? const Color(
                              0xFF102724,
                            ).withValues(
                              alpha: .62,
                            )
                          : const Color(
                              0xFFE4EFEB,
                            ).withValues(
                              alpha: .85,
                            )
                    )
                    : null,

            boxShadow:
                !_enabled ||
                        widget.isOutlined
                    ? []
                    : [
                        BoxShadow(
                          color:
                              accent.withValues(
                            alpha:
                                _isPressed
                                    ? .10
                                    : .22,
                          ),
                          blurRadius:
                              _isPressed
                                  ? 8
                                  : 20,
                          offset:
                              const Offset(
                            0,
                            8,
                          ),
                        ),
                      ],
          ),

          child: Material(
            color:
                Colors.transparent,

            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Center(
                child: AnimatedSwitcher(
                  duration:
                      const Duration(
                    milliseconds: 200,
                  ),

                  child:
                      widget.isLoading
                          ? SizedBox(
                              key:
                                  const ValueKey(
                                'loader',
                              ),

                              width: 22,
                              height: 22,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2.2,

                                color:
                                    widget.isOutlined
                                        ? accent
                                        : Colors.white,
                              ),
                            )
                          : Row(
                              key:
                                  const ValueKey(
                                'content',
                              ),

                              mainAxisSize:
                                  MainAxisSize.min,

                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [
                                if (widget.icon !=
                                    null) ...[
                                  Icon(
                                    widget.icon,
                                    size: 21,
                                    color:
                                        textColor,
                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],

                                Text(
                                  widget.text,

                                  style:
                                      TextStyle(
                                    color:
                                        _enabled
                                            ? textColor
                                            : (
                                              isDark
                                                  ? const Color(
                                                      0xFF82938F,
                                                    )
                                                  : const Color(
                                                      0xFF667A75,
                                                    )
                                            ),

                                    fontSize:
                                        15.5,

                                    fontWeight:
                                        FontWeight.w700,

                                    letterSpacing:
                                        .15,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}