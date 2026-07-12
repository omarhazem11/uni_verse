import 'package:flutter/material.dart';
import '../utils/schedule_color.dart';

class ScheduleColorPicker extends StatelessWidget {
  final String selectedHex;
  final ValueChanged<String> onChanged;

  const ScheduleColorPicker({super.key, required this.selectedHex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: plannerColorPalette.map((hex) {
        final isSelected = hex == selectedHex;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => onChanged(hex),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: colorFromHex(hex), shape: BoxShape.circle),
              child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
