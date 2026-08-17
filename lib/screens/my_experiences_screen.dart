import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/experience.dart';
import '../models/job_type.dart';
import '../services/experience_service.dart';
import '../services/catalog_service.dart';
import '../services/upload_service.dart';

class MyExperiencesScreen extends StatefulWidget {
  const MyExperiencesScreen({super.key});

  @override
  State<MyExperiencesScreen> createState() => _MyExperiencesScreenState();
}

class _MyExperiencesScreenState extends State<MyExperiencesScreen> {
  final _service = ExperienceService();
  final _catalogService = CatalogService();

  List<Experience> _experiences = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadExperiences();
  }

  Future<void> _loadExperiences() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final experiences = await _service.getMyExperiences();
      if (!mounted) return;
      setState(() => _experiences = experiences);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMsg = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteExperience(Experience exp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar experiencia'),
        content: Text('¿Seguro que quieres eliminar "${exp.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.deleteExperience(exp.id);
      if (!mounted) return;
      setState(() => _experiences.removeWhere((e) => e.id == exp.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _showAddExperienceDialog() async {
    final titleCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final picker = ImagePicker();

    List<JobType> jobTypes = [];
    JobType? selectedJobType;
    File? certificateFile;
    bool isSaving = false;
    bool loadingCatalog = true;

    try {
      jobTypes = await _catalogService.getJobTypes();
    } catch (_) {
      // Si falla, seguimos igual: el tipo de trabajo es opcional
    }
    loadingCatalog = false;

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Agregar experiencia'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 3,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  if (!loadingCatalog && jobTypes.isNotEmpty)
                    DropdownButtonFormField<JobType>(
                      decoration: const InputDecoration(
                        labelText: 'Área relacionada (opcional)',
                      ),
                      initialValue: selectedJobType,
                      items: jobTypes
                          .map(
                            (jt) => DropdownMenuItem(
                              value: jt,
                              child: Text(jt.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => selectedJobType = value),
                    ),
                  const SizedBox(height: 12),
                  if (certificateFile != null)
                    Image.file(certificateFile!, height: 100),
                  TextButton.icon(
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Adjuntar certificado (opcional)'),
                    onPressed: () async {
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (picked != null) {
                        setDialogState(
                          () => certificateFile = File(picked.path),
                        );
                      }
                    },
                  ),
                ],
              ),
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
                        String? certificateUrl;
                        if (certificateFile != null) {
                          certificateUrl = await UploadService().uploadImage(
                            certificateFile!,
                          );
                        }
                        await _service.addExperience(
                          title: titleCtrl.text.trim(),
                          description: descriptionCtrl.text.trim(),
                          jobTypeKey: selectedJobType?.key,
                          certificateImage: certificateUrl,
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        _loadExperiences();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis experiencias')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
          ? Center(child: Text('Error: $_errorMsg'))
          : _experiences.isEmpty
          ? const Center(
              child: Text('Todavía no agregaste ninguna experiencia'),
            )
          : ListView.builder(
              itemCount: _experiences.length,
              itemBuilder: (context, index) {
                final exp = _experiences[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: exp.certificateImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              exp.certificateImage!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const CircleAvatar(child: Icon(Icons.work_outline)),
                    title: Text(
                      exp.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      exp.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteExperience(exp),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        onPressed: _showAddExperienceDialog,
      ),
    );
  }
}
