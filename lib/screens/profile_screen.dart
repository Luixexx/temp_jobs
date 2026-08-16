import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'my_experiences_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();

  Future<void> _showChangePasswordDialog() async {
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Cambiar clave'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newPasswordCtrl,
                  decoration: const InputDecoration(labelText: 'Nueva clave'),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mínimo 6 caracteres'
                      : null,
                ),
                TextFormField(
                  controller: confirmPasswordCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar clave',
                  ),
                  obscureText: true,
                  validator: (v) =>
                      (v != newPasswordCtrl.text) ? 'No coincide' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSaving = true);
                      try {
                        await _authService.changePassword(newPasswordCtrl.text);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Clave actualizada ✅')),
                        );
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No hay sesión activa')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              child: Text(
                user.firstName.isNotEmpty
                    ? user.firstName[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${user.firstName} ${user.lastName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Center(
            child: Text(user.email, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Matrícula de referido'),
                  subtitle: Text(
                    user.referralMatricula.isNotEmpty
                        ? user.referralMatricula
                        : '—',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('Rol'),
                  subtitle: Text(user.role.isNotEmpty ? user.role : '—'),
                ),
                if (user.createdAt != null)
                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Miembro desde'),
                    subtitle: Text(user.createdAt!.split('T').first),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Cambiar clave'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showChangePasswordDialog,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.work_history_outlined),
              title: const Text('Mis experiencias'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyExperiencesScreen()),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _confirmLogout,
            ),
          ),
        ],
      ),
    );
  }
}
