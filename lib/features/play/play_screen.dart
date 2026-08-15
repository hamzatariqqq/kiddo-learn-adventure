import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/premium_banner_ad.dart';
import 'letter_match/letter_match_screen.dart';
import 'number_match/number_match_screen.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  void _openGame(
      BuildContext context,
      Widget screen,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/play_screen_hero.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(
                alpha: 0.08,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.maybePop(
                            context,
                          );
                        },
                        style:
                        IconButton.styleFrom(
                          backgroundColor:
                          Colors.black
                              .withValues(
                            alpha: 0.30,
                          ),
                        ),
                        icon: const Icon(
                          Icons
                              .arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                const Spacer(),

                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    12,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 62,
                        child:
                        ElevatedButton.icon(
                          onPressed: () {
                            _openGame(
                              context,
                              const NumberMatchScreen(),
                            );
                          },
                          icon: const Icon(
                            Icons
                                .play_arrow_rounded,
                            size: 30,
                          ),
                          label: const Text(
                            'Start Playing',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            const Color(
                              0xFFFFC42E,
                            ),
                            foregroundColor:
                            const Color(
                              0xFF092052,
                            ),
                            elevation: 8,
                            shadowColor:
                            Colors.blue
                                .withValues(
                              alpha: 0.7,
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                30,
                              ),
                              side:
                              const BorderSide(
                                color:
                                Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                            OutlinedButton
                                .icon(
                              onPressed: () {
                                _openGame(
                                  context,
                                  const NumberMatchScreen(),
                                );
                              },
                              icon: const Icon(
                                Icons
                                    .numbers_rounded,
                              ),
                              label: const Text(
                                'Numbers',
                              ),
                              style:
                              OutlinedButton
                                  .styleFrom(
                                foregroundColor:
                                Colors.white,
                                backgroundColor:
                                Colors.blue
                                    .withValues(
                                  alpha: 0.75,
                                ),
                                side:
                                const BorderSide(
                                  color: Colors
                                      .white70,
                                ),
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  vertical: 15,
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    18,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                            OutlinedButton
                                .icon(
                              onPressed: () {
                                _openGame(
                                  context,
                                  const LetterMatchScreen(),
                                );
                              },
                              icon: const Icon(
                                Icons.abc_rounded,
                              ),
                              label: const Text(
                                'Letters',
                              ),
                              style:
                              OutlinedButton
                                  .styleFrom(
                                foregroundColor:
                                Colors.white,
                                backgroundColor:
                                Colors.purple
                                    .withValues(
                                  alpha: 0.75,
                                ),
                                side:
                                const BorderSide(
                                  color: Colors
                                      .white70,
                                ),
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  vertical: 15,
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const PremiumBannerAd(
                        margin:
                        EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}