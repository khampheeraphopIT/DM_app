import 'package:flutter/material.dart';

class ProvinceDropdown extends StatelessWidget {
  final List<String> provinces;
  final String? selectedProvince;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  const ProvinceDropdown({
    super.key,
    required this.provinces,
    this.selectedProvince,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select Province',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            errorText: errorText,
          ),
          value: selectedProvince,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('-- Selected Province --'),
            ),
            ...provinces.map(
              (province) =>
                  DropdownMenuItem(value: province, child: Text(province)),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
