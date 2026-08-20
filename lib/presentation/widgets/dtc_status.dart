import 'package:flutter/widgets.dart';

import '../../data/obd/dtc/dtc_decoder.dart';
import '../../domain/entities/enums.dart';
import '../theme/colors.dart';

String dtcTipoLabel(DtcEventType tipo) => switch (tipo) {
      DtcEventType.ativo => 'Ativo',
      DtcEventType.pendente => 'Pendente',
      DtcEventType.permanente => 'Permanente',
    };

/// Cor do selo de status — só o ativo acende o MIL de verdade (nota dos
/// tokens de cor: "critical: DTC ativo ou parâmetro muito fora da faixa").
Color dtcTipoColor(DtcEventType tipo) => switch (tipo) {
      DtcEventType.ativo => PulsoColors.criticalInk,
      DtcEventType.pendente => PulsoColors.attentionInk,
      DtcEventType.permanente => PulsoColors.ink2,
    };

/// Palavra por extenso do sistema (§9) — "P0133" sozinho não diz nada a um
/// motorista leigo; "Powertrain" diz um pouco (nota do mockup).
String dtcSystemLabel(DtcSystem system) => switch (system) {
      DtcSystem.powertrain => 'POWERTRAIN',
      DtcSystem.chassis => 'CHASSIS',
      DtcSystem.body => 'BODY',
      DtcSystem.network => 'NETWORK',
    };
