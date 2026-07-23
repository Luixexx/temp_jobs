import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/job_type.dart';
import '../services/catalog_service.dart';
import '../services/offer_service.dart';
import '../services/payment_service.dart';
import '../services/upload_service.dart';

class PublishOfferScreen extends StatefulWidget {
  const PublishOfferScreen({super.key});

  @override
  State<PublishOfferScreen> createState() => _PublishOfferScreenState();
}

class _PublishOfferScreenState extends State<PublishOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catalogService = CatalogService();
  final _uploadService = UploadService();
  final _paymentService = PaymentService();
  final _offerService = OfferService();
  final _picker = ImagePicker();

  // Datos del catálogo
  List<JobType> _jobTypes = [];
  JobType? _selectedJobType;
  bool _loadingCatalog = true;

  // Campos del formulario
  String _contractType = 'temporal';
  final _descriptionCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final Map<String, dynamic> _customAnswers = {};

  // Foto
  File? _photoFile;

  // Tarjeta (pago simulado)
  final _cardCtrl = TextEditingController(text: '4242424242424242');
  final _cvvCtrl = TextEditingController(text: '123');
  final _monthCtrl = TextEditingController(text: '12');
  final _yearCtrl = TextEditingController(text: '2030');

  bool _isSubmitting = false;
  String? _errorMsg;
  String _statusMsg = '';

  @override
  void initState() {
    super.initState();
    _loadJobTypes();
  }

  Future<void> _loadJobTypes() async {
    try {
      final types = await _catalogService.getJobTypes();
      setState(() {
        _jobTypes = types;
        _loadingCatalog = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'No se pudo cargar el catálogo: $e';
        _loadingCatalog = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _photoFile = File(picked.path));
  }

  // Construye los widgets de los campos dinámicos según customFields
  List<Widget> _buildCustomFieldWidgets() {
    if (_selectedJobType == null) return [];

    return _selectedJobType!.customFields.map((field) {
      switch (field.type) {
        case 'select':
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: field.label),
              items: field.options
                  .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                  .toList(),
              onChanged: (value) => _customAnswers[field.key] = value,
              validator: (value) =>
                  (field.required && value == null) ? 'Requerido' : null,
            ),
          );
        case 'check':
          return CheckboxListTile(
            title: Text(field.label),
            value: _customAnswers[field.key] ?? false,
            onChanged: (value) =>
                setState(() => _customAnswers[field.key] = value),
          );
        case 'date':
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              decoration: InputDecoration(labelText: field.label),
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(
                    () => _customAnswers[field.key] = picked
                        .toIso8601String()
                        .split('T')
                        .first,
                  );
                }
              },
              controller: TextEditingController(
                text: _customAnswers[field.key] ?? '',
              ),
              validator: (value) =>
                  (field.required && (value == null || value.isEmpty))
                  ? 'Requerido'
                  : null,
            ),
          );
        default: // 'text' o 'number'
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              decoration: InputDecoration(labelText: field.label),
              keyboardType: field.type == 'number'
                  ? TextInputType.number
                  : TextInputType.text,
              onChanged: (value) => _customAnswers[field.key] = value,
              validator: (value) =>
                  (field.required && (value == null || value.isEmpty))
                  ? 'Requerido'
                  : null,
            ),
          );
      }
    }).toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedJobType == null) {
      setState(() => _errorMsg = 'Elige un tipo de trabajo');
      return;
    }
    if (_photoFile == null) {
      setState(() => _errorMsg = 'La foto es obligatoria');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMsg = null;
    });

    try {
      // 1. Subir la foto
      setState(() => _statusMsg = 'Subiendo foto...');
      final photoUrl = await _uploadService.uploadImage(_photoFile!);

      // 2. Procesar el pago
      setState(() => _statusMsg = 'Procesando pago...');
      final payment = await _paymentService.charge(
        cardNumber: _cardCtrl.text.trim(),
        cvv: _cvvCtrl.text.trim(),
        expMonth: int.parse(_monthCtrl.text.trim()),
        expYear: int.parse(_yearCtrl.text.trim()),
      );

      // 3. Crear la oferta
      setState(() => _statusMsg = 'Publicando oferta...');
      await _offerService.createOffer({
        'jobTypeKey': _selectedJobType!.key,
        'contractType': _contractType,
        'description': _descriptionCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'photo': photoUrl,
        'paymentId': payment.id,
        'payment': {'amount': 1500, 'currency': 'DOP'},
        if (_customAnswers.isNotEmpty) 'customAnswers': _customAnswers,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Oferta publicada con éxito!')),
      );
      Navigator.of(
        context,
      ).pop(true); // devuelve true para que la lista se refresque
    } catch (e) {
      setState(() => _errorMsg = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        _isSubmitting = false;
        _statusMsg = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar oferta')),
      body: _loadingCatalog
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<JobType>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de trabajo',
                      ),
                      items: _jobTypes
                          .map(
                            (jt) => DropdownMenuItem(
                              value: jt,
                              child: Text(jt.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        _selectedJobType = value;
                        _customAnswers.clear();
                      }),
                      validator: (value) => value == null ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de contrato',
                      ),
                      value: _contractType,
                      items: const [
                        DropdownMenuItem(
                          value: 'temporal',
                          child: Text('Temporal'),
                        ),
                        DropdownMenuItem(value: 'fijo', child: Text('Fijo')),
                        DropdownMenuItem(
                          value: 'horas',
                          child: Text('Por horas'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _contractType = value!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      maxLines: 3,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    ..._buildCustomFieldWidgets(),
                    const SizedBox(height: 8),
                    const Divider(),
                    const Text(
                      'Foto de la oferta',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_photoFile != null)
                      Image.file(_photoFile!, height: 150),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text('Elegir foto'),
                    ),
                    const Divider(),
                    const Text(
                      'Datos de pago (1 USD, simulado)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cardCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Número tarjeta',
                      ),
                    ),
                    TextFormField(
                      controller: _cvvCtrl,
                      decoration: const InputDecoration(labelText: 'CVV'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _monthCtrl,
                            decoration: const InputDecoration(labelText: 'Mes'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _yearCtrl,
                            decoration: const InputDecoration(labelText: 'Año'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_errorMsg != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _errorMsg!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? Text(
                              _statusMsg.isEmpty ? 'Publicando...' : _statusMsg,
                            )
                          : const Text('Publicar oferta'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
