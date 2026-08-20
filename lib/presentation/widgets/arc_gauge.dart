import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/enums.dart';
import '../theme/colors.dart';
import 'severity_colors.dart';

/// Gauge de arco do sistema visual — 240°, trilho fixo em 9 dp, sem
/// agulha. Regra mais importante do componente (nota 01 do mockup): o
/// arco fica neutro no estado normal, nunca verde — se acende verde toda
/// partida, o olho aprende a ignorar cor, e o alerta perde força quando
/// precisa dela. A cor de estado só pinta o arco quando há desvio.
class ArcGauge extends StatelessWidget {
  const ArcGauge({
    super.key,
    required this.diameter,
    required this.value,
    required this.min,
    required this.max,
    this.mean,
    this.severity,
    this.strokeWidth = 9,
    this.child,
  });

  final double diameter;
  final double value;
  final double min;
  final double max;

  /// Média histórica aprendida (baseline) — vira o traço fino no arco.
  final double? mean;

  /// `null` = normal. A cor só aparece aqui quando há desvio.
  final AnomalySeverity? severity;
  final double strokeWidth;
  final Widget? child;

  double _fractionOf(double v) {
    if (max <= min) return 0;
    return ((v - min) / (max - min)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _ArcGaugePainter(
          fraction: _fractionOf(value),
          meanFraction: mean == null ? null : _fractionOf(mean!),
          color: severityColor(severity) ?? PulsoColors.ink,
          strokeWidth: strokeWidth,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  _ArcGaugePainter({
    required this.fraction,
    required this.meanFraction,
    required this.color,
    required this.strokeWidth,
  });

  final double fraction;
  final double? meanFraction;
  final Color color;
  final double strokeWidth;

  static const _startDeg = 150.0;
  static const _sweepDeg = 240.0;

  static double _deg2rad(double deg) => deg * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = PulsoColors.hairline
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _deg2rad(_startDeg), _deg2rad(_sweepDeg), false, trackPaint);

    if (fraction > 0) {
      final valuePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        _deg2rad(_startDeg),
        _deg2rad(_sweepDeg * fraction),
        false,
        valuePaint,
      );
    }

    final mf = meanFraction;
    if (mf != null) {
      final angle = _deg2rad(_startDeg + _sweepDeg * mf);
      final direction = Offset(math.cos(angle), math.sin(angle));
      final inner = radius - strokeWidth * 1.3;
      final outer = radius + strokeWidth * 0.5;
      final markPaint = Paint()
        ..color = PulsoColors.accent
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center + direction * inner, center + direction * outer, markPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.meanFraction != meanFraction ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
