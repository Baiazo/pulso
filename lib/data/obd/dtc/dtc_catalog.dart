import 'dtc_decoder.dart';

/// Descrições em português dos códigos genéricos SAE/ISO mais comuns
/// (faixas P0xxx e U0xxx — ver nota sobre B/C abaixo). Não é exaustivo:
/// cobre os códigos mais frequentes na prática de diagnóstico. Chave é o
/// texto completo do código (`"P0133"`).
///
/// Códigos de chassi (Cxxxx) e carroceria (Bxxxx) têm pouquíssimos códigos
/// realmente genéricos na prática — a esmagadora maioria é específica de
/// fabricante mesmo dentro da faixa "genérica" nominal — por isso não têm
/// entradas aqui; ver [describeDtc].
const Map<String, String> _genericDtcDescriptions = {
  // Mistura / sondas de combustível
  'P0100': 'Circuito do sensor de fluxo de massa de ar (MAF) — faixa ou desempenho',
  'P0101': 'Sensor de fluxo de massa de ar (MAF) — problema de faixa ou desempenho',
  'P0102': 'Sensor de fluxo de massa de ar (MAF) — sinal muito baixo',
  'P0103': 'Sensor de fluxo de massa de ar (MAF) — sinal muito alto',
  'P0106': 'Sensor de pressão absoluta do coletor (MAP) — faixa ou desempenho',
  'P0107': 'Sensor de pressão absoluta do coletor (MAP) — sinal muito baixo',
  'P0108': 'Sensor de pressão absoluta do coletor (MAP) — sinal muito alto',
  'P0110': 'Circuito do sensor de temperatura do ar admitido (IAT)',
  'P0113': 'Sensor de temperatura do ar admitido (IAT) — sinal muito alto',
  'P0115': 'Circuito do sensor de temperatura do arrefecimento (ECT)',
  'P0117': 'Sensor de temperatura do arrefecimento (ECT) — sinal muito baixo',
  'P0118': 'Sensor de temperatura do arrefecimento (ECT) — sinal muito alto',
  'P0120': 'Circuito do sensor de posição do acelerador (TPS)',
  'P0121': 'Sensor de posição do acelerador (TPS) — faixa ou desempenho',
  'P0125': 'Tempo insuficiente para malha fechada — controle de temperatura',
  'P0128': 'Termostato — temperatura abaixo da regulada',
  'P0130': 'Circuito da sonda lambda, banco 1 sensor 1',
  'P0131': 'Sonda lambda banco 1 sensor 1 — sinal baixo',
  'P0132': 'Sonda lambda banco 1 sensor 1 — sinal alto',
  'P0133': 'Sonda lambda banco 1 sensor 1 — resposta lenta',
  'P0134': 'Sonda lambda banco 1 sensor 1 — sem atividade detectada',
  'P0135': 'Sonda lambda banco 1 sensor 1 — aquecedor com mau funcionamento',
  'P0136': 'Circuito da sonda lambda, banco 1 sensor 2',
  'P0141': 'Sonda lambda banco 1 sensor 2 — aquecedor com mau funcionamento',
  'P0171': 'Sistema de mistura muito pobre, banco 1',
  'P0172': 'Sistema de mistura muito rica, banco 1',
  'P0174': 'Sistema de mistura muito pobre, banco 2',
  'P0175': 'Sistema de mistura muito rica, banco 2',

  // Ignição / falha de combustão
  'P0300': 'Falha de combustão detectada — cilindro aleatório/múltiplo',
  'P0301': 'Falha de combustão detectada — cilindro 1',
  'P0302': 'Falha de combustão detectada — cilindro 2',
  'P0303': 'Falha de combustão detectada — cilindro 3',
  'P0304': 'Falha de combustão detectada — cilindro 4',
  'P0305': 'Falha de combustão detectada — cilindro 5',
  'P0306': 'Falha de combustão detectada — cilindro 6',
  'P0325': 'Circuito do sensor de detonação (knock sensor), banco 1',
  'P0335': 'Circuito do sensor de posição da árvore de manivelas (CKP)',
  'P0340': 'Circuito do sensor de posição do comando de válvulas (CMP)',
  'P0350': 'Circuito primário/secundário da bobina de ignição',

  // Emissões
  'P0400': 'Fluxo do sistema de recirculação de gases (EGR)',
  'P0401': 'Fluxo insuficiente no sistema EGR',
  'P0402': 'Fluxo excessivo no sistema EGR',
  'P0410': 'Sistema de ar secundário',
  'P0420': 'Eficiência do catalisador abaixo do limiar, banco 1',
  'P0430': 'Eficiência do catalisador abaixo do limiar, banco 2',
  'P0440': 'Sistema de controle de emissões evaporativas (EVAP)',
  'P0442': 'Sistema EVAP — vazamento pequeno detectado',
  'P0446': 'Sistema EVAP — circuito de controle de ventilação',
  'P0455': 'Sistema EVAP — vazamento grande detectado',

  // Marcha lenta / velocidade / diversos do motor
  'P0500': 'Circuito do sensor de velocidade do veículo (VSS)',
  'P0505': 'Sistema de controle de marcha lenta',
  'P0506': 'Sistema de controle de marcha lenta — rotação abaixo do esperado',
  'P0507': 'Sistema de controle de marcha lenta — rotação acima do esperado',
  'P0560': 'Tensão do sistema fora da faixa',
  'P0562': 'Tensão do sistema baixa',
  'P0563': 'Tensão do sistema alta',
  'P0600': 'Circuito de comunicação serial (barramento interno da ECU)',
  'P0601': 'Erro de checksum na memória de controle interna',
  'P0603': 'Erro na memória não-volátil (KAM)',
  'P0606': 'Módulo de controle do motor — desempenho do processador',

  // Transmissão (comum o suficiente para valer a entrada genérica)
  'P0700': 'Sistema de controle da transmissão — código requisitado',
  'P0701': 'Sistema de controle da transmissão — faixa/desempenho',
  'P0715': 'Circuito do sensor de velocidade de entrada da transmissão',
  'P0720': 'Circuito do sensor de velocidade de saída da transmissão',

  // Rede de comunicação (barramento entre módulos)
  'U0100': 'Perda de comunicação com o módulo de controle do motor/powertrain',
  'U0101': 'Perda de comunicação com o módulo da transmissão',
  'U0121': 'Perda de comunicação com o módulo de controle de estabilidade (ABS)',
  'U0155': 'Perda de comunicação com o módulo do painel de instrumentos',
};

/// Nota fixada no código quando ele não tem descrição pública cadastrada —
/// nunca inventar descrição para código proprietário (§9).
const String manufacturerSpecificNote =
    'Código específico do fabricante — a interpretação depende da montadora.';

const String undocumentedGenericNote =
    'Código genérico sem descrição cadastrada neste catálogo.';

/// Descrição em português para exibição, seguindo a regra do §9: nunca
/// inventar descrição para código proprietário — a nota deixa isso
/// explícito para o usuário em vez de mostrar um texto vazio.
String describeDtc(DtcCode dtc) {
  if (dtc.isManufacturerSpecific) return manufacturerSpecificNote;
  return _genericDtcDescriptions[dtc.code] ?? undocumentedGenericNote;
}
