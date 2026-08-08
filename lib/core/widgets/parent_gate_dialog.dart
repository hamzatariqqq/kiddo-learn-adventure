import 'dart:math';

import 'package:flutter/material.dart';

class ParentGateDialog extends StatefulWidget {
  const ParentGateDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ParentGateDialog(),
    );

    return result ?? false;
  }

  @override
  State<ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<ParentGateDialog> {
  final controller = TextEditingController();

  late int first;
  late int second;
  late int answer;

  @override
  void initState() {
    super.initState();

    final random = Random();

    first = random.nextInt(8) + 2;
    second = random.nextInt(8) + 2;

    answer = first + second;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      title: const Center(
        child: Text(
          "Parents Only",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock,
            size: 65,
            color: Colors.orange,
          ),

          const SizedBox(height: 20),

          const Text(
            "Please solve this question",
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 25),

          Text(
            "$first + $second = ?",
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Answer",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () {
            if (controller.text.trim() ==
                answer.toString()) {
              Navigator.pop(context, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Wrong Answer"),
                ),
              );
            }
          },
          child: const Text("Continue"),
        ),
      ],
    );
  }
}