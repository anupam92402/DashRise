import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedBorderContainer extends StatefulWidget {
  const AnimatedBorderContainer({
    super.key,
    required this.child,
    required this.gradientColors,
    this.backgroundColor = const Color.fromRGBO(255, 255, 255, 0.10),
    this.borderRadius = 28.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
    this.animationDuration = const Duration(seconds: 3),
    this.segmentFraction = 0.35,
    this.showBackdropBlur = true,
    this.darkOverlayColor,
  });

  final Widget child;
  final List<Color> gradientColors;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets padding;
  final Duration animationDuration;
  final double segmentFraction; // portion of perimeter highlighted
  final bool showBackdropBlur;
  final Color? darkOverlayColor; // if provided, draws a full-screen overlay behind container

  @override
  State<AnimatedBorderContainer> createState() => _AnimatedBorderContainerState();
}

class _AnimatedBorderContainerState extends State<AnimatedBorderContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.animationDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget core = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _AnimatedBorderPainter(
            progress: _controller.value,
            gradientColors: widget.gradientColors,
            segmentFraction: widget.segmentFraction,
            borderRadius: widget.borderRadius,
          ),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: widget.child,
          ),
        );
      },
    );

    if (widget.showBackdropBlur) {
      core = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 6),
        child: core,
      );
    }

    if (widget.darkOverlayColor != null) {
      return Stack(
        children: [
          Positioned.fill(child: Container(color: widget.darkOverlayColor)),
          Center(child: core),
        ],
      );
    }

    return Center(child: core);
  }
}

class _AnimatedBorderPainter extends CustomPainter {
  _AnimatedBorderPainter({
    required this.progress,
    required this.gradientColors,
    required this.segmentFraction,
    required this.borderRadius,
  });

  final double progress; // 0..1
  final List<Color> gradientColors;
  final double segmentFraction;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final fullPath = Path()..addRRect(rRect);
    final metric = fullPath.computeMetrics().first;
    final perimeterApprox = 2 * (size.width + size.height);
    final currentLen = perimeterApprox * progress;
    final segmentLen = perimeterApprox * segmentFraction;

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
      ..color = const Color.fromRGBO(255, 255, 255, 0.18); // shimmerBorder equivalent
    canvas.drawPath(fullPath, basePaint);

    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(colors: gradientColors).createShader(rect);
    canvas.drawPath(animatedSegment, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedBorderPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.gradientColors != gradientColors ||
      oldDelegate.segmentFraction != segmentFraction ||
      oldDelegate.borderRadius != borderRadius;
}

