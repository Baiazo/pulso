import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/db/database.dart';
import 'package:pulso/domain/entities/enums.dart';
import 'package:pulso/presentation/alerts/alerts_screen.dart';
import 'package:pulso/presentation/providers/app_providers.dart';

String _timeLabel(DateTime ts) =>
    '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

void main() {
  group('AlertsScreen (item 15)', () {
    testWidgets('sem veículo mostra o estado vazio', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory()))],
          child: const MaterialApp(home: AlertsScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Nenhum alerta registrado ainda.'), findsOneWidget);
    });

    testWidgets(
        'separa alerta aberto (sem confirmação) de alerta resolvido '
        '(3+ viagens sem repetir)', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
      addTearDown(container.dispose);

      final vehicleRepo = container.read(vehicleRepositoryProvider);
      final sessionRepo = container.read(sessionRepositoryProvider);
      final anomalyRepo = container.read(anomalyRepositoryProvider);

      final vehicle = await vehicleRepo.create(
        vin: 'YV1MZ7B2XPB123456',
        apelido: 'Meu Volvo',
        modelo: 'V40 2019',
        ano: 2019,
        cilindradaL: 2.0,
        tipoCombustivel: FuelType.flex,
      );

      final now = DateTime.now();

      // Cinco sessões finalizadas, mais espaçada (há 4 dias) até a mais
      // recente (há 12 h) — todas encerradas, nenhuma em andamento.
      Future<int> seedFinishedSession(Duration agoStart) async {
        final start = now.subtract(agoStart);
        final session = await sessionRepo.start(
          vehicleId: vehicle.id!,
          iniciadaEm: start,
          protocolo: 'ISO 15765-4 (CAN 11/500)',
          adaptador: 'ELM327',
          origem: SessionOrigin.simulado,
        );
        await sessionRepo.end(
          session.id!,
          encerradaEm: start.add(const Duration(minutes: 20)),
          distanciaKm: 10,
          consumoMedioKml: 11,
        );
        return session.id!;
      }

      final s1 = await seedFinishedSession(const Duration(days: 4));
      await seedFinishedSession(const Duration(days: 3));
      await seedFinishedSession(const Duration(days: 2));
      await seedFinishedSession(const Duration(days: 1));
      final s5 = await seedFinishedSession(const Duration(hours: 12));

      // Grupo 1 (coolant_temp): única ocorrência na sessão mais antiga,
      // seguida de 4 sessões finalizadas sem recorrência → resolvido.
      final anomalyATs = now.subtract(const Duration(days: 4)).add(const Duration(minutes: 10));
      await anomalyRepo.record(
        sessionId: s1,
        ts: anomalyATs,
        pidKey: 'coolant_temp',
        contexto: OperatingContext.urbano,
        valor: 106,
        mediaEsperada: 88,
        desvioPadrao: 3.1,
        z: 5.8,
        severidade: AnomalySeverity.serio,
        tipo: AnomalyType.pontual,
      );

      // Grupo 2 (control_module_voltage): ocorre na última sessão, sem
      // nenhuma sessão finalizada depois dela → continua aberto.
      final anomalyBTs = now.subtract(const Duration(hours: 12)).add(const Duration(minutes: 10));
      await anomalyRepo.record(
        sessionId: s5,
        ts: anomalyBTs,
        pidKey: 'control_module_voltage',
        contexto: OperatingContext.paradoQuente,
        valor: 11.5,
        mediaEsperada: 12.6,
        desvioPadrao: 0.3,
        z: -3.7,
        severidade: AnomalySeverity.atencao,
        tipo: AnomalyType.pontual,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: AlertsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Alertas'), findsOneWidget);
      expect(find.textContaining('1 abertos'), findsOneWidget);
      expect(find.textContaining('1 resolvidos'), findsOneWidget);

      // Alerta aberto: card com selo de severidade, título do catálogo de
      // PIDs e o trio observado/esperado/desvio (nunca o Z-score sozinho).
      expect(find.text('Tensão do módulo de controle'), findsOneWidget);
      expect(
        find.text('ATENÇÃO · ${_timeLabel(anomalyBTs)} · PARADO'),
        findsOneWidget,
      );
      expect(find.text('OBSERVADO'), findsOneWidget);
      expect(find.text('ESPERADO'), findsOneWidget);
      expect(find.text('DESVIO'), findsOneWidget);
      expect(find.text('11.5'), findsOneWidget);
      expect(find.text('12.6 ±0.3'), findsOneWidget);
      expect(find.text('-3.7 σ'), findsOneWidget);

      // Alerta resolvido: seção própria, título do catálogo e a contagem
      // de viagens sem repetir — sem os números de observado/esperado.
      expect(find.text('RESOLVIDOS'), findsOneWidget);
      expect(find.text('Temperatura do arrefecimento (ECT)'), findsOneWidget);
      expect(find.text('RESOLVIDO · 4 VIAGENS SEM REPETIR'), findsOneWidget);
    });
  });
}
