import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temp_jobs/widget/Components/animated_button.dart';
import 'package:temp_jobs/widget/Components/animated_text_field.dart';
import '../providers/auth_provider.dart';
import 'main_nav_screen.dart';
import 'complete_profile_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _errorMsg = null;
    });

    final auth = context.read<AuthProvider>();

    try {
      await auth.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;

      final user = context.read<AuthProvider>().user;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => (user != null && !user.profileCompleted)
              ? const CompleteProfileScreen()
              : const MainNavScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _goToRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark
        ? const Color(0xFFF2F7F5)
        : const Color(0xFF173A33);

    final secondaryColor = isDark
        ? const Color(0xFF91A7A1)
        : const Color(0xFF58736C);

    final accent = isDark ? const Color(0xFF4DB6AC) : const Color(0xFF2E6F65);

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),

                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,

                      children: [
                        const Spacer(),


                        Text(
                          'Login',

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: titleColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.7,
                          ),
                        ),

                        const SizedBox(height: 30),
         
                        AnimatedTextField(
                          controller: _emailCtrl,

                          labelText: 'Correo',

                          hintText: 'correo@ejemplo.com',

                          prefixIcon: Icons.alternate_email_rounded,

                          keyboardType: TextInputType.emailAddress,

                          textInputAction: TextInputAction.next,

                          validator: _validateEmail,
                        ),

                        const SizedBox(height: 12),

                        AnimatedTextField(
                          controller: _passwordCtrl,

                          labelText: 'Contraseña',

                          hintText: 'Ingresa tu contraseña',

                          prefixIcon: Icons.lock_outline_rounded,

                          obscureText: true,

                          textInputAction: TextInputAction.done,

                          onSubmitted: (_) {
                            if (!isLoading) {
                              _submit();
                            }
                          },

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),

                          child: _errorMsg == null
                              ? const SizedBox.shrink()
                              : Container(
                                  key: ValueKey(_errorMsg),

                                  margin: const EdgeInsets.only(bottom: 12),

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: .07),

                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: Colors.redAccent,
                                        size: 17,
                                      ),

                                      const SizedBox(width: 8),

                                      Expanded(
                                        child: Text(
                                          _errorMsg!,

                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),

                        AnimatedButton(
                          text: 'Iniciar Sesión',

                          icon: Icons.login_rounded,

                          isLoading: isLoading,

                          onPressed: isLoading ? null : _submit,
                        ),

                        const Spacer(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Text(
                              '¿No tienes cuenta?',

                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(width: 3),

                            TextButton(
                              onPressed: isLoading ? null : _goToRegister,

                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,

                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),

                                minimumSize: Size.zero,

                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),

                              child: Text(
                                'Registrarme',

                                style: TextStyle(
                                  color: accent,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Ingresa tu correo';
    }

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!regex.hasMatch(email)) {
      return 'Correo inválido';
    }

    return null;
  }
}
