import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temp_jobs/widget/Components/AnimatedButton.dart';
import 'package:temp_jobs/widget/Components/AnimatedTextField.dart';

import '../providers/auth_provider.dart';



import 'main_nav_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _emailCtrl =
      TextEditingController();

  final _firstNameCtrl =
      TextEditingController();

  final _lastNameCtrl =
      TextEditingController();

  final _passwordCtrl =
      TextEditingController();

  final _matriculaCtrl =
      TextEditingController();

  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _passwordCtrl.dispose();
    _matriculaCtrl.dispose();

    super.dispose();
  }

  // ===========================================================================
  // REGISTRO
  // ===========================================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ??
        false)) {
      return;
    }

    setState(() {
      _errorMsg = null;
    });

    final auth =
        context.read<AuthProvider>();

    try {
      await auth.register(
        email:
            _emailCtrl.text.trim(),

        firstName:
            _firstNameCtrl.text.trim(),

        lastName:
            _lastNameCtrl.text.trim(),

        password:
            _passwordCtrl.text,

        referralMatricula:
            _matriculaCtrl.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) =>
                  const MainNavScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMsg =
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                );
      });
    }
  }

  // ===========================================================================
  // LOGIN
  // ===========================================================================

  void _goToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) =>
                const LoginScreen(),
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final isLoading =
        context.watch<AuthProvider>().isLoading;

    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    final primary =
        isDark
            ? const Color(
                0xFF4DB6AC,
              )
            : const Color(
                0xFF2E6F65,
              );

    final titleColor =
        isDark
            ? const Color(
                0xFFF2F7F5,
              )
            : const Color(
                0xFF17352F,
              );

    final secondaryText =
        isDark
            ? const Color(
                0xFFA6BAB5,
              )
            : const Color(
                0xFF526D67,
              );

    return Scaffold(
      backgroundColor:
          Colors.transparent,

      resizeToAvoidBottomInset:
          true,

      body: SafeArea(
        child:
            SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior
                  .onDrag,

          padding:
              const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            32,
          ),

          child:
              Form(
            key:
                _formKey,

            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [
              
                // =============================================================
                // HEADER
                // =============================================================

                Center(
                  child:
                      _RegisterIcon(
                    isDark:
                        isDark,
                  ),
                ),

                const SizedBox(
                  height: 48,
                ),

                Text(
                  'Crea tu cuenta',

                  textAlign:
                      TextAlign.center,

                  style:
                      TextStyle(
                    color:
                        titleColor,

                    fontSize:
                        29,

                    height:
                        1.15,

                    fontWeight:
                        FontWeight.w800,

                    letterSpacing:
                        -.7,
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                ),

                const SizedBox(
                  height: 0,
                ),

                const SizedBox(
                  height: 15,
                ),

                AnimatedTextField(
                  controller:
                      _firstNameCtrl,

                  labelText:
                      'Nombre',

                  hintText:
                      'Escribe tu nombre',

                  prefixIcon:
                      Icons.person_outline_rounded,

                  textInputAction:
                      TextInputAction.next,

                  validator:
                      (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Ingresa tu nombre';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 13,
                ),

                AnimatedTextField(
                  controller:
                      _lastNameCtrl,

                  labelText:
                      'Apellido',

                  hintText:
                      'Escribe tu apellido',

                  prefixIcon:
                      Icons.badge_outlined,

                  textInputAction:
                      TextInputAction.next,

                  validator:
                      (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Ingresa tu apellido';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 13,
                ),

                AnimatedTextField(
                  controller:
                      _emailCtrl,

                  labelText:
                      'Correo electrónico',

                  hintText:
                      'ejemplo@correo.com',

                  prefixIcon:
                      Icons.alternate_email_rounded,

                  keyboardType:
                      TextInputType.emailAddress,

                  textInputAction:
                      TextInputAction.next,

                  validator:
                      _validateEmail,
                ),

                const SizedBox(
                  height: 13,
                ),

                AnimatedTextField(
                  controller:
                      _passwordCtrl,

                  labelText:
                      'Contraseña',

                  hintText:
                      '*******',

                  prefixIcon:
                      Icons.lock_outline_rounded,

                  obscureText:
                      true,

                  textInputAction:
                      TextInputAction.next,

                  validator:
                      (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Ingresa una contraseña';
                    }

                    if (value.length < 6) {
                      return 'Debe tener al menos 6 caracteres';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 13,
                ),

                AnimatedTextField(
                  controller:
                      _matriculaCtrl,

                  labelText:
                      'Matrícula de referido',

                  hintText:
                      'Ej. 20240001',

                  prefixIcon:
                      Icons.confirmation_number_outlined,

                  textInputAction:
                      TextInputAction.done,

                  onSubmitted:
                      (_) {
                    if (!isLoading) {
                      _submit();
                    }
                  },

                  validator:
                      (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Ingresa la matrícula del referido';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 22,
                ),

                // =============================================================
                // ERROR
                // =============================================================

                AnimatedSwitcher(
                  duration:
                      const Duration(
                    milliseconds: 250,
                  ),

                  child:
                      _errorMsg == null
                          ? const SizedBox.shrink()
                          : _ErrorMessage(
                              key:
                                  ValueKey(
                                _errorMsg,
                              ),

                              message:
                                  _errorMsg!,
                            ),
                ),

                if (_errorMsg != null)
                  const SizedBox(
                    height: 16,
                  ),

                // =============================================================
                // CTA PRINCIPAL
                // =============================================================

                AnimatedButton(
                  text:
                      'Crear mi cuenta',

                  icon:
                      Icons.person_add_alt_1_rounded,

                  isLoading:
                      isLoading,

                  onPressed:
                      isLoading
                          ? null
                          : _submit,
                ),

                const SizedBox(
                  height: 18,
                ),

                // =============================================================
                // LOGIN
                // =============================================================

                _LoginPrompt(
                  isDark:
                      isDark,

                  accent:
                      primary,

                  textColor:
                      secondaryText,

                  onPressed:
                      isLoading
                          ? null
                          : _goToLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // EMAIL VALIDATOR
  // ===========================================================================

  String? _validateEmail(
    String? value,
  ) {
    final email =
        value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    final emailRegex =
        RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(
      email,
    )) {
      return 'Ingresa un correo válido';
    }

    return null;
  }
}

// =============================================================================
// HEADER ICON
// =============================================================================

class _RegisterIcon extends StatelessWidget {
  final bool isDark;

  const _RegisterIcon({
    required this.isDark,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final accent =
        isDark
            ? const Color(
                0xFF4DB6AC,
              )
            : const Color(
                0xFF2E6F65,
              );

    return Container(
      width: 84,
      height: 84,

      decoration:
          BoxDecoration(
        shape:
            BoxShape.circle,

        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,

          colors: [
            accent.withValues(
              alpha:
                  isDark
                      ? .22
                      : .15,
            ),

            accent.withValues(
              alpha:
                  .055,
            ),
          ],
        ),

        border:
            Border.all(
          color:
              accent.withValues(
            alpha:
                .24,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
                accent.withValues(
              alpha:
                  .14,
            ),

            blurRadius:
                30,

            spreadRadius:
                2,
          ),
        ],
      ),

      child:
          Icon(
        Icons.person_add_alt_1_rounded,
        size:
            38,
        color:
            accent,
      ),
    );
  }
}

// =============================================================================
// SECTION TITLE
// =============================================================================


class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Container(
      padding:
          const EdgeInsets.all(
        13,
      ),

      decoration:
          BoxDecoration(
        color:
            (
              isDark
                  ? const Color(
                      0xFFFF6B6B,
                    )
                  : const Color(
                      0xFFB42318,
                    )
            ).withValues(
              alpha:
                  .08,
            ),

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border:
            Border.all(
          color:
              (
                isDark
                    ? const Color(
                        0xFFFF8A80,
                      )
                    : const Color(
                        0xFFB42318,
                      )
              ).withValues(
                alpha:
                    .20,
              ),
        ),
      ),

      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            Icons.error_outline_rounded,

            size:
                20,

            color:
                isDark
                    ? const Color(
                        0xFFFF8A80,
                      )
                    : const Color(
                        0xFFB42318,
                      ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child:
                Text(
              message,

              style:
                  TextStyle(
                color:
                    isDark
                        ? const Color(
                            0xFFFFCBC7,
                          )
                        : const Color(
                            0xFF8E1B12,
                          ),

                fontSize:
                    13,

                height:
                    1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// LOGIN PROMPT
// =============================================================================

class _LoginPrompt extends StatelessWidget {
  final bool isDark;

  final Color accent;

  final Color textColor;

  final VoidCallback? onPressed;

  const _LoginPrompt({
    required this.isDark,
    required this.accent,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        Text(
          '¿Ya tienes una cuenta? ',

          style:
              TextStyle(
            color:
                textColor,

            fontSize:
                13.5,
          ),
        ),

        TextButton(
          onPressed:
              onPressed,

          style:
              TextButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(
              horizontal:
                  5,
              vertical:
                  2,
            ),

            minimumSize:
                Size.zero,

            tapTargetSize:
                MaterialTapTargetSize
                    .shrinkWrap,

            foregroundColor:
                accent,
          ),

          child:
              Text(
            'Iniciar sesión',

            style:
                TextStyle(
              color:
                  accent,

              fontSize:
                  13.5,

              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

