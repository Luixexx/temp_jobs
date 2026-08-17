import 'package:flutter/material.dart';

class OfferQuestionDraft {
  String label = '';
  String type = 'text';
  bool required = true;
  String optionsText = ''; // separadas por coma, solo si type == 'select'

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'type': type,
      'required': required,
      if (type == 'select')
        'options': optionsText
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
    };
  }
}

class QuestionsBuilder extends StatefulWidget {
  final List<OfferQuestionDraft> questions;
  final VoidCallback onChanged;
  const QuestionsBuilder({
    super.key,
    required this.questions,
    required this.onChanged,
  });

  @override
  State<QuestionsBuilder> createState() => _QuestionsBuilderState();
}

class _QuestionsBuilderState extends State<QuestionsBuilder> {
  void _addQuestion() {
    setState(() => widget.questions.add(OfferQuestionDraft()));
    widget.onChanged();
  }

  void _removeQuestion(int index) {
    setState(() => widget.questions.removeAt(index));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final q = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: q.label,
                          decoration: const InputDecoration(
                            labelText: 'Pregunta',
                          ),
                          onChanged: (v) => q.label = v,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeQuestion(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de respuesta',
                    ),
                    initialValue: q.type,
                    items: const [
                      DropdownMenuItem(
                        value: 'text',
                        child: Text('Texto libre'),
                      ),
                      DropdownMenuItem(value: 'date', child: Text('Fecha')),
                      DropdownMenuItem(
                        value: 'select',
                        child: Text('Selección (opciones)'),
                      ),
                      DropdownMenuItem(value: 'check', child: Text('Sí / No')),
                    ],
                    onChanged: (value) => setState(() => q.type = value!),
                  ),
                  if (q.type == 'select') ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: q.optionsText,
                      decoration: const InputDecoration(
                        labelText: 'Opciones (separadas por coma)',
                        hintText: 'Ej: mañana, tarde, noche',
                      ),
                      onChanged: (v) => q.optionsText = v,
                    ),
                  ],
                  Row(
                    children: [
                      Checkbox(
                        value: q.required,
                        onChanged: (v) =>
                            setState(() => q.required = v ?? true),
                      ),
                      const Text('Obligatoria'),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Agregar pregunta'),
          onPressed: _addQuestion,
        ),
      ],
    );
  }
}
