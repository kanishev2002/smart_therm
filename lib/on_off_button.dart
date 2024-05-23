import 'package:flutter/material.dart';
import 'package:smart_therm/constants.dart';

class OnOffButton extends StatelessWidget {
  const OnOffButton({
    required this.onPressed,
    required this.active,
    required this.label,
    super.key,
  });

  final void Function() onPressed;
  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            foregroundColor: active ? Colors.blue : Colors.orange,
          ),
          child: Icon(
            active ? Icons.whatshot : Icons.whatshot_outlined,
            color: active ? Colors.orange : Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '$label ${active ? HomePageConstants.on : HomePageConstants.off}',
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}
