# Sistema Inteligente de Monitoramento Veicular via OBD-II

Especificação técnica de implementação.
Origem: TCC em Sistemas de Informação — IFSC Câmpus Caçador, 2026.
Autor: Matheus Gabryel Neves.

---

## Como usar este documento

Salve este arquivo na raiz do repositório e comece a sessão com:

> Leia o `PROJETO-OBD-II.md` inteiro antes de escrever qualquer código. Ele
> descreve a arquitetura completa do sistema, mas **só a Fase 1 deve ser
> implementada agora**. Comece pelo item 1 da ordem de implementação (§17) e vá
> commitando etapa por etapa. Antes de cada etapa, me diga o que vai fazer e
> espere confirmação.

As Fases 2 e 3 estão documentadas para que as decisões da Fase 1 não gerem
retrabalho depois. **Não as implemente sem que eu peça.**

---

## 1. O que o sistema é

Um aplicativo Android que se conecta por Bluetooth a um adaptador OBD-II
(ELM327), lê continuamente os parâmetros operacionais e os códigos de falha da
ECU do veículo, aprende o comportamento normal daquele carro específico, e avisa
o motorista quando algo se desvia desse padrão — idealmente antes que a ECU gere
um código de falha.

Veículo de referência: **Volvo V40 2019**, protocolo CAN ISO 15765-4.

O diferencial em relação a um scanner comum não é ler o dado, é **interpretá-lo
contra o histórico do próprio veículo**. Um scanner diz "temperatura 96°C". Este
sistema diz "96°C, sendo que esse carro normalmente roda a 88°C nessa condição de
uso". Internamente isso é um Z-score de 3,1; **na tela, o número estatístico não
aparece** — aparece a comparação em linguagem comum (RF23). O usuário-alvo do TCC
é o motorista sem conhecimento técnico.

### 1.1 Rastreabilidade com os objetivos do TCC

Cada objetivo específico do trabalho precisa ter uma contraparte verificável no
código. Isso é o que vai ser defendido na banca.

| Objetivo específico (texto do TCC) | Onde é atendido |
|---|---|
| Levantar na literatura os conceitos de OBD-II, ECU, DTCs e técnicas inteligentes | Fora do código — referencial teórico do TCC1 |
| Identificar os parâmetros disponíveis via OBD-II que contribuam para a análise **da eficiência automobilística** e para a detecção de falhas | Catálogo de PIDs (§8) + descoberta automática dos PIDs suportados (§7.5) + parâmetros derivados de eficiência (§12.6) |
| Definir os requisitos funcionais e não funcionais | §4 |
| Desenvolver solução capaz de receber, organizar e analisar dados obtidos via OBD-II | Fase 1 completa |
| Implementar mecanismos de interpretação para identificar comportamentos anômalos, **variações de eficiência** e possíveis falhas | Motor de análise (§12), incluindo baseline de consumo (§12.6) |
| Avaliar o sistema, verificando a capacidade de monitorar e **gerar informações úteis ao usuário** | Suíte de testes (§15) + modo de validação contra scanner (§14) + RF23 (linguagem leiga) |

**Atenção à palavra "eficiência":** ela está no título do trabalho e em dois
objetivos específicos. Não basta exibir o consumo — o consumo precisa ter perfil
normal, Z-score e detecção de tendência como qualquer outro parâmetro (§12.6).
Se isso ficar de fora, o título promete algo que o sistema não entrega.

---

## 2. Arquitetura completa

Cinco camadas. **Somente as camadas 1 a 3 entram na Fase 1.**

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. VEÍCULO                                                      │
│    ECU → barramento CAN → conector DLC (16 pinos)               │
│    Adaptador ELM327 traduz OBD-II ↔ serial sobre Bluetooth      │
└────────────────────────────┬────────────────────────────────────┘
                             │  Bluetooth (SPP clássico ou BLE)
┌────────────────────────────┴────────────────────────────────────┐
│ 2. APLICATIVO FLUTTER                            ◄── FASE 1     │
│    Transporte → Cliente ELM327 → Decodificadores                │
│    Agendador de amostragem → Repositórios                       │
│    Motor de análise (Welford, Z-score, EWMA)                    │
│    Apresentação (painel, gráficos, alertas)                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────┴────────────────────────────────────┐
│ 3. PERSISTÊNCIA LOCAL (SQLite via Drift)         ◄── FASE 1     │
│    Sessões · Leituras · Frames brutos · DTCs                    │
│    Baselines estatísticas · Anomalias                           │
└────────────────────────────┬────────────────────────────────────┘
                             ┊  HTTPS/JSON — contrato definido na Fase 1,
                             ┊  implementado na Fase 2
┌────────────────────────────┴────────────────────────────────────┐
│ 4. API LARAVEL                                   ◄── FASE 2     │
│    Sincronização, histórico multi-dispositivo, backup           │
└────────────────────────────┬────────────────────────────────────┘
                             ┊
┌────────────────────────────┴────────────────────────────────────┐
│ 5. SERVIÇO DE ANÁLISE PYTHON                     ◄── FASE 3     │
│    Modelos de ML sobre o histórico acumulado                    │
└─────────────────────────────────────────────────────────────────┘
```

### 2.1 Regras de preparação — obrigatórias na Fase 1

Estas quatro decisões custam quase nada agora e evitam reescrever tudo depois.
**Siga-as mesmo que a Fase 2 nunca aconteça** — elas também tornam o código mais
testável.

1. **Toda persistência atrás de interface.** `ReadingRepository`,
   `SessionRepository`, `DtcRepository` são abstratas. A implementação da Fase 1
   é `LocalReadingRepository` (Drift). A Fase 2 acrescenta uma implementação
   remota sem tocar em nada acima.

2. **Identificadores estáveis desde o início.** Toda linha de toda tabela tem uma
   coluna `uuid` (UUID v4, gerado no dispositivo) e uma coluna `synced_at`
   anulável. Sincronizar depois vira trivial; retrofitar isso num banco com dados
   reais coletados é doloroso.

3. **Motor de análise em Dart puro.** Nenhum `import 'package:flutter/...'` dentro
   de `domain/analysis/`. Ele precisa rodar em teste unitário sem framework, e o
   serviço Python da Fase 3 vai reimplementar o mesmo contrato — o que só é
   verificável se o contrato estiver isolado.

4. **DTOs JSON definidos já na Fase 1.** Cada entidade tem `toJson`/`fromJson` com
   nomes de campo em `snake_case`. Esse é o contrato da API Laravel, escrito antes
   de existir API. E é o formato de exportação para análise no TCC2.

---

## 3. Escopo da Fase 1

**Dentro:**

- Conexão Bluetooth com adaptador ELM327 (SPP clássico e BLE)
- Handshake, detecção de protocolo, descoberta dos PIDs suportados
- Leitura contínua dos PIDs do Modo 01 com agendamento por prioridade
- Leitura de DTCs (Modos 03, 07, 0A), freeze frame (Modo 02), VIN (Modo 09)
- Persistência local em SQLite
- Motor de análise: perfil normal contextual, Z-score, EWMA, detecção de tendência
- Painel ao vivo, histórico, gráficos, tela de diagnóstico, linha do tempo de anomalias
- **Simulador ELM327 embutido** — o app funciona por completo sem carro
- Exportação CSV/JSON dos dados coletados
- Suíte de testes automatizados

**Fora (não implemente):**

- Servidor, API, autenticação, contas de usuário
- Machine learning de qualquer tipo
- iOS (o Flutter compila, mas Bluetooth SPP clássico não funciona em iOS sem MFi;
  não gaste tempo nisso)
- Qualquer comando de **escrita** na ECU além do Modo 04 (§16)

---

## 4. Requisitos

### 4.1 Funcionais

| ID | Requisito |
|---|---|
| RF01 | Descobrir e parear adaptadores OBD-II Bluetooth próximos |
| RF02 | Estabelecer sessão ELM327 e detectar automaticamente o protocolo do veículo |
| RF03 | Identificar quais PIDs o veículo suporta, consultando os bitmaps 0100/0120/0140/0160 |
| RF04 | Ler continuamente os parâmetros operacionais suportados, com taxa configurável |
| RF05 | Decodificar cada PID conforme a norma SAE J1979 e converter às unidades de engenharia |
| RF06 | Ler DTCs ativos, pendentes e permanentes, decodificando-os conforme a SAE J2012 |
| RF07 | Ler o freeze frame associado a um DTC |
| RF08 | Ler o VIN e associar as sessões ao veículo identificado |
| RF09 | Persistir localmente todas as leituras, organizadas em sessões de coleta |
| RF10 | Construir incrementalmente o perfil de funcionamento normal por parâmetro e por contexto operacional |
| RF11 | Classificar cada leitura em um contexto operacional |
| RF12 | Detectar valores atípicos por Z-score, com limiar configurável (padrão 3,0) |
| RF13 | Detectar tendências progressivas de desvio por média móvel exponencial |
| RF14 | Registrar cada anomalia com o dado que a motivou, para auditoria |
| RF15 | Exibir os parâmetros em tempo real num painel gráfico |
| RF16 | Exibir séries temporais históricas por parâmetro, com a faixa normal sobreposta |
| RF17 | Listar sessões de coleta com métricas agregadas |
| RF18 | Estimar consumo instantâneo e médio a partir do MAF ou do MAP |
| RF19 | Apagar DTCs (Modo 04), mediante confirmação explícita do usuário |
| RF20 | Exportar os dados coletados em CSV e JSON |
| RF21 | Operar integralmente em modo simulado, sem hardware |
| RF22 | Exibir o quadro bruto de comunicação, para validação contra scanner comercial |
| RF23 | Apresentar todo alerta em linguagem leiga, sem exigir conhecimento técnico: o que foi observado, o que é esperado e o que fazer. O valor de Z-score fica disponível num detalhe secundário, nunca no texto principal |
| RF24 | Monitorar a eficiência (consumo) como parâmetro analisado, com perfil normal e detecção de desvio, e não apenas exibido |

### 4.2 Não funcionais

| ID | Requisito |
|---|---|
| RNF01 | Android 8.0 (API 26) ou superior |
| RNF02 | A interface não pode travar durante a comunicação serial — toda I/O é assíncrona |
| RNF03 | Taxa de atualização dos parâmetros de alta prioridade ≥ 2 Hz. **Meça antes de fixar:** um ELM327 sustenta 5–15 consultas/s no total (§10); com 4 PIDs de alta prioridade, o limite inferior dessa faixa não atinge 2 Hz. Se o adaptador adquirido ficar abaixo, ajuste o requisito para o valor medido e registre a medição no TCC |
| RNF04 | Perda de conexão deve ser detectada em até 3 s e tratada sem encerrar a sessão de dados |
| RNF05 | O app não pode enviar comandos de escrita à ECU, exceto o Modo 04 explicitamente confirmado |
| RNF06 | Uma sessão de 1 h a 2 Hz não deve ocupar mais que ~50 MB |
| RNF07 | Cobertura de testes ≥ 80% nas camadas de decodificação e análise |
| RNF08 | Nenhum dado sai do dispositivo na Fase 1 |
| RNF09 | Alvos de toque ≥ 48 dp; contraste conforme WCAG AA |
| RNF10 | O app precisa continuar coletando com a tela apagada (serviço em primeiro plano) |

---

## 5. Stack

- **Flutter** (canal stable) / **Dart 3**
- **Estado:** `flutter_riverpod`
- **Banco:** `drift` + `sqlite3_flutter_libs` — escolhido por ser tipado e por
  expor `Stream` reativo, o que serve diretamente ao painel ao vivo
- **Gráficos:** `fl_chart`
- **Bluetooth BLE:** `flutter_blue_plus`
- **Bluetooth clássico (SPP):** `flutter_bluetooth_serial` ou fork mantido.
  A maioria dos clones ELM327 baratos é Bluetooth 2.0 SPP, não BLE — os dois
  transportes são necessários. Esse pacote tem histórico de manutenção
  irregular; por isso ele fica **atrás da interface `ObdTransport`** e pode ser
  trocado sem afetar o resto do código.
- **Permissões:** `permission_handler`
- **Serviço em primeiro plano:** `flutter_foreground_task`
- **Modelos:** `freezed` + `json_serializable` + `build_runner`
- **Exportação:** `csv`, `share_plus`, `path_provider`
- **Testes:** `flutter_test`, `mocktail`

---

## 6. Estrutura de pastas

```
lib/
  main.dart
  app.dart                        # tema, rotas, ProviderScope
  core/
    result.dart                   # Result<T, ObdError> — sem exceções na camada OBD
    errors.dart
    constants.dart
  data/
    obd/
      transport/
        obd_transport.dart        # interface: connect, write, stream<String>, dispose
        classic_spp_transport.dart
        ble_transport.dart
        mock_transport.dart       # simulador — §13
      elm327/
        elm327_client.dart        # handshake, fila serial, timeout, retry
        elm327_commands.dart      # constantes AT
        response_parser.dart      # limpeza, multi-linha ISO-TP, detecção de erro
      pids/
        pid_definition.dart
        pid_catalog.dart          # §8
        pid_decoder.dart
        supported_pids.dart       # decodificação dos bitmaps
      dtc/
        dtc_decoder.dart          # §9
        dtc_catalog.dart          # descrições genéricas em português
      sampling/
        sampling_scheduler.dart   # round-robin por prioridade — §10
    db/
      database.dart               # Drift
      tables/
      daos/
    repositories/
      reading_repository.dart     # interface + impl local
      session_repository.dart
      dtc_repository.dart
      baseline_repository.dart
  domain/
    entities/
    analysis/                     # DART PURO — sem imports de Flutter
      welford.dart
      context_classifier.dart
      zscore_detector.dart
      ewma_trend_detector.dart
      fuel_estimator.dart
      analysis_engine.dart
  presentation/
    connection/
    dashboard/
    live_detail/
    diagnostics/
    anomalies/
    trips/
    vehicle/
    settings/
    widgets/                      # gauge de arco, stat tile, sparkline, chips
test/
  pids/                           # vetores golden
  dtc/
  analysis/
  elm327/
  integration/
```

---

## 7. Protocolo ELM327

### 7.1 Handshake

O adaptador é um dispositivo serial burro que fala texto ASCII. Envie cada
comando terminado em `\r` e aguarde o caractere de prompt `>`.

```
ATZ      → reset por software. Aguarde ~1000 ms. Responde "ELM327 v1.5" ou similar.
ATE0     → desliga o eco. Sem isso, cada resposta vem precedida do comando.
ATL0     → desliga linefeeds
ATS0     → remove espaços das respostas (parsing fica muito mais simples)
ATH0     → cabeçalhos desligados (ligue com ATH1 apenas no modo de validação)
ATSP6    → força CAN 11 bits / 500 kbps (ISO 15765-4) — o do Volvo V40 2019
0100     → primeira consulta real; confirma que a ECU respondeu
ATDP     → confirma qual protocolo foi negociado
ATAT1    → temporização adaptativa (melhora a taxa de amostragem)
```

Se `0100` retornar `UNABLE TO CONNECT`, `SEARCHING...` sem sucesso, ou `NO DATA`,
faça fallback para `ATSP0` (detecção automática) e repita. Registre em log qual
protocolo foi efetivamente negociado — isso vai para o TCC.

Números de protocolo do `ATSP`: `0` auto · `1` J1850 PWM · `2` J1850 VPW ·
`3` ISO 9141-2 · `4` KWP2000 init lento · `5` KWP2000 init rápido ·
`6` CAN 11 bits 500 k · `7` CAN 29 bits 500 k · `8` CAN 11 bits 250 k ·
`9` CAN 29 bits 250 k.

### 7.2 A regra mais importante desta camada

**O ELM327 é half-duplex e estritamente serial.** Um comando por vez. Se dois
comandos forem enviados concorrentemente, as respostas se misturam e o parser
produz lixo silencioso — valores errados, não erros. Esse é o defeito número um
de aplicativos OBD amadores, e ele é difícil de detectar porque o app *parece*
funcionar.

Implemente `Elm327Client` com **uma única fila serial**: um worker consome
requisições uma a uma, cada uma com timeout próprio (padrão 1000 ms, 4000 ms para
os Modos 03/09), e nada mais escreve no transporte. A API pública devolve
`Future<Result<...>>` e o enfileiramento é interno. Não exponha `write` cru para
o resto do app.

### 7.3 Formato de resposta

Com `ATE0` e `ATS0` ativos, a consulta `010C` retorna:

```
410C1AF8\r\r>
```

`41` = `40 + modo`, confirmando resposta do Modo 01. `0C` ecoa o PID. `1AF8` são
os bytes de dado — aqui, A=0x1A, B=0xF8.

Respostas longas (VIN, muitos DTCs) são multi-frame ISO-TP. O ELM327 reagrupa e
imprime com numeração de linha:

```
014
0:490201314434
1:47503030523535
2:42313233343536
```

A primeira linha é o comprimento total em hexadecimal (`0x14` = 20 bytes); as
seguintes têm o índice seguido de `:`. Descontando `49 02 01` (modo, PID e contador),
sobram os 17 bytes ASCII do VIN. O parser precisa reconhecer e concatenar esse
formato — e o teste golden precisa verificar que o VIN resultante tem exatamente
17 caracteres.

### 7.4 Respostas de erro a tratar explicitamente

`NO DATA` · `?` (comando não entendido) · `UNABLE TO CONNECT` · `BUS INIT: ERROR`
· `BUS BUSY` · `CAN ERROR` · `DATA ERROR` · `STOPPED` · `BUFFER FULL` ·
`SEARCHING...` (transitório, aguarde) · `ERROR`.

`NO DATA` é o mais comum e **não é falha** — significa que o veículo não suporta
aquele PID, *ou* que o motor está desligado, *ou* que aquele sensor ainda não tem
leitura válida. Trate como ausência de dado, não como erro.

Cuidado com a regra de desativação: se o app desativar todo PID que devolver
`NO DATA` três vezes, uma conexão feita com a ignição ligada e o motor parado
desativa quase todo o catálogo, e ele não volta. A regra correta é:

- Suspenda o PID **apenas na sessão atual**, nunca no perfil do veículo
- Re-sonde os PIDs suspensos a cada 60 s
- Re-sonde **imediatamente** quando o RPM passar de 0, que é o sinal de que o
  motor entrou em funcionamento
- A lista de PIDs suportados vem dos bitmaps (§7.5), não da observação de `NO DATA`

### 7.5 Descoberta dos PIDs suportados

Consulte `0100`, depois `0120`, `0140`, `0160`. Cada resposta traz 4 bytes = 32
bits. O bit mais significativo do primeiro byte indica suporte ao PID seguinte ao
consultado; o menos significativo do quarto byte indica o PID + 0x20. Se esse
último bit estiver ligado, consulte o próximo bloco.

Exemplo: resposta `4100BE1FA813` → bytes `BE 1F A8 13`. `B` = `1011` → PIDs 01, 03
e 04 suportados; PID 02 não.

Armazene o conjunto suportado no perfil do veículo e **só agende PIDs suportados**.

---

## 8. Catálogo de PIDs (Modo 01, SAE J1979)

`A`, `B`, `C`, `D` são os bytes de dado, em ordem, já convertidos de hexadecimal
para inteiro sem sinal.

| PID | Parâmetro | Bytes | Fórmula | Unidade | Faixa |
|---|---|---|---|---|---|
| `04` | Carga calculada do motor | 1 | `A × 100 / 255` | % | 0–100 |
| `05` | Temperatura do arrefecimento (ECT) | 1 | `A − 40` | °C | −40–215 |
| `06` | Correção de curto prazo, banco 1 | 1 | `(A − 128) × 100 / 128` | % | −100–99,2 |
| `07` | Correção de longo prazo, banco 1 | 1 | `(A − 128) × 100 / 128` | % | −100–99,2 |
| `0A` | Pressão do combustível | 1 | `A × 3` | kPa | 0–765 |
| `0B` | Pressão absoluta do coletor (MAP) | 1 | `A` | kPa | 0–255 |
| `0C` | Rotação do motor | 2 | `(256A + B) / 4` | rpm | 0–16383,75 |
| `0D` | Velocidade do veículo | 1 | `A` | km/h | 0–255 |
| `0E` | Avanço de ignição | 1 | `A / 2 − 64` | ° | −64–63,5 |
| `0F` | Temperatura do ar admitido (IAT) | 1 | `A − 40` | °C | −40–215 |
| `10` | Fluxo de massa de ar (MAF) | 2 | `(256A + B) / 100` | g/s | 0–655,35 |
| `11` | Posição do acelerador (TPS) | 1 | `A × 100 / 255` | % | 0–100 |
| `1F` | Tempo desde a partida | 2 | `256A + B` | s | 0–65535 |
| `21` | Distância com MIL ligada | 2 | `256A + B` | km | 0–65535 |
| `2F` | Nível do tanque | 1 | `A × 100 / 255` | % | 0–100 |
| `33` | Pressão barométrica absoluta | 1 | `A` | kPa | 0–255 |
| `3C` | Temperatura do catalisador B1S1 | 2 | `(256A + B) / 10 − 40` | °C | −40–6513,5 |
| `42` | Tensão do módulo de controle | 2 | `(256A + B) / 1000` | V | 0–65,535 |
| `43` | Valor absoluto de carga | 2 | `(256A + B) × 100 / 255` | % | 0–25700 |
| `44` | Razão lambda comandada | 2 | `(256A + B) / 32768` | — | 0–2 |
| `46` | Temperatura do ar ambiente | 1 | `A − 40` | °C | −40–215 |
| `5C` | Temperatura do óleo do motor | 1 | `A − 40` | °C | −40–210 |
| `5E` | Taxa de consumo de combustível | 2 | `(256A + B) / 20` | L/h | 0–3276,75 |

**O PID `01` fica fora desta tabela** porque não é um valor escalar: ele devolve o
estado da luz de injeção (bit 7 de A) e a contagem de DTCs (`A & 0x7F`) num mesmo
quadro, além do estado dos monitores de emissão. Trate-o num decodificador
próprio, `MonitorStatusDecoder`, com retorno estruturado — não force isso no
catálogo numérico.

Modele o restante como uma lista de `PidDefinition` — nunca com `switch` espalhado
pelo código:

```dart
enum SamplingPriority { alta, media, baixa, sobDemanda }

class PidDefinition {
  final int mode;            // 0x01
  final int pid;             // 0x0C
  final String key;          // 'engine_rpm'
  final String label;        // 'Rotação do motor'
  final String unit;         // 'rpm'
  final int byteCount;
  final double Function(List<int> bytes) decode;
  final double min;
  final double max;
  final SamplingPriority priority;   // fonte única do agendamento — §10
}
```

Toda leitura decodificada é validada contra `min`/`max` antes de ser persistida.
Valor fora da faixa física é descartado como erro de comunicação — se ele entrar
na baseline, contamina a média e o desvio padrão de forma permanente.

---

## 9. Decodificação de DTCs (SAE J2012)

Cada DTC ocupa 2 bytes.

```
byte A:  b7 b6 | b5 b4 | b3 b2 b1 b0
         sistema  díg.1    dígito 2
byte B:  b7 b6 b5 b4 | b3 b2 b1 b0
           dígito 3      dígito 4
```

- `A >> 6` → sistema: `0`=P (powertrain), `1`=C (chassis), `2`=B (body), `3`=U (network)
- `(A >> 4) & 0x03` → primeiro dígito (0–3). `0` = código genérico SAE/ISO;
  `1` = específico do fabricante.
- `A & 0x0F` → segundo dígito
- `B >> 4` → terceiro dígito
- `B & 0x0F` → quarto dígito

Os três últimos dígitos são impressos em hexadecimal maiúsculo.

**Exemplo:** bytes `01 33` → `A>>6 = 0` → `P`; `(A>>4)&3 = 0`; `A&0x0F = 1`;
`B>>4 = 3`; `B&0x0F = 3` → **`P0133`**.

Escreva o teste com estes vetores: `0133 → P0133`, `0420 → P0420`, `4171 → C0171`,
`8100 → B0100`, `C123 → U0123`, `0171 → P0171`.

**Modos:** `03` = armazenados/ativos · `07` = pendentes · `0A` = permanentes ·
`04` = apagar.

**Atenção no parsing do Modo 03:** em CAN (ISO 15765-4) a resposta `43` vem
seguida de um byte com a quantidade de DTCs; em protocolos legados, não vem —
cada frame carrega até 3 códigos. Trate as duas formas e **descarte os pares
`0000`**, que são preenchimento.

Mantenha um `dtc_catalog.dart` com as descrições em português dos códigos
genéricos (faixas P0xxx, P2xxx, P3xxx, U0xxx). Códigos específicos de fabricante
(`P1xxx`) não têm descrição pública — exiba o código com a nota de que a
interpretação depende da montadora. Não invente descrição para código
proprietário.

---

## 10. Agendamento da amostragem

Um ELM327 clássico sustenta algo entre 5 e 15 consultas por segundo no total.
Consultar 10 PIDs em rodízio simples derruba cada um para ~1 Hz, o que é lento
demais para RPM e rápido demais para nível de combustível. Use rodízio por
prioridade.

**O agendador não tem lista fixa de PIDs.** Ele lê o campo
`PidDefinition.priority` do catálogo (§8), intersecta com o conjunto de PIDs
suportados descoberto no handshake (§7.5), e monta o rodízio. Assim, incluir um
parâmetro novo é acrescentar uma linha no catálogo, e nunca acontece de um PID
existir no catálogo e ser esquecido no agendamento.

| Prioridade | Frequência | Atribuição no catálogo |
|---|---|---|
| `alta` | todo ciclo | rotação · velocidade · acelerador · carga do motor |
| `media` | 1 a cada 5 ciclos | ECT · MAF · MAP · IAT · taxa de consumo (PID `5E`) |
| `baixa` | 1 a cada 30 ciclos | tensão · nível do tanque · correções de mistura · temperatura do óleo · pressão barométrica · temperatura do catalisador · lambda · avanço de ignição |
| `sobDemanda` | ação do usuário ou início/fim de sessão | Modos `03`, `07`, `0A`, `02`, `0902`; PIDs `01`, `1F`, `21` |

Nota de notação: `03`, `07`, `0A` e `02` na última linha são **modos de serviço**,
não PIDs. Não confunda com os PIDs `06`/`07` (correções de mistura) e `0A`
(pressão do combustível) do Modo 01 — o par `(modo, pid)` do `PidDefinition`
existe justamente para essa distinção não virar bug.

Meça e exiba a taxa efetiva por PID na tela de ajustes. É um dado do TCC: se a
banca perguntar qual a frequência real de amostragem, a resposta precisa ser
medida, não estimada.

---

## 11. Persistência

Tabelas Drift. Toda tabela tem `id` (inteiro autoincremento), `uuid` (texto) e
`synced_at` (data anulável), conforme §2.1.

**`vehicles`** — `vin`, `apelido`, `modelo`, `ano`, `cilindrada_l`,
`tipo_combustivel` (enum: gasolina_comum · gasolina_aditivada · etanol · flex),
`pids_suportados` (JSON)

**`sessions`** — `vehicle_id`, `iniciada_em`, `encerrada_em`, `protocolo`,
`adaptador`, `origem` (real · simulado), `distancia_km`, `duracao_s`,
`consumo_medio_kml`

**`readings`** — `session_id`, `ts`, `pid_key`, `valor`, `contexto`.
Índice composto em `(session_id, pid_key, ts)`. É a tabela que cresce; a consulta
do gráfico depende desse índice.

**`raw_frames`** — `session_id`, `ts`, `comando`, `resposta_bruta`.
Gravada apenas com o modo de validação ligado. Serve à seção 5.7 do TCC — é a
evidência bruta para comparar contra o scanner comercial.

**`dtc_events`** — `session_id`, `ts`, `codigo`, `tipo` (ativo · pendente ·
permanente), `descricao`, `freeze_frame` (JSON)

**`baselines`** — `vehicle_id`, `pid_key`, `contexto`, `n`, `media`, `m2`,
`atualizado_em`. Guarda o estado do algoritmo de Welford, não a lista de amostras.

**`anomalies`** — `session_id`, `ts`, `pid_key`, `contexto`, `valor`,
`media_esperada`, `desvio_padrao`, `z`, `severidade`, `tipo` (pontual · tendencia)

Guardar `media_esperada` e `desvio_padrao` **no momento do alerta** é
intencional: a baseline muda ao longo do tempo, e sem isso é impossível auditar
depois por que um alerta foi disparado.

---

## 12. Motor de análise

Esta é a seção 5.5 do TCC transformada em código, com uma correção importante em
relação ao que está escrito no texto.

### 12.1 O problema de uma baseline global

O TCC descreve calcular média e desvio padrão de cada parâmetro. Implementado de
forma ingênua — uma média global por parâmetro — **isso não funciona**, e vale
entender por quê antes de escrever a primeira linha:

O RPM de um carro parado no semáforo fica perto de 750. Em rodovia, perto de
2500. Uma média global dá algo como 1400 com desvio padrão altíssimo. Resultado:
o Z-score nunca passa de 3 (nada é detectado), *ou* todo trecho de rodovia é
marcado como anomalia. A distribuição é multimodal, e a estatística de uma
distribuição multimodal não descreve nenhum dos modos.

### 12.2 A correção: baseline por contexto operacional

Classifique cada leitura em um contexto e mantenha uma baseline separada por
`(parâmetro, contexto)`:

| Contexto | Condição |
|---|---|
| `parado_frio` | velocidade = 0 **e** ECT < 70 °C |
| `parado_quente` | velocidade = 0 **e** ECT ≥ 70 °C |
| `urbano` | 0 < velocidade ≤ 60 km/h |
| `rodovia` | velocidade > 60 km/h |

Dentro de cada contexto a distribuição é aproximadamente unimodal, e aí sim média
e desvio padrão descrevem o comportamento. Isso é uma decisão defensável na banca
e é o tipo de detalhe que separa um TCC que funciona de um que só compila.

> **Pendência no texto do TCC, não no código.** A seção 5.5 do TCC1 descreve a
> baseline sem a segmentação por contexto. Reescreva essa seção no TCC2 para
> refletir o que foi implementado, apresentando a mudança como um refinamento
> metodológico com a justificativa acima. Se o texto e o código divergirem na
> defesa, a banca vai perguntar — e a resposta boa é ter previsto isso.

### 12.3 Welford — média e variância incrementais

Não recarregue o histórico inteiro a cada leitura. Use o algoritmo de Welford,
que atualiza em O(1) e é numericamente estável:

```dart
void update(double x) {
  n += 1;
  final delta = x - mean;
  mean += delta / n;
  m2 += delta * (x - mean);   // note: usa a média JÁ atualizada
}

double get variance => n < 2 ? 0 : m2 / (n - 1);
double get stdDev => sqrt(variance);
```

Persista `n`, `mean` e `m2` na tabela `baselines`.

### 12.4 Detecção de anomalia pontual

`z = (x − μ) / σ`, sinalizando `|z| > 3,0` (limiar configurável).

Três guardas, todas necessárias para o app não virar uma máquina de falso positivo:

1. **Amostras mínimas:** não avalie enquanto `n < 100` naquele contexto. Com poucas
   amostras, σ é uma estimativa ruim. Exiba "perfil em construção" na interface.
2. **Piso de desvio padrão:** se `σ` for menor que um piso por parâmetro, use o
   piso. Sem isso, um parâmetro quase constante (tensão da bateria com o motor
   parado) gera σ ≈ 0, e qualquer flutuação de leitura vira Z-score infinito.
   Pisos sugeridos: RPM 25 · velocidade 1,0 · ECT 0,8 · TPS 1,0 · carga 1,5 ·
   tensão 0,15 · MAF 0,5.
3. **Debounce:** só alerte após 5 amostras com `|z| > 3` dentro de uma janela de
   10. Um único pico é ruído de comunicação, não anomalia mecânica.

Severidade: `3 ≤ |z| < 4` → atenção · `4 ≤ |z| < 6` → sério · `|z| ≥ 6` → crítico.

### 12.5 Detecção de tendência

Anomalia pontual pega o evento; tendência pega a degradação lenta — que é o
objetivo real declarado no TCC ("antes que se tornem críticas").

Mantenha uma média móvel exponencial por `(parâmetro, contexto)` com α = 0,05.
Ao fim de cada sessão, compare a EWMA da sessão contra a média da baseline. Se
`|EWMA − μ| > 1,5σ` de forma sustentada por 3 sessões consecutivas, registre uma
anomalia do tipo `tendencia`.

Exemplo do que isso captura: um sensor de oxigênio degradando desloca lentamente
a correção de longo prazo (PID `07`) ao longo de semanas. Nenhuma leitura
individual é atípica; a média deslocou. É exatamente o caso que o TCC cita no
referencial teórico.

**Não alimente a baseline com leituras já marcadas como anômalas** — senão o
perfil "normal" absorve o defeito e o alerta desaparece sozinho.

### 12.6 Estimativa de consumo

Preferencialmente a partir do MAF (PID `10`):

```
L/h = MAF(g/s) × 3600 / (AFR_estequiométrica × densidade_g_por_L)
km/L = velocidade(km/h) / L/h      (indefinido com o veículo parado)
```

Constantes por combustível — **atenção ao caso brasileiro**, em que a gasolina
comum já vem com cerca de 27% de etanol anidro, o que muda a relação
estequiométrica e invalida a constante de 14,7 usada na literatura internacional:

| Combustível | AFR | Densidade | Fator (L/h por g/s) |
|---|---|---|---|
| Gasolina comum brasileira (E27) | 13,2 | 750 g/L | 0,364 |
| Gasolina pura (E0, referência) | 14,7 | 745 g/L | 0,329 |
| Etanol hidratado (E100) | 8,4 | 809 g/L | 0,530 |

Cuidado com a constante do etanol: **8,9 é o valor do etanol anidro**, e é o que
aparece na maior parte da literatura. O E100 vendido no Brasil é hidratado
(~6,5% de água em massa), e a água não consome ar — a relação estequiométrica cai
para cerca de 8,4. Usar 8,9 subestima o consumo em torno de 6%.

Se o veículo expuser o PID `5E` (taxa de consumo), use-o e ignore o cálculo.

Se não houver MAF nem `5E`, derive por densidade-velocidade a partir do MAP:

```
MAF(g/s) = (RPM / 120) × Vd(L) × VE × MAP(kPa) × 28,97 / (8,314 × IAT(K))
```

com `Vd` = cilindrada configurada no perfil do veículo e `VE` (eficiência
volumétrica) ≈ 0,85. Marque esse valor na interface como **estimado**, porque a
`VE` é uma suposição, não uma medida.

### 12.7 Eficiência como parâmetro analisado (RF24)

O consumo não pode ser apenas exibido. "Eficiência automobilística" está no título
do trabalho e em dois objetivos específicos — e o que o TCC promete é *monitorar*
a eficiência, não *mostrar* a eficiência.

Trate `consumo_kml` e `consumo_lh` como parâmetros derivados de primeira classe:
eles entram na tabela `readings` com `pid_key` próprio, recebem baseline por
contexto operacional, Z-score e EWMA, exatamente como um parâmetro lido do
veículo. Restrições próprias:

- `consumo_kml` só é calculado com velocidade > 0; nos contextos `parado_*` use
  apenas `consumo_lh`
- A baseline de consumo é a que mais depende do contexto — a diferença entre
  urbano e rodovia é enorme, e sem a separação de §12.2 o parâmetro é inútil
- A detecção de **tendência** (§12.5) é a que importa aqui: queda gradual de km/L
  ao longo de semanas, com o mesmo padrão de uso, é o sinal clássico de perda de
  eficiência — filtro de ar sujo, sonda lambda degradando, pressão de pneu.
  Anomalia pontual de consumo quase sempre é só o motorista pisando fundo.

---

## 13. Simulador ELM327

Uma implementação de `ObdTransport` que responde a comandos AT e a consultas OBD
com dados sinteticamente plausíveis. Não é um enfeite de desenvolvimento: é o que
torna possível programar sem o carro ligado, escrever testes de integração
determinísticos, e gravar a demonstração da defesa sem depender do trânsito.

**Requisitos:**

- Responde ao handshake completo, incluindo `ATZ` → `ELM327 v1.5`
- Aplica latência realista (30–80 ms por consulta) — sem isso o app fica
  otimista demais e problemas de temporização só aparecem no carro
- Simula um ciclo de condução coerente: partida a frio → ECT sobe gradualmente
  até ~90 °C e estabiliza · marcha lenta ~780 rpm · acelerações com RPM e TPS
  correlacionados · velocidade integrada de forma fisicamente consistente
- Perfis selecionáveis: `normal` · `urbano` · `rodovia` · `superaquecimento` ·
  `falha_sensor_o2` · `bateria_fraca` · `dtc_ativo`
- Injeta DTCs sob comando, com freeze frame coerente
- Simula falhas de comunicação: `NO DATA` ocasional, timeout, desconexão

Os perfis de falha são o que permite **testar a detecção de anomalia sem
danificar um carro real** — o único caminho viável para validar boa parte do RF12
e do RF13.

> **Pendência no texto do TCC.** O simulador não aparece nas seis etapas da seção
> 5.2, nem na Figura 1, nem no Quadro 2 — mas ele sustenta a validação dos RF12 e
> RF13 e é o item 4 da ordem de implementação. Acrescente "desenvolvimento do
> simulador OBD-II" como etapa em 5.2 e como linha do cronograma (jul–ago). É
> pouco texto e evita a pergunta "de onde saiu isso?" na banca.

---

## 14. Plataforma Android

**Permissões no manifesto:**

```xml
<!-- API ≤ 30 -->
<uses-permission android:name="android.permission.BLUETOOTH"
                 android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"
                 android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"
                 android:maxSdkVersion="30" />
<!-- API ≥ 31 -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"
                 android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<!-- coleta com a tela apagada -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_CONNECTED_DEVICE" />
<!-- API ≥ 33: sem isto a notificação do serviço não aparece e o RNF10 falha -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

O serviço em primeiro plano precisa declarar o tipo, obrigatório a partir da API 34:

```xml
<service
    android:name=".CollectionService"
    android:foregroundServiceType="connectedDevice"
    android:exported="false" />
```

Trate a negação de permissão com uma tela explicativa, não com um travamento
silencioso — em API ≥ 31, `BLUETOOTH_SCAN` negado faz o scan retornar lista vazia
sem erro, o que parece um bug de "adaptador não encontrado".

**Modo de validação (RF22):** um interruptor nos ajustes que liga `ATH1`, grava
todo tráfego em `raw_frames` e exibe uma tela com comando, resposta bruta em
hexadecimal e valor decodificado lado a lado. É a evidência para a seção 5.7 do
TCC — a comparação contra o scanner comercial.

**Exportação (RF20):** CSV por sessão, uma linha por leitura
(`ts, pid_key, valor, unidade, contexto`), mais um JSON com os metadados da
sessão, as baselines e as anomalias. Esse arquivo é o dado bruto que vai para os
gráficos e a análise do TCC2 — e o conjunto de treino da Fase 3, se ela existir.

---

## 15. Testes

| Camada | O que testar |
|---|---|
| Decodificadores de PID | Vetores golden: entrada hexadecimal → valor esperado, para todos os PIDs do §8. Inclua os extremos de faixa. |
| Decodificador de DTC | Os seis vetores do §9, mais o caso de preenchimento `0000` e o de resposta CAN com byte de contagem. |
| Parser de resposta | Multi-linha ISO-TP, cada string de erro do §7.4, respostas truncadas, lixo. |
| Welford | Contra valores conhecidos calculados à parte. Verifique estabilidade com 100 mil amostras de média alta e variância baixa — é onde o cálculo ingênuo quebra. |
| Classificador de contexto | Fronteiras: velocidade exatamente 0 e 60, ECT exatamente 70. |
| Z-score | As três guardas do §12.4, cada uma isolada. |
| Estimador de consumo | Os três combustíveis; velocidade zero; ausência de MAF. |
| Fila do ELM327 | Que 50 requisições concorrentes saem uma a uma, em ordem, sem interleaving. **Este é o teste mais importante da suíte** (§7.2). |
| Integração | Sessão completa contra o `MockTransport`: conectar, coletar 10 min simulados, persistir, analisar, verificar que o perfil `superaquecimento` gera anomalia e o `normal` não. |

`flutter analyze` sem avisos e `flutter test` verde antes de cada commit.

---

## 16. Segurança e limites

- **Nenhum comando de escrita na ECU.** Nada de Modo 08, nada de comandos
  proprietários, nada de `ATSH` para forjar cabeçalho e conversar com módulos
  fora do escopo de diagnóstico. O OBD-II é uma porta de leitura neste projeto.
- **Modo 04 (apagar DTC) atrás de dupla confirmação**, com aviso explícito de que
  apagar códigos remove evidência de diagnóstico e reinicia os monitores de
  emissão do veículo — o que pode reprovar o carro numa inspeção pelos próximos
  ciclos de condução.
- **Aviso de uso ao dirigir** no primeiro uso, e um modo direção que não exige
  interação (§ prompt de design).
- Nenhum dado sai do dispositivo na Fase 1 (RNF08).
- Não persista o VIN em log nem em exportação compartilhável sem que o usuário
  escolha — VIN identifica o veículo e, indiretamente, o proprietário.

---

## 17. Ordem de implementação

Um commit por item. Não pule para a interface antes do item 8 estar verde — a
tentação de ver algo na tela é forte, e é assim que se constrói um app bonito
sobre uma camada de dados errada.

1. Scaffold do projeto, `analysis_options.yaml` estrito, CI rodando `analyze` + `test`
2. `PidDefinition` + catálogo completo (§8) + decodificadores + **testes golden**
3. `DtcDecoder` + catálogo de descrições + **testes com os seis vetores**
4. Interface `ObdTransport` + `MockTransport` com o simulador (§13)
5. `Elm327Client`: handshake, **fila serial**, timeouts, tratamento de erro — sobre o mock
6. Descoberta de PIDs suportados
7. Esquema Drift + DAOs + repositórios atrás de interface
8. `SamplingScheduler` + gravação de sessão ponta a ponta contra o mock
9. **Transporte Bluetooth real** — SPP clássico e BLE — e primeira coleta no veículo
10. Motor de análise: Welford, contextos, Z-score, EWMA + testes
11. Interface: conexão e estados de conexão
12. Interface: painel ao vivo
13. Interface: histórico, detalhe de parâmetro, gráficos
14. Interface: diagnóstico e freeze frame
15. Interface: anomalias e calibração
16. Exportação CSV/JSON + modo de validação
17. Serviço em primeiro plano
18. Modo direção

**Por que o Bluetooth real vem no item 9 e não no fim.** Tecnicamente daria para
deixá-lo por último, já que os itens 1 a 8 são feitos inteiramente contra o
simulador. Mas o cronograma do TCC (Quadro 2) põe a coleta de dados do veículo
entre agosto e setembro, e a baseline estatística precisa de semanas de condução
real para ficar utilizável. Adiar o hardware para outubro fecha a janela de coleta
e deixa o TCC2 sem dado real para analisar.

Então: assim que a gravação de sessão funcionar contra o mock (item 8), conecte no
carro e **comece a coletar em paralelo** com o desenvolvimento da interface. Os
dados se acumulam enquanto os itens 10 a 18 são construídos. O simulador continua
sendo o caminho de teste automatizado — ele não é substituído pelo hardware, os
dois convivem.

---

## 18. Critérios de aceite da Fase 1

A fase está concluída quando **todos** forem verdadeiros:

- [ ] O app conecta a um ELM327 real e lê pelo menos RPM, velocidade, ECT, TPS,
      carga e tensão do Volvo V40 2019
- [ ] Os PIDs suportados são descobertos automaticamente, sem lista fixa no código
- [ ] Os DTCs são lidos e decodificados corretamente, validados contra um scanner
      comercial
- [ ] Uma sessão de 30 minutos é gravada sem perda de dado e sem travar a interface
- [ ] Após coleta suficiente, o perfil normal é construído por contexto operacional
- [ ] O consumo tem baseline própria e desvio detectável, não só exibição (RF24)
- [ ] O perfil `superaquecimento` do simulador dispara anomalia; o perfil `normal`
      não dispara nenhuma
- [ ] **No veículo real**, ao menos uma condição atípica conhecida e reproduzível é
      detectada — partida a frio prolongada, carga sustentada de ar-condicionado
      parado, ou subida longa. O TCC (5.1 e 5.7) promete validação em "situações
      conhecidas de comportamento atípico do veículo"; validar só no simulador não
      cumpre o que foi escrito
- [ ] Todo alerta é legível por quem não conhece o termo "desvio padrão" (RF23)
- [ ] O app funciona por completo em modo simulado, sem hardware
- [ ] Os dados exportam em CSV com o esquema documentado
- [ ] `flutter analyze` limpo e `flutter test` verde
- [ ] Os valores exibidos batem com os de um scanner comercial nos mesmos
      parâmetros — a evidência da seção 5.7 do TCC

---

## 19. Fases futuras — não implementar agora

**Fase 2 — API Laravel.** Sincronização das sessões, histórico entre
dispositivos, backup. O contrato JSON já sai pronto da Fase 1 (§2.1, item 4). O
trabalho fica sendo autenticação, resolução de conflito e a fila de sincronização
no cliente. Depende de ter onde hospedar.

**Fase 3 — Análise em Python.** Modelos sobre o histórico acumulado: Isolation
Forest para anomalia multivariada, previsão de degradação por série temporal.
Só faz sentido com meses de dados reais coletados — o que é justamente o que a
Fase 1 produz. Note que o Z-score contextual da Fase 1 já atende ao objetivo do
TCC; a Fase 3 é extensão, não pendência.

---

## 20. Pendências no texto do TCC

Três pontos em que a implementação avança sobre o que está escrito no TCC1.
Nenhum é problema — todos são melhorias justificáveis. Mas o texto do TCC2
precisa acompanhar, senão a banca encontra a divergência antes de você.

| O que mudou | Onde ajustar no TCC |
|---|---|
| Baseline segmentada por contexto operacional, em vez de média global por parâmetro | Reescrever 5.5 com a justificativa de §12.1–12.2 |
| Simulador OBD-II como artefato do trabalho | Incluir como etapa em 5.2, na Figura 1 e no Quadro 2 (jul–ago) |
| Eficiência tratada como parâmetro analisado, com baseline própria | Explicitar em 5.5 e 5.6 — hoje o texto só menciona exibir consumo |
| Taxa de amostragem real do adaptador | Medir e registrar em 5.4; não afirmar frequência sem medição |

---

## 21. Glossário

**ECU** — Electronic Control Unit, a central eletrônica que controla o motor.
**OBD-II** — padrão de diagnóstico de bordo, obrigatório no Brasil desde 2010.
**ELM327** — chip que traduz os protocolos OBD-II para uma interface serial de texto.
**DLC** — o conector trapezoidal de 16 pinos sob o painel.
**PID** — Parameter ID, o identificador de um parâmetro consultável.
**DTC** — Diagnostic Trouble Code, o código de falha armazenado na ECU.
**MIL** — Malfunction Indicator Light, a luz de injeção no painel.
**Freeze frame** — instantâneo das condições do veículo no momento em que a falha foi registrada.
**ISO-TP** — protocolo de transporte que fragmenta mensagens longas sobre CAN.
**Baseline** — o perfil de funcionamento normal aprendido, por parâmetro e contexto.
