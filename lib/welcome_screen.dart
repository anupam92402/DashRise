import 'dart:math';
import 'package:dash_rise/utils/color_constants.dart';
import 'package:dash_rise/utils/constants.dart';
import 'package:dash_rise/utils/route_names.dart';
import 'package:dash_rise/utils/string_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  final ValueNotifier<int?> lastScore = ValueNotifier<int?>(null);
  final ValueNotifier<int?> highScore = ValueNotifier<int?>(null);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);

  late AnimationController _titleController;
  late Animation<double> _titleScale;
  late AnimationController _playButtonController;
  late Animation<double> _playButtonScale;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadScores();
    _fadeController.forward();
  }

  void _initAnimations() {
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _titleScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticInOut),
    );

    _playButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _playButtonScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _playButtonController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    lastScore.dispose();
    highScore.dispose();
    isLoading.dispose();
    _titleController.dispose();
    _playButtonController.dispose();
    _fadeController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 1));
    lastScore.value = prefs.getInt(Constants.lastScore) ?? 0;
    highScore.value = prefs.getInt(Constants.highScore) ?? 0;
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedGradientBackground(controller: _gradientController),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _titleScale,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) => LinearGradient(
                        colors: const [
                          ColorConstants.colorFFD740,
                          ColorConstants.colorFF4081,
                          ColorConstants.color448AFF,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        StringConstants.dashRise,
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.colorFFFFFF,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              blurRadius: 16,
                              color: ColorConstants.color8A000000,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      StringConstants.welcome,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromRGBO(255, 255, 255, 0.93),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black26,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Listen to loading state only; internal builders handle score changes
                  ValueListenableBuilder<bool>(
                    valueListenable: isLoading,
                    builder: (context, loading, _) => ScoreCard(
                      isLoading: loading,
                      fadeAnimation: _fadeAnimation,
                      lastScore: lastScore,
                      highScore: highScore,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ValueListenableBuilder<bool>(
                    valueListenable: isLoading,
                    builder: (context, loading, _) => PlayButtonWidget(
                      enabled: !loading,
                      scale: _playButtonScale,
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(RouteNames.homeScreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  final bool isLoading;
  final Animation<double> fadeAnimation;
  final ValueNotifier<int?> lastScore;
  final ValueNotifier<int?> highScore;
  const ScoreCard({
    super.key,
    required this.isLoading,
    required this.fadeAnimation,
    required this.lastScore,
    required this.highScore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: ColorConstants.shimmerBase,
        highlightColor: ColorConstants.shimmerHighlight,
        child: Container(
          decoration: BoxDecoration(
            color: ColorConstants.shimmerContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(width: 120, height: 24, color: Colors.white),
              SizedBox(height: 12),
              Container(width: 160, height: 24, color: Colors.white),
            ],
          ),
        ),
      );
    } else {
      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.2),
            end: Offset.zero,
          ).animate(fadeAnimation),
          child: Container(
            decoration: BoxDecoration(
              color: ColorConstants.shimmerContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorConstants.shimmerBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: ColorConstants.shimmerShadow,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(28.0),
            child: Column(
              children: [
                ValueListenableBuilder<int?>(
                  valueListenable: lastScore,
                  builder: (context, last, _) => Text(
                    '${StringConstants.lastScore} $last',
                    style: TextStyle(
                      fontSize: 20,
                      color: ColorConstants.colorWhiteText,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(1,2))],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                ValueListenableBuilder<int?>(
                  valueListenable: highScore,
                  builder: (context, high, _) => Text(
                    '${StringConstants.highestScore} $high',
                    style: TextStyle(
                      fontSize: 22,
                      color: ColorConstants.colorFFD600,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.black87, offset: Offset(0,2)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

// New optimized background widget
class AnimatedGradientBackground extends StatelessWidget {
  final AnimationController controller;
  const AnimatedGradientBackground({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final progress = controller.value * pi;
        final c1 = Color.lerp(
          ColorConstants.color4527A0,
          ColorConstants.color2387FC,
          (sin(progress) * 0.5 + 0.5),
        )!;
        final c2 = Color.lerp(
          ColorConstants.colorFFCA00,
          ColorConstants.colorFF4081,
          (cos(progress) * 0.5 + 0.5),
        )!;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c1, c2],
            ),
          ),
        );
      },
    );
  }
}

// Extracted Play button widget
class PlayButtonWidget extends StatelessWidget {
  final bool enabled;
  final Animation<double> scale;
  final VoidCallback onPressed;
  const PlayButtonWidget({
    super.key,
    required this.enabled,
    required this.scale,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amberAccent,
          foregroundColor: Colors.deepPurple[900],
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 10,
          shadowColor: const Color.fromRGBO(255, 193, 7, 0.7),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, size: 28),
            SizedBox(width: 10),
            Text(StringConstants.play),
          ],
        ),
      ),
    );
  }
}
