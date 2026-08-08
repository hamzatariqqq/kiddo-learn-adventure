import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/color_data.dart';
import '../../../core/services/tts_service.dart';
import 'colors_quiz_screen.dart';

class ColorsLessonScreen extends StatefulWidget {
  const ColorsLessonScreen({super.key});

  @override
  State<ColorsLessonScreen> createState() => _ColorsLessonScreenState();
}

class _ColorsLessonScreenState extends State<ColorsLessonScreen> {
  final colors = ColorData.items;

  int currentIndex = 0;
  bool isSpeaking = false;

  Future<void> _speakCurrentColor() async {
    if (isSpeaking) return;

    final item = colors[currentIndex];

    setState(() {
      isSpeaking = true;
    });

    await TtsService.instance.speak(
      'This is the ${item['name']} color',
    );

    if (!mounted) return;

    setState(() {
      isSpeaking = false;
    });
  }

  void _previous() {
    if (currentIndex == 0) return;

    TtsService.instance.stop();

    setState(() {
      currentIndex--;
      isSpeaking = false;
    });
  }

  void _next() {
    final isLast = currentIndex == colors.length - 1;

    TtsService.instance.stop();

    if (isLast) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ColorsQuizScreen(),
        ),
      );
      return;
    }

    setState(() {
      currentIndex++;
      isSpeaking = false;
    });
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = colors[currentIndex];
    final progress = (currentIndex + 1) / colors.length;
    final isLast = currentIndex == colors.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Learn Colors'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Color ${currentIndex + 1}',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '${currentIndex + 1} / ${colors.length}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    item['color'] as Color,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: GestureDetector(
                  onTap: _speakCurrentColor,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: item['color'] as Color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (item['color'] as Color)
                                    .withValues(alpha: 0.35),
                                blurRadius: 25,
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .scale(
                          begin: const Offset(.75, .75),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        ),

                        const SizedBox(height: 25),

                        Text(
                          item['emoji'] as String,
                          style: const TextStyle(fontSize: 60),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          item['name'] as String,
                          style: AppTextStyles.headingLarge.copyWith(
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'This is the ${item['name']} color',
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton.icon(
                          onPressed: isSpeaking
                              ? null
                              : _speakCurrentColor,
                          icon: Icon(
                            isSpeaking
                                ? Icons.graphic_eq
                                : Icons.volume_up,
                          ),
                          label: Text(
                            isSpeaking
                                ? 'Speaking...'
                                : 'Listen',
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Tap anywhere to hear the color.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                      currentIndex == 0 ? null : _previous,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _next,
                      icon: Icon(
                        isLast
                            ? Icons.quiz
                            : Icons.arrow_forward,
                      ),
                      label: Text(
                        isLast
                            ? 'Start Quiz'
                            : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}