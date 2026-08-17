import 'package:flutter/material.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;

  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;

  final TextInputType keyboardType;
  final bool obscureText;

  final int? maxLength;
  final int maxLines;
  final int? minLines;

  final bool enabled;
  final bool readOnly;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  final FocusNode? focusNode;

  final TextInputAction? textInputAction;

  final String? Function(String?)? validator;

  final Color? accentColor;

  final bool showCounter;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
    this.textInputAction,
    this.validator,
    this.accentColor,
    this.showCounter = false,
  });

  @override
  State<AnimatedTextField> createState() =>
      _AnimatedTextFieldState();
}

class _AnimatedTextFieldState
    extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;

  late final AnimationController _animationController;

  late final Animation<double> _focusAnimation;

  bool _hasFocus = false;
  bool _hasText = false;

  bool _obscurePassword = false;

  @override
  void initState() {
    super.initState();

    _focusNode =
        widget.focusNode ??
        FocusNode();

    _hasText =
        widget.controller.text.isNotEmpty;

    _obscurePassword =
        widget.obscureText;

    _focusNode.addListener(
      _handleFocusChange,
    );

    widget.controller.addListener(
      _handleTextChange,
    );

    _animationController =
        AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 220,
      ),
    );

    _focusAnimation =
        CurvedAnimation(
      parent:
          _animationController,
      curve:
          Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(
    covariant AnimatedTextField oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller !=
        widget.controller) {
      oldWidget.controller.removeListener(
        _handleTextChange,
      );

      widget.controller.addListener(
        _handleTextChange,
      );

      _hasText =
          widget.controller.text.isNotEmpty;
    }

    if (oldWidget.focusNode !=
        widget.focusNode) {
      _focusNode.removeListener(
        _handleFocusChange,
      );

      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }

      _focusNode =
          widget.focusNode ??
          FocusNode();

      _focusNode.addListener(
        _handleFocusChange,
      );
    }

    if (oldWidget.obscureText !=
        widget.obscureText) {
      _obscurePassword =
          widget.obscureText;
    }
  }

  void _handleFocusChange() {
    if (!mounted) {
      return;
    }

    setState(() {
      _hasFocus =
          _focusNode.hasFocus;
    });

    if (_hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTextChange() {
    final hasText =
        widget.controller.text.isNotEmpty;

    if (_hasText != hasText &&
        mounted) {
      setState(() {
        _hasText =
            hasText;
      });
    }
  }

  void _clearText() {
    widget.controller.clear();

    widget.onChanged?.call('');

    widget.onClear?.call();

    _focusNode.requestFocus();
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword =
          !_obscurePassword;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(
      _handleTextChange,
    );

    _focusNode.removeListener(
      _handleFocusChange,
    );

    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    final accent =
        widget.accentColor ??
        (
          isDark
              ? const Color(
                  0xFF4DB6AC,
                )
              : const Color(
                  0xFF2E6F65,
                )
        );

    final textColor =
        isDark
            ? const Color(
                0xFFF0F5F4,
              )
            : const Color(
                0xFF183832,
              );

    final hintColor =
        isDark
            ? const Color(
                0xFF8BA39D,
              )
            : const Color(
                0xFF5E7872,
              );

    final normalIconColor =
        isDark
            ? const Color(
                0xFF829D96,
              )
            : const Color(
                0xFF58766F,
              );

    final borderColor =
        _hasFocus
            ? accent
            : (
              isDark
                  ? const Color(
                      0xFF39544E,
                    )
                  : const Color(
                      0xFF789990,
                    )
            ).withValues(
              alpha: .42,
            );

    return AnimatedBuilder(
      animation:
          _focusAnimation,
      builder: (
        context,
        child,
      ) {
        return AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 220,
          ),
          curve:
              Curves.easeOutCubic,

          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              14,
            ),

            border:
                Border.all(
              color:
                  borderColor,

              width:
                  _hasFocus
                      ? 1.35
                      : 1,
            ),

            gradient:
                LinearGradient(
              begin:
                  Alignment.topLeft,

              end:
                  Alignment.bottomRight,

              colors:
                  isDark
                      ? [
                          const Color(
                            0xFF17302C,
                          ).withValues(
                            alpha: .90,
                          ),
                          const Color(
                            0xFF102622,
                          ).withValues(
                            alpha: .94,
                          ),
                        ]
                      : [
                          const Color(
                            0xFFEAF3F0,
                          ),
                          const Color(
                            0xFFDCE9E5,
                          ),
                        ],
            ),

            boxShadow:
                _hasFocus
                    ? [
                        BoxShadow(
                          color:
                              accent.withValues(
                            alpha:
                                .07 *
                                _focusAnimation.value,
                          ),
                          blurRadius:
                              10,
                          spreadRadius:
                              0,
                        ),
                      ]
                    : const [],
          ),

          child:
              ClipRRect(
            borderRadius:
                BorderRadius.circular(
              14,
            ),

            child:
                Stack(
              alignment:
                  Alignment.center,

              children: [
                // Glow interior muy discreto.
                Positioned.fill(
                  child:
                      IgnorePointer(
                    child:
                        AnimatedOpacity(
                      duration:
                          const Duration(
                        milliseconds:
                            200,
                      ),

                      opacity:
                          _hasFocus
                              ? 1
                              : .35,

                      child:
                          DecoratedBox(
                        decoration:
                            BoxDecoration(
                          gradient:
                              RadialGradient(
                            center:
                                const Alignment(
                              -.85,
                              -.75,
                            ),

                            radius:
                                1.2,

                            colors: [
                              accent.withValues(
                                alpha:
                                    isDark
                                        ? .045
                                        : .055,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                TextFormField(
                  controller:
                      widget.controller,

                  focusNode:
                      _focusNode,

                  enabled:
                      widget.enabled,

                  readOnly:
                      widget.readOnly,

                  keyboardType:
                      widget.keyboardType,

                  obscureText:
                      widget.obscureText
                          ? _obscurePassword
                          : false,

                  maxLength:
                      widget.maxLength,

                  maxLines:
                      widget.obscureText
                          ? 1
                          : widget.maxLines,

                  minLines:
                      widget.obscureText
                          ? 1
                          : widget.minLines,

                  textInputAction:
                      widget.textInputAction,

                  validator:
                      widget.validator,

                  onChanged:
                      widget.onChanged,

                  onFieldSubmitted:
                      widget.onSubmitted,

                  cursorColor:
                      accent,

                  cursorWidth:
                      1.5,

                  style:
                      TextStyle(
                    color:
                        textColor,

                    fontSize:
                        14.5,

                    fontWeight:
                        FontWeight.w500,

                    height:
                        1.1,
                  ),

                  decoration:
                      InputDecoration(
                    isDense:
                        true,

                    filled:
                        false,

                    counterText:
                        widget.showCounter
                            ? null
                            : '',

                    // =========================================================
                    // COMPACTO
                    // =========================================================

                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal:
                          13,
                      vertical:
                          11,
                    ),

                    hintText:
                        widget.hintText,

                    hintStyle:
                        TextStyle(
                      color:
                          hintColor.withValues(
                        alpha:
                            .75,
                      ),

                      fontSize:
                          13.5,

                      fontWeight:
                          FontWeight.w400,
                    ),

                    labelText:
                        widget.labelText,

                    labelStyle:
                        TextStyle(
                      color:
                          _hasFocus
                              ? accent
                              : hintColor,

                      fontSize:
                          13,

                      fontWeight:
                          FontWeight.w500,
                    ),

                    floatingLabelStyle:
                        TextStyle(
                      color:
                          accent,

                      fontSize:
                          12.5,

                      fontWeight:
                          FontWeight.w600,
                    ),

                    // =========================================================
                    // ICONO IZQUIERDO COMPACTO
                    // =========================================================

                    prefixIcon:
                        widget.prefixIcon ==
                                null
                            ? null
                            : Icon(
                                widget.prefixIcon,

                                color:
                                    _hasFocus
                                        ? accent
                                        : normalIconColor,

                                size:
                                    19,
                              ),

                    prefixIconConstraints:
                        const BoxConstraints(
                      minWidth:
                          42,
                      minHeight:
                          38,
                    ),

                    // =========================================================
                    // ACCIONES DERECHAS
                    // =========================================================

                    suffixIcon:
                        _buildSuffix(
                      accent:
                          accent,

                      normalColor:
                          normalIconColor,
                    ),

                    suffixIconConstraints:
                        const BoxConstraints(
                      minWidth:
                          40,
                      minHeight:
                          38,
                    ),

                    border:
                        InputBorder.none,

                    enabledBorder:
                        InputBorder.none,

                    focusedBorder:
                        InputBorder.none,

                    disabledBorder:
                        InputBorder.none,

                    errorBorder:
                        InputBorder.none,

                    focusedErrorBorder:
                        InputBorder.none,

                    // Error también compacto.
                    errorStyle:
                        const TextStyle(
                      fontSize:
                          11.5,

                      height:
                          1.1,
                    ),

                    errorMaxLines:
                        2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _buildSuffix({
    required Color accent,
    required Color normalColor,
  }) {
    // Para contraseña priorizamos mostrar/ocultar.
    if (widget.obscureText) {
      return IconButton(
        padding:
            EdgeInsets.zero,

        visualDensity:
            VisualDensity.compact,

        tooltip:
            _obscurePassword
                ? 'Mostrar contraseña'
                : 'Ocultar contraseña',

        onPressed:
            _togglePassword,

        icon:
            Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,

          color:
              _hasFocus
                  ? accent
                  : normalColor,

          size:
              18,
        ),
      );
    }

    // Clear solo aparece cuando existe texto.
    return AnimatedSwitcher(
      duration:
          const Duration(
        milliseconds: 160,
      ),

      transitionBuilder:
          (
        child,
        animation,
      ) {
        return FadeTransition(
          opacity:
              animation,

          child:
              ScaleTransition(
            scale:
                animation,

            child:
                child,
          ),
        );
      },

      child:
          _hasText &&
                  widget.enabled &&
                  !widget.readOnly
              ? IconButton(
                  key:
                      const ValueKey(
                    'clear',
                  ),

                  padding:
                      EdgeInsets.zero,

                  visualDensity:
                      VisualDensity.compact,

                  tooltip:
                      'Limpiar',

                  onPressed:
                      _clearText,

                  icon:
                      Icon(
                    Icons.close_rounded,

                    color:
                        _hasFocus
                            ? accent
                            : normalColor,

                    size: 18,
                    ),
                )
              : const SizedBox(
                  key:
                      ValueKey(
                    'empty',
                  ),

                  width:
                      8,
                ),
    );
  }
}