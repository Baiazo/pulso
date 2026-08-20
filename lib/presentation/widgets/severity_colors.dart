import 'package:flutter/widgets.dart';

import '../../domain/entities/enums.dart';
import '../theme/colors.dart';

/// Cor de estado — reservado, nunca decorativo (nota do mockup). `null`
/// significa "normal": a cor normal só aparece no selo, nunca pinta arco
/// nem número.
Color? severityColor(AnomalySeverity? severity) => switch (severity) {
      null => null,
      AnomalySeverity.atencao => PulsoColors.attentionInk,
      AnomalySeverity.serio => PulsoColors.seriousInk,
      AnomalySeverity.critico => PulsoColors.criticalInk,
    };

String severityLabel(AnomalySeverity? severity) => switch (severity) {
      null => 'Normal',
      AnomalySeverity.atencao => 'Atenção',
      AnomalySeverity.serio => 'Sério',
      AnomalySeverity.critico => 'Crítico',
    };
