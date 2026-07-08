import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/color_data.dart';

class ColorsQuizScreen extends StatefulWidget {
  const ColorsQuizScreen({super.key});

  @override
  State<ColorsQuizScreen> createState() => _ColorsQuizScreenState();
}

class _ColorsQuizScreenState extends State<ColorsQuizScreen> {
  final colors = ColorData.items;

  int currentQuestion = 0;
  int score = 0;

  List<Map<String, dynamic>> get currentOptions {
    final correctColor = colors[currentQuestion];
    final allColors = List<Map<String, dynamic>>.from(colors);

    allColors.remove(correctColor);
    allColors.shuffle();

    final options = [
      correctColor,
      allColors[0],
      allColors[1],
      allColors[2],
    ];

    options.shuffle();
    return options;
  }

  Future<void> addStarsToFirestore(int stars) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'stars': FieldValue.increment(stars),
    });
  }

  Future<void> completeLessonInFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'completedLessons': FieldValue.increment(1),
      'streak': FieldValue.increment(1),
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = colors[currentQuestion];
    final options = currentOptions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Color Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tap the ${currentColor['name']} color',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${currentQuestion + 1} of ${colors.length}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (currentQuestion + 1) / colors.length,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(AppColors.purple),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $score',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: options.map((colorItem) {
                  return _colorButton(colorItem);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorButton(Map<String, dynamic> colorItem) {
    final color = colorItem['color'] as Color;
    final name = colorItem['name'] as String;

    return InkWell(
      onTap: () async {
        final correctName = colors[currentQuestion]['name'] as String;
        final bool isCorrect = name == correctName;

        if (isCorrect) {
          score++;
          await addStarsToFirestore(5);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCorrect ? 'Correct! 🎉 +5 Stars ⭐' : 'Try Again 😊',
            ),
            backgroundColor: isCorrect ? AppColors.green : AppColors.coral,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (currentQuestion < colors.length - 1) {
          setState(() {
            currentQuestion++;
          });
        } else {
          await completeLessonInFirestore();

          if (!mounted) return;

          Future.delayed(
            const Duration(milliseconds: 400),
                () {
              _showQuizCompleteDialog();
            },
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            name,
            style: AppTextStyles.title.copyWith(
              color: name == 'White' || name == 'Yellow'
                  ? AppColors.textPrimary
                  : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showQuizCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('🎉 Quiz Complete'),
          content: Text(
            'Your score is $score / ${colors.length}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  currentQuestion = 0;
                  score = 0;
                });
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }
}