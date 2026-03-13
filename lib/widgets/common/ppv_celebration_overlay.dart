import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/ppv_finalize_result.dart';

class PpvCelebrationOverlay extends StatefulWidget {
  const PpvCelebrationOverlay({
    required this.outcome,
    required this.onCompleted,
    super.key,
  });

  final PpvUserOutcome outcome;
  final VoidCallback onCompleted;

  @override
  State<PpvCelebrationOverlay> createState() => _PpvCelebrationOverlayState();
}

class _PpvCelebrationOverlayState extends State<PpvCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted();
        }
      });

    if (widget.outcome != PpvUserOutcome.none) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant PpvCelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.outcome != oldWidget.outcome && widget.outcome != PpvUserOutcome.none) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.outcome == PpvUserOutcome.none) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeOut.transform(_controller.value);
            final opacity = (1.0 - max(0.0, (t - 0.75) / 0.25)).clamp(0.0, 1.0);

            return Opacity(
              opacity: opacity,
              child: CustomPaint(
                painter: widget.outcome == PpvUserOutcome.allCorrect
                    ? _ConfettiPainter(progress: t)
                    : _PoopExplosionPainter(progress: t),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.x,
    required this.size,
    required this.speed,
    required this.phase,
    required this.color,
  });

  final double x;
  final double size;
  final double speed;
  final double phase;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});

  final double progress;

  static final List<_ConfettiParticle> _particles = List.generate(140, (i) {
    final rnd = Random(1337 + i);
    final colors = <Color>[
      Colors.amber,
      Colors.redAccent,
      Colors.lightBlueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.white,
    ];
    return _ConfettiParticle(
      x: rnd.nextDouble(),
      size: 3 + rnd.nextDouble() * 5,
      speed: 0.7 + rnd.nextDouble() * 1.6,
      phase: rnd.nextDouble() * pi * 2,
      color: colors[rnd.nextInt(colors.length)],
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      final y = (progress * p.speed) % 1.1;
      final dy = y * size.height;
      final sway = sin(progress * 6 + p.phase) * 18;
      final dx = p.x * size.width + sway;

      final rect = Rect.fromCenter(
        center: Offset(dx, dy),
        width: p.size * 1.2,
        height: p.size * 2.6,
      );

      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(sin(progress * 10 + p.phase) * 0.6);
      canvas.translate(-rect.center.dx, -rect.center.dy);

      paint.color = p.color.withValues(alpha: 0.95);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PoopParticle {
  const _PoopParticle({
    required this.angle,
    required this.distance,
    required this.size,
  });

  final double angle;
  final double distance;
  final double size;
}

class _PoopExplosionPainter extends CustomPainter {
  _PoopExplosionPainter({required this.progress});

  final double progress;

  static final List<_PoopParticle> _poops = List.generate(16, (i) {
    final rnd = Random(9000 + i);
    return _PoopParticle(
      angle: rnd.nextDouble() * pi * 2,
      distance: 90 + rnd.nextDouble() * 160,
      size: 18 + rnd.nextDouble() * 24,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final explosionT = Curves.easeOutBack.transform(min(progress / 0.75, 1.0));

    for (final p in _poops) {
      final offset = Offset(cos(p.angle), sin(p.angle)) * (p.distance * explosionT);
      final pos = center + offset;

      textPainter.text = TextSpan(
        text: '💩',
        style: TextStyle(
          fontSize: p.size,
        ),
      );
      textPainter.layout();

      final drawOffset = pos - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, drawOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _PoopExplosionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
