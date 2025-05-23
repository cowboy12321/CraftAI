import 'package:flutter/material.dart';
import '../models/model_config.dart';

class ModelSelector extends StatelessWidget {
  final ModelConfig? selectedModel;
  final Function(ModelConfig?) onModelChanged;

  const ModelSelector({
    super.key,
    required this.selectedModel,
    required this.onModelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final models = ModelConfig.getAvailableModels();
    if (models.isEmpty) {
      return const Text('无可用模型', style: TextStyle(color: Colors.red));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
      child: DropdownButtonFormField<ModelConfig>(
        value: selectedModel,
        hint: const Text('选择模型'),
        isExpanded: true,
        items: models.map((model) {
          return DropdownMenuItem<ModelConfig>(
            value: model,
            child: Text(model.name),
          );
        }).toList(),
        onChanged: onModelChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}