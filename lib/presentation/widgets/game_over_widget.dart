import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/constants/color_constants.dart';
import '../../utils/constants/string_constants.dart';
import '../blocs/game_cubit/game_cubit.dart';

class GameOverWidget extends StatefulWidget {
  const GameOverWidget({super.key});

  @override
  State<GameOverWidget> createState() => _GameOverWidgetState();
}

class _GameOverWidgetState extends State<GameOverWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller; // made nullable

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // original speed
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose(); // null-safe dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 6),
          child: Stack(
            children: [
              // Dark overlay to improve readability without changing container styling
              Container(color: ColorConstants.color8A000000),
              Center(
                child: AnimatedBuilder(
                  animation: _controller!,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _AnimatedBorderPainter(progress: _controller!.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: ColorConstants.shimmerContainer,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              StringConstants.gameOver,
                              style: TextStyle(
                                color: ColorConstants.colorFFCA00,
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              '${StringConstants.score} ${state.currentScore}',
                              style: const TextStyle(
                                color: ColorConstants.colorFFFFFF,
                                fontSize: 22,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 54),
                            ElevatedButton(
                              onPressed: () {
                                BlocProvider.of<GameCubit>(context).restartGame();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorConstants.color2387FC,
                                foregroundColor: ColorConstants.colorFFFFFF,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                StringConstants.playAgain,
                                style: const TextStyle(
                                  fontSize: 22,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedBorderPainter extends CustomPainter {
  final double progress; // 0..1
  _AnimatedBorderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(28));

    final perimeter = 2 * (size.width + size.height);
    final currentLen = perimeter * progress;

    final fullPath = Path()..addRRect(rRect);
    final metric = fullPath.computeMetrics().first;

    final segmentLen = perimeter * 0.35; // original highlight length
    double start = currentLen - segmentLen;
    if (start < 0) start = 0;
    double end = currentLen;

    Path animatedSegment;
    if (end <= metric.length) {
      animatedSegment = metric.extractPath(start.clamp(0, metric.length), end.clamp(0, metric.length));
    } else {
      final firstPart = metric.extractPath(start.clamp(0, metric.length), metric.length);
      final remaining = end - metric.length;
      final secondPart = metric.extractPath(0, remaining.clamp(0, metric.length));
      animatedSegment = Path()
        ..addPath(firstPart, Offset.zero)
        ..addPath(secondPart, Offset.zero);
    }

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = ColorConstants.shimmerBorder;
    canvas.drawPath(fullPath, basePaint);

    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          ColorConstants.colorFFD740, // vivid amber
          ColorConstants.colorFFFFFF, // brighter start
          ColorConstants.color2387FC, // finishing blue accent
        ],
      ).createShader(rect);
    canvas.drawPath(animatedSegment, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
