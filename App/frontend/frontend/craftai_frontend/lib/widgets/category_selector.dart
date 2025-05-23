import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  final List<String> selectedCategories;
  final Function(List<String>) onCategoriesChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategories,
    required this.onCategoriesChanged,
  });

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final List<String> _allCategories = [
    '裂缝',
    '变色与沉积物',
    '表面剥落',
    '泛碱',
    '不当修补',
    '生物入侵',
    '砖缝失效',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _allCategories.map((category) {
        final isSelected = widget.selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                widget.selectedCategories.add(category);
              } else {
                widget.selectedCategories.remove(category);
              }
              widget.onCategoriesChanged(widget.selectedCategories);
            });
          },
        );
      }).toList(),
    );
  }
}