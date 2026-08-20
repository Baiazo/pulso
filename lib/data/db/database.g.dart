// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vinMeta = const VerificationMeta('vin');
  @override
  late final GeneratedColumn<String> vin = GeneratedColumn<String>(
    'vin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apelidoMeta = const VerificationMeta(
    'apelido',
  );
  @override
  late final GeneratedColumn<String> apelido = GeneratedColumn<String>(
    'apelido',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeloMeta = const VerificationMeta('modelo');
  @override
  late final GeneratedColumn<String> modelo = GeneratedColumn<String>(
    'modelo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anoMeta = const VerificationMeta('ano');
  @override
  late final GeneratedColumn<int> ano = GeneratedColumn<int>(
    'ano',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cilindradaLMeta = const VerificationMeta(
    'cilindradaL',
  );
  @override
  late final GeneratedColumn<double> cilindradaL = GeneratedColumn<double>(
    'cilindrada_l',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoCombustivelMeta = const VerificationMeta(
    'tipoCombustivel',
  );
  @override
  late final GeneratedColumn<String> tipoCombustivel = GeneratedColumn<String>(
    'tipo_combustivel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String>
  pidsSuportados = GeneratedColumn<String>(
    'pids_suportados',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<int>>($VehiclesTable.$converterpidsSuportados);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    syncedAt,
    vin,
    apelido,
    modelo,
    ano,
    cilindradaL,
    tipoCombustivel,
    pidsSuportados,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('vin')) {
      context.handle(
        _vinMeta,
        vin.isAcceptableOrUnknown(data['vin']!, _vinMeta),
      );
    } else if (isInserting) {
      context.missing(_vinMeta);
    }
    if (data.containsKey('apelido')) {
      context.handle(
        _apelidoMeta,
        apelido.isAcceptableOrUnknown(data['apelido']!, _apelidoMeta),
      );
    } else if (isInserting) {
      context.missing(_apelidoMeta);
    }
    if (data.containsKey('modelo')) {
      context.handle(
        _modeloMeta,
        modelo.isAcceptableOrUnknown(data['modelo']!, _modeloMeta),
      );
    } else if (isInserting) {
      context.missing(_modeloMeta);
    }
    if (data.containsKey('ano')) {
      context.handle(
        _anoMeta,
        ano.isAcceptableOrUnknown(data['ano']!, _anoMeta),
      );
    } else if (isInserting) {
      context.missing(_anoMeta);
    }
    if (data.containsKey('cilindrada_l')) {
      context.handle(
        _cilindradaLMeta,
        cilindradaL.isAcceptableOrUnknown(
          data['cilindrada_l']!,
          _cilindradaLMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cilindradaLMeta);
    }
    if (data.containsKey('tipo_combustivel')) {
      context.handle(
        _tipoCombustivelMeta,
        tipoCombustivel.isAcceptableOrUnknown(
          data['tipo_combustivel']!,
          _tipoCombustivelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoCombustivelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      vin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vin'],
      )!,
      apelido: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apelido'],
      )!,
      modelo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modelo'],
      )!,
      ano: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ano'],
      )!,
      cilindradaL: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cilindrada_l'],
      )!,
      tipoCombustivel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_combustivel'],
      )!,
      pidsSuportados: $VehiclesTable.$converterpidsSuportados.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pids_suportados'],
        )!,
      ),
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<int>, String> $converterpidsSuportados =
      const IntListConverter();
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final int id;
  final String uuid;
  final DateTime? syncedAt;
  final String vin;
  final String apelido;
  final String modelo;
  final int ano;
  final double cilindradaL;

  /// `.name` de [FuelType] — nunca o índice numérico (comentário do §11).
  final String tipoCombustivel;
  final List<int> pidsSuportados;
  const Vehicle({
    required this.id,
    required this.uuid,
    this.syncedAt,
    required this.vin,
    required this.apelido,
    required this.modelo,
    required this.ano,
    required this.cilindradaL,
    required this.tipoCombustivel,
    required this.pidsSuportados,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['vin'] = Variable<String>(vin);
    map['apelido'] = Variable<String>(apelido);
    map['modelo'] = Variable<String>(modelo);
    map['ano'] = Variable<int>(ano);
    map['cilindrada_l'] = Variable<double>(cilindradaL);
    map['tipo_combustivel'] = Variable<String>(tipoCombustivel);
    {
      map['pids_suportados'] = Variable<String>(
        $VehiclesTable.$converterpidsSuportados.toSql(pidsSuportados),
      );
    }
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      vin: Value(vin),
      apelido: Value(apelido),
      modelo: Value(modelo),
      ano: Value(ano),
      cilindradaL: Value(cilindradaL),
      tipoCombustivel: Value(tipoCombustivel),
      pidsSuportados: Value(pidsSuportados),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      vin: serializer.fromJson<String>(json['vin']),
      apelido: serializer.fromJson<String>(json['apelido']),
      modelo: serializer.fromJson<String>(json['modelo']),
      ano: serializer.fromJson<int>(json['ano']),
      cilindradaL: serializer.fromJson<double>(json['cilindradaL']),
      tipoCombustivel: serializer.fromJson<String>(json['tipoCombustivel']),
      pidsSuportados: serializer.fromJson<List<int>>(json['pidsSuportados']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'vin': serializer.toJson<String>(vin),
      'apelido': serializer.toJson<String>(apelido),
      'modelo': serializer.toJson<String>(modelo),
      'ano': serializer.toJson<int>(ano),
      'cilindradaL': serializer.toJson<double>(cilindradaL),
      'tipoCombustivel': serializer.toJson<String>(tipoCombustivel),
      'pidsSuportados': serializer.toJson<List<int>>(pidsSuportados),
    };
  }

  Vehicle copyWith({
    int? id,
    String? uuid,
    Value<DateTime?> syncedAt = const Value.absent(),
    String? vin,
    String? apelido,
    String? modelo,
    int? ano,
    double? cilindradaL,
    String? tipoCombustivel,
    List<int>? pidsSuportados,
  }) => Vehicle(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    vin: vin ?? this.vin,
    apelido: apelido ?? this.apelido,
    modelo: modelo ?? this.modelo,
    ano: ano ?? this.ano,
    cilindradaL: cilindradaL ?? this.cilindradaL,
    tipoCombustivel: tipoCombustivel ?? this.tipoCombustivel,
    pidsSuportados: pidsSuportados ?? this.pidsSuportados,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      vin: data.vin.present ? data.vin.value : this.vin,
      apelido: data.apelido.present ? data.apelido.value : this.apelido,
      modelo: data.modelo.present ? data.modelo.value : this.modelo,
      ano: data.ano.present ? data.ano.value : this.ano,
      cilindradaL: data.cilindradaL.present
          ? data.cilindradaL.value
          : this.cilindradaL,
      tipoCombustivel: data.tipoCombustivel.present
          ? data.tipoCombustivel.value
          : this.tipoCombustivel,
      pidsSuportados: data.pidsSuportados.present
          ? data.pidsSuportados.value
          : this.pidsSuportados,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('vin: $vin, ')
          ..write('apelido: $apelido, ')
          ..write('modelo: $modelo, ')
          ..write('ano: $ano, ')
          ..write('cilindradaL: $cilindradaL, ')
          ..write('tipoCombustivel: $tipoCombustivel, ')
          ..write('pidsSuportados: $pidsSuportados')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    syncedAt,
    vin,
    apelido,
    modelo,
    ano,
    cilindradaL,
    tipoCombustivel,
    pidsSuportados,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.syncedAt == this.syncedAt &&
          other.vin == this.vin &&
          other.apelido == this.apelido &&
          other.modelo == this.modelo &&
          other.ano == this.ano &&
          other.cilindradaL == this.cilindradaL &&
          other.tipoCombustivel == this.tipoCombustivel &&
          other.pidsSuportados == this.pidsSuportados);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<DateTime?> syncedAt;
  final Value<String> vin;
  final Value<String> apelido;
  final Value<String> modelo;
  final Value<int> ano;
  final Value<double> cilindradaL;
  final Value<String> tipoCombustivel;
  final Value<List<int>> pidsSuportados;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.vin = const Value.absent(),
    this.apelido = const Value.absent(),
    this.modelo = const Value.absent(),
    this.ano = const Value.absent(),
    this.cilindradaL = const Value.absent(),
    this.tipoCombustivel = const Value.absent(),
    this.pidsSuportados = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.syncedAt = const Value.absent(),
    required String vin,
    required String apelido,
    required String modelo,
    required int ano,
    required double cilindradaL,
    required String tipoCombustivel,
    this.pidsSuportados = const Value.absent(),
  }) : uuid = Value(uuid),
       vin = Value(vin),
       apelido = Value(apelido),
       modelo = Value(modelo),
       ano = Value(ano),
       cilindradaL = Value(cilindradaL),
       tipoCombustivel = Value(tipoCombustivel);
  static Insertable<Vehicle> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<DateTime>? syncedAt,
    Expression<String>? vin,
    Expression<String>? apelido,
    Expression<String>? modelo,
    Expression<int>? ano,
    Expression<double>? cilindradaL,
    Expression<String>? tipoCombustivel,
    Expression<String>? pidsSuportados,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (vin != null) 'vin': vin,
      if (apelido != null) 'apelido': apelido,
      if (modelo != null) 'modelo': modelo,
      if (ano != null) 'ano': ano,
      if (cilindradaL != null) 'cilindrada_l': cilindradaL,
      if (tipoCombustivel != null) 'tipo_combustivel': tipoCombustivel,
      if (pidsSuportados != null) 'pids_suportados': pidsSuportados,
    });
  }

  VehiclesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<DateTime?>? syncedAt,
    Value<String>? vin,
    Value<String>? apelido,
    Value<String>? modelo,
    Value<int>? ano,
    Value<double>? cilindradaL,
    Value<String>? tipoCombustivel,
    Value<List<int>>? pidsSuportados,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      syncedAt: syncedAt ?? this.syncedAt,
      vin: vin ?? this.vin,
      apelido: apelido ?? this.apelido,
      modelo: modelo ?? this.modelo,
      ano: ano ?? this.ano,
      cilindradaL: cilindradaL ?? this.cilindradaL,
      tipoCombustivel: tipoCombustivel ?? this.tipoCombustivel,
      pidsSuportados: pidsSuportados ?? this.pidsSuportados,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (vin.present) {
      map['vin'] = Variable<String>(vin.value);
    }
    if (apelido.present) {
      map['apelido'] = Variable<String>(apelido.value);
    }
    if (modelo.present) {
      map['modelo'] = Variable<String>(modelo.value);
    }
    if (ano.present) {
      map['ano'] = Variable<int>(ano.value);
    }
    if (cilindradaL.present) {
      map['cilindrada_l'] = Variable<double>(cilindradaL.value);
    }
    if (tipoCombustivel.present) {
      map['tipo_combustivel'] = Variable<String>(tipoCombustivel.value);
    }
    if (pidsSuportados.present) {
      map['pids_suportados'] = Variable<String>(
        $VehiclesTable.$converterpidsSuportados.toSql(pidsSuportados.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('vin: $vin, ')
          ..write('apelido: $apelido, ')
          ..write('modelo: $modelo, ')
          ..write('ano: $ano, ')
          ..write('cilindradaL: $cilindradaL, ')
          ..write('tipoCombustivel: $tipoCombustivel, ')
          ..write('pidsSuportados: $pidsSuportados')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _iniciadaEmMeta = const VerificationMeta(
    'iniciadaEm',
  );
  @override
  late final GeneratedColumn<DateTime> iniciadaEm = GeneratedColumn<DateTime>(
    'iniciada_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encerradaEmMeta = const VerificationMeta(
    'encerradaEm',
  );
  @override
  late final GeneratedColumn<DateTime> encerradaEm = GeneratedColumn<DateTime>(
    'encerrada_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _protocoloMeta = const VerificationMeta(
    'protocolo',
  );
  @override
  late final GeneratedColumn<String> protocolo = GeneratedColumn<String>(
    'protocolo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adaptadorMeta = const VerificationMeta(
    'adaptador',
  );
  @override
  late final GeneratedColumn<String> adaptador = GeneratedColumn<String>(
    'adaptador',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _origemMeta = const VerificationMeta('origem');
  @override
  late final GeneratedColumn<String> origem = GeneratedColumn<String>(
    'origem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanciaKmMeta = const VerificationMeta(
    'distanciaKm',
  );
  @override
  late final GeneratedColumn<double> distanciaKm = GeneratedColumn<double>(
    'distancia_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _duracaoSMeta = const VerificationMeta(
    'duracaoS',
  );
  @override
  late final GeneratedColumn<int> duracaoS = GeneratedColumn<int>(
    'duracao_s',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consumoMedioKmlMeta = const VerificationMeta(
    'consumoMedioKml',
  );
  @override
  late final GeneratedColumn<double> consumoMedioKml = GeneratedColumn<double>(
    'consumo_medio_kml',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    syncedAt,
    vehicleId,
    iniciadaEm,
    encerradaEm,
    protocolo,
    adaptador,
    origem,
    distanciaKm,
    duracaoS,
    consumoMedioKml,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('iniciada_em')) {
      context.handle(
        _iniciadaEmMeta,
        iniciadaEm.isAcceptableOrUnknown(data['iniciada_em']!, _iniciadaEmMeta),
      );
    } else if (isInserting) {
      context.missing(_iniciadaEmMeta);
    }
    if (data.containsKey('encerrada_em')) {
      context.handle(
        _encerradaEmMeta,
        encerradaEm.isAcceptableOrUnknown(
          data['encerrada_em']!,
          _encerradaEmMeta,
        ),
      );
    }
    if (data.containsKey('protocolo')) {
      context.handle(
        _protocoloMeta,
        protocolo.isAcceptableOrUnknown(data['protocolo']!, _protocoloMeta),
      );
    } else if (isInserting) {
      context.missing(_protocoloMeta);
    }
    if (data.containsKey('adaptador')) {
      context.handle(
        _adaptadorMeta,
        adaptador.isAcceptableOrUnknown(data['adaptador']!, _adaptadorMeta),
      );
    } else if (isInserting) {
      context.missing(_adaptadorMeta);
    }
    if (data.containsKey('origem')) {
      context.handle(
        _origemMeta,
        origem.isAcceptableOrUnknown(data['origem']!, _origemMeta),
      );
    } else if (isInserting) {
      context.missing(_origemMeta);
    }
    if (data.containsKey('distancia_km')) {
      context.handle(
        _distanciaKmMeta,
        distanciaKm.isAcceptableOrUnknown(
          data['distancia_km']!,
          _distanciaKmMeta,
        ),
      );
    }
    if (data.containsKey('duracao_s')) {
      context.handle(
        _duracaoSMeta,
        duracaoS.isAcceptableOrUnknown(data['duracao_s']!, _duracaoSMeta),
      );
    }
    if (data.containsKey('consumo_medio_kml')) {
      context.handle(
        _consumoMedioKmlMeta,
        consumoMedioKml.isAcceptableOrUnknown(
          data['consumo_medio_kml']!,
          _consumoMedioKmlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      iniciadaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}iniciada_em'],
      )!,
      encerradaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}encerrada_em'],
      ),
      protocolo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocolo'],
      )!,
      adaptador: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adaptador'],
      )!,
      origem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origem'],
      )!,
      distanciaKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distancia_km'],
      ),
      duracaoS: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duracao_s'],
      ),
      consumoMedioKml: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}consumo_medio_kml'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String uuid;
  final DateTime? syncedAt;
  final int vehicleId;
  final DateTime iniciadaEm;
  final DateTime? encerradaEm;
  final String protocolo;
  final String adaptador;
  final String origem;
  final double? distanciaKm;
  final int? duracaoS;
  final double? consumoMedioKml;
  const Session({
    required this.id,
    required this.uuid,
    this.syncedAt,
    required this.vehicleId,
    required this.iniciadaEm,
    this.encerradaEm,
    required this.protocolo,
    required this.adaptador,
    required this.origem,
    this.distanciaKm,
    this.duracaoS,
    this.consumoMedioKml,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['iniciada_em'] = Variable<DateTime>(iniciadaEm);
    if (!nullToAbsent || encerradaEm != null) {
      map['encerrada_em'] = Variable<DateTime>(encerradaEm);
    }
    map['protocolo'] = Variable<String>(protocolo);
    map['adaptador'] = Variable<String>(adaptador);
    map['origem'] = Variable<String>(origem);
    if (!nullToAbsent || distanciaKm != null) {
      map['distancia_km'] = Variable<double>(distanciaKm);
    }
    if (!nullToAbsent || duracaoS != null) {
      map['duracao_s'] = Variable<int>(duracaoS);
    }
    if (!nullToAbsent || consumoMedioKml != null) {
      map['consumo_medio_kml'] = Variable<double>(consumoMedioKml);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      vehicleId: Value(vehicleId),
      iniciadaEm: Value(iniciadaEm),
      encerradaEm: encerradaEm == null && nullToAbsent
          ? const Value.absent()
          : Value(encerradaEm),
      protocolo: Value(protocolo),
      adaptador: Value(adaptador),
      origem: Value(origem),
      distanciaKm: distanciaKm == null && nullToAbsent
          ? const Value.absent()
          : Value(distanciaKm),
      duracaoS: duracaoS == null && nullToAbsent
          ? const Value.absent()
          : Value(duracaoS),
      consumoMedioKml: consumoMedioKml == null && nullToAbsent
          ? const Value.absent()
          : Value(consumoMedioKml),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      iniciadaEm: serializer.fromJson<DateTime>(json['iniciadaEm']),
      encerradaEm: serializer.fromJson<DateTime?>(json['encerradaEm']),
      protocolo: serializer.fromJson<String>(json['protocolo']),
      adaptador: serializer.fromJson<String>(json['adaptador']),
      origem: serializer.fromJson<String>(json['origem']),
      distanciaKm: serializer.fromJson<double?>(json['distanciaKm']),
      duracaoS: serializer.fromJson<int?>(json['duracaoS']),
      consumoMedioKml: serializer.fromJson<double?>(json['consumoMedioKml']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'iniciadaEm': serializer.toJson<DateTime>(iniciadaEm),
      'encerradaEm': serializer.toJson<DateTime?>(encerradaEm),
      'protocolo': serializer.toJson<String>(protocolo),
      'adaptador': serializer.toJson<String>(adaptador),
      'origem': serializer.toJson<String>(origem),
      'distanciaKm': serializer.toJson<double?>(distanciaKm),
      'duracaoS': serializer.toJson<int?>(duracaoS),
      'consumoMedioKml': serializer.toJson<double?>(consumoMedioKml),
    };
  }

  Session copyWith({
    int? id,
    String? uuid,
    Value<DateTime?> syncedAt = const Value.absent(),
    int? vehicleId,
    DateTime? iniciadaEm,
    Value<DateTime?> encerradaEm = const Value.absent(),
    String? protocolo,
    String? adaptador,
    String? origem,
    Value<double?> distanciaKm = const Value.absent(),
    Value<int?> duracaoS = const Value.absent(),
    Value<double?> consumoMedioKml = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    vehicleId: vehicleId ?? this.vehicleId,
    iniciadaEm: iniciadaEm ?? this.iniciadaEm,
    encerradaEm: encerradaEm.present ? encerradaEm.value : this.encerradaEm,
    protocolo: protocolo ?? this.protocolo,
    adaptador: adaptador ?? this.adaptador,
    origem: origem ?? this.origem,
    distanciaKm: distanciaKm.present ? distanciaKm.value : this.distanciaKm,
    duracaoS: duracaoS.present ? duracaoS.value : this.duracaoS,
    consumoMedioKml: consumoMedioKml.present
        ? consumoMedioKml.value
        : this.consumoMedioKml,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      iniciadaEm: data.iniciadaEm.present
          ? data.iniciadaEm.value
          : this.iniciadaEm,
      encerradaEm: data.encerradaEm.present
          ? data.encerradaEm.value
          : this.encerradaEm,
      protocolo: data.protocolo.present ? data.protocolo.value : this.protocolo,
      adaptador: data.adaptador.present ? data.adaptador.value : this.adaptador,
      origem: data.origem.present ? data.origem.value : this.origem,
      distanciaKm: data.distanciaKm.present
          ? data.distanciaKm.value
          : this.distanciaKm,
      duracaoS: data.duracaoS.present ? data.duracaoS.value : this.duracaoS,
      consumoMedioKml: data.consumoMedioKml.present
          ? data.consumoMedioKml.value
          : this.consumoMedioKml,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('iniciadaEm: $iniciadaEm, ')
          ..write('encerradaEm: $encerradaEm, ')
          ..write('protocolo: $protocolo, ')
          ..write('adaptador: $adaptador, ')
          ..write('origem: $origem, ')
          ..write('distanciaKm: $distanciaKm, ')
          ..write('duracaoS: $duracaoS, ')
          ..write('consumoMedioKml: $consumoMedioKml')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    syncedAt,
    vehicleId,
    iniciadaEm,
    encerradaEm,
    protocolo,
    adaptador,
    origem,
    distanciaKm,
    duracaoS,
    consumoMedioKml,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.syncedAt == this.syncedAt &&
          other.vehicleId == this.vehicleId &&
          other.iniciadaEm == this.iniciadaEm &&
          other.encerradaEm == this.encerradaEm &&
          other.protocolo == this.protocolo &&
          other.adaptador == this.adaptador &&
          other.origem == this.origem &&
          other.distanciaKm == this.distanciaKm &&
          other.duracaoS == this.duracaoS &&
          other.consumoMedioKml == this.consumoMedioKml);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<DateTime?> syncedAt;
  final Value<int> vehicleId;
  final Value<DateTime> iniciadaEm;
  final Value<DateTime?> encerradaEm;
  final Value<String> protocolo;
  final Value<String> adaptador;
  final Value<String> origem;
  final Value<double?> distanciaKm;
  final Value<int?> duracaoS;
  final Value<double?> consumoMedioKml;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.iniciadaEm = const Value.absent(),
    this.encerradaEm = const Value.absent(),
    this.protocolo = const Value.absent(),
    this.adaptador = const Value.absent(),
    this.origem = const Value.absent(),
    this.distanciaKm = const Value.absent(),
    this.duracaoS = const Value.absent(),
    this.consumoMedioKml = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.syncedAt = const Value.absent(),
    required int vehicleId,
    required DateTime iniciadaEm,
    this.encerradaEm = const Value.absent(),
    required String protocolo,
    required String adaptador,
    required String origem,
    this.distanciaKm = const Value.absent(),
    this.duracaoS = const Value.absent(),
    this.consumoMedioKml = const Value.absent(),
  }) : uuid = Value(uuid),
       vehicleId = Value(vehicleId),
       iniciadaEm = Value(iniciadaEm),
       protocolo = Value(protocolo),
       adaptador = Value(adaptador),
       origem = Value(origem);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<DateTime>? syncedAt,
    Expression<int>? vehicleId,
    Expression<DateTime>? iniciadaEm,
    Expression<DateTime>? encerradaEm,
    Expression<String>? protocolo,
    Expression<String>? adaptador,
    Expression<String>? origem,
    Expression<double>? distanciaKm,
    Expression<int>? duracaoS,
    Expression<double>? consumoMedioKml,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (iniciadaEm != null) 'iniciada_em': iniciadaEm,
      if (encerradaEm != null) 'encerrada_em': encerradaEm,
      if (protocolo != null) 'protocolo': protocolo,
      if (adaptador != null) 'adaptador': adaptador,
      if (origem != null) 'origem': origem,
      if (distanciaKm != null) 'distancia_km': distanciaKm,
      if (duracaoS != null) 'duracao_s': duracaoS,
      if (consumoMedioKml != null) 'consumo_medio_kml': consumoMedioKml,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<DateTime?>? syncedAt,
    Value<int>? vehicleId,
    Value<DateTime>? iniciadaEm,
    Value<DateTime?>? encerradaEm,
    Value<String>? protocolo,
    Value<String>? adaptador,
    Value<String>? origem,
    Value<double?>? distanciaKm,
    Value<int?>? duracaoS,
    Value<double?>? consumoMedioKml,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      syncedAt: syncedAt ?? this.syncedAt,
      vehicleId: vehicleId ?? this.vehicleId,
      iniciadaEm: iniciadaEm ?? this.iniciadaEm,
      encerradaEm: encerradaEm ?? this.encerradaEm,
      protocolo: protocolo ?? this.protocolo,
      adaptador: adaptador ?? this.adaptador,
      origem: origem ?? this.origem,
      distanciaKm: distanciaKm ?? this.distanciaKm,
      duracaoS: duracaoS ?? this.duracaoS,
      consumoMedioKml: consumoMedioKml ?? this.consumoMedioKml,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (iniciadaEm.present) {
      map['iniciada_em'] = Variable<DateTime>(iniciadaEm.value);
    }
    if (encerradaEm.present) {
      map['encerrada_em'] = Variable<DateTime>(encerradaEm.value);
    }
    if (protocolo.present) {
      map['protocolo'] = Variable<String>(protocolo.value);
    }
    if (adaptador.present) {
      map['adaptador'] = Variable<String>(adaptador.value);
    }
    if (origem.present) {
      map['origem'] = Variable<String>(origem.value);
    }
    if (distanciaKm.present) {
      map['distancia_km'] = Variable<double>(distanciaKm.value);
    }
    if (duracaoS.present) {
      map['duracao_s'] = Variable<int>(duracaoS.value);
    }
    if (consumoMedioKml.present) {
      map['consumo_medio_kml'] = Variable<double>(consumoMedioKml.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('iniciadaEm: $iniciadaEm, ')
          ..write('encerradaEm: $encerradaEm, ')
          ..write('protocolo: $protocolo, ')
          ..write('adaptador: $adaptador, ')
          ..write('origem: $origem, ')
          ..write('distanciaKm: $distanciaKm, ')
          ..write('duracaoS: $duracaoS, ')
          ..write('consumoMedioKml: $consumoMedioKml')
          ..write(')'))
        .toString();
  }
}

class $ReadingsTable extends Readings with TableInfo<$ReadingsTable, Reading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pidKeyMeta = const VerificationMeta('pidKey');
  @override
  late final GeneratedColumn<String> pidKey = GeneratedColumn<String>(
    'pid_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextoMeta = const VerificationMeta(
    'contexto',
  );
  @override
  late final GeneratedColumn<String> contexto = GeneratedColumn<String>(
    'contexto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    syncedAt,
    sessionId,
    ts,
    pidKey,
    valor,
    contexto,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('pid_key')) {
      context.handle(
        _pidKeyMeta,
        pidKey.isAcceptableOrUnknown(data['pid_key']!, _pidKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_pidKeyMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('contexto')) {
      context.handle(
        _contextoMeta,
        contexto.isAcceptableOrUnknown(data['contexto']!, _contextoMeta),
      );
    } else if (isInserting) {
      context.missing(_contextoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ts'],
      )!,
      pidKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pid_key'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      )!,
      contexto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contexto'],
      )!,
    );
  }

  @override
  $ReadingsTable createAlias(String alias) {
    return $ReadingsTable(attachedDatabase, alias);
  }
}

class Reading extends DataClass implements Insertable<Reading> {
  final int id;
  final String uuid;
  final DateTime? syncedAt;
  final int sessionId;
  final DateTime ts;
  final String pidKey;
  final double valor;
  final String contexto;
  const Reading({
    required this.id,
    required this.uuid,
    this.syncedAt,
    required this.sessionId,
    required this.ts,
    required this.pidKey,
    required this.valor,
    required this.contexto,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['session_id'] = Variable<int>(sessionId);
    map['ts'] = Variable<DateTime>(ts);
    map['pid_key'] = Variable<String>(pidKey);
    map['valor'] = Variable<double>(valor);
    map['contexto'] = Variable<String>(contexto);
    return map;
  }

  ReadingsCompanion toCompanion(bool nullToAbsent) {
    return ReadingsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      sessionId: Value(sessionId),
      ts: Value(ts),
      pidKey: Value(pidKey),
      valor: Value(valor),
      contexto: Value(contexto),
    );
  }

  factory Reading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reading(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      ts: serializer.fromJson<DateTime>(json['ts']),
      pidKey: serializer.fromJson<String>(json['pidKey']),
      valor: serializer.fromJson<double>(json['valor']),
      contexto: serializer.fromJson<String>(json['contexto']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'sessionId': serializer.toJson<int>(sessionId),
      'ts': serializer.toJson<DateTime>(ts),
      'pidKey': serializer.toJson<String>(pidKey),
      'valor': serializer.toJson<double>(valor),
      'contexto': serializer.toJson<String>(contexto),
    };
  }

  Reading copyWith({
    int? id,
    String? uuid,
    Value<DateTime?> syncedAt = const Value.absent(),
    int? sessionId,
    DateTime? ts,
    String? pidKey,
    double? valor,
    String? contexto,
  }) => Reading(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    sessionId: sessionId ?? this.sessionId,
    ts: ts ?? this.ts,
    pidKey: pidKey ?? this.pidKey,
    valor: valor ?? this.valor,
    contexto: contexto ?? this.contexto,
  );
  Reading copyWithCompanion(ReadingsCompanion data) {
    return Reading(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      ts: data.ts.present ? data.ts.value : this.ts,
      pidKey: data.pidKey.present ? data.pidKey.value : this.pidKey,
      valor: data.valor.present ? data.valor.value : this.valor,
      contexto: data.contexto.present ? data.contexto.value : this.contexto,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reading(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('ts: $ts, ')
          ..write('pidKey: $pidKey, ')
          ..write('valor: $valor, ')
          ..write('contexto: $contexto')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uuid, syncedAt, sessionId, ts, pidKey, valor, contexto);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reading &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.syncedAt == this.syncedAt &&
          other.sessionId == this.sessionId &&
          other.ts == this.ts &&
          other.pidKey == this.pidKey &&
          other.valor == this.valor &&
          other.contexto == this.contexto);
}

class ReadingsCompanion extends UpdateCompanion<Reading> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<DateTime?> syncedAt;
  final Value<int> sessionId;
  final Value<DateTime> ts;
  final Value<String> pidKey;
  final Value<double> valor;
  final Value<String> contexto;
  const ReadingsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.ts = const Value.absent(),
    this.pidKey = const Value.absent(),
    this.valor = const Value.absent(),
    this.contexto = const Value.absent(),
  });
  ReadingsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.syncedAt = const Value.absent(),
    required int sessionId,
    required DateTime ts,
    required String pidKey,
    required double valor,
    required String contexto,
  }) : uuid = Value(uuid),
       sessionId = Value(sessionId),
       ts = Value(ts),
       pidKey = Value(pidKey),
       valor = Value(valor),
       contexto = Value(contexto);
  static Insertable<Reading> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<DateTime>? syncedAt,
    Expression<int>? sessionId,
    Expression<DateTime>? ts,
    Expression<String>? pidKey,
    Expression<double>? valor,
    Expression<String>? contexto,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (sessionId != null) 'session_id': sessionId,
      if (ts != null) 'ts': ts,
      if (pidKey != null) 'pid_key': pidKey,
      if (valor != null) 'valor': valor,
      if (contexto != null) 'contexto': contexto,
    });
  }

  ReadingsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<DateTime?>? syncedAt,
    Value<int>? sessionId,
    Value<DateTime>? ts,
    Value<String>? pidKey,
    Value<double>? valor,
    Value<String>? contexto,
  }) {
    return ReadingsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      syncedAt: syncedAt ?? this.syncedAt,
      sessionId: sessionId ?? this.sessionId,
      ts: ts ?? this.ts,
      pidKey: pidKey ?? this.pidKey,
      valor: valor ?? this.valor,
      contexto: contexto ?? this.contexto,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (pidKey.present) {
      map['pid_key'] = Variable<String>(pidKey.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (contexto.present) {
      map['contexto'] = Variable<String>(contexto.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('ts: $ts, ')
          ..write('pidKey: $pidKey, ')
          ..write('valor: $valor, ')
          ..write('contexto: $contexto')
          ..write(')'))
        .toString();
  }
}

class $RawFramesTable extends RawFrames
    with TableInfo<$RawFramesTable, RawFrame> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RawFramesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _comandoMeta = const VerificationMeta(
    'comando',
  );
  @override
  late final GeneratedColumn<String> comando = GeneratedColumn<String>(
    'comando',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respostaBrutaMeta = const VerificationMeta(
    'respostaBruta',
  );
  @override
  late final GeneratedColumn<String> respostaBruta = GeneratedColumn<String>(
    'resposta_bruta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    syncedAt,
    sessionId,
    ts,
    comando,
    respostaBruta,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'raw_frames';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawFrame> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('comando')) {
      context.handle(
        _comandoMeta,
        comando.isAcceptableOrUnknown(data['comando']!, _comandoMeta),
      );
    } else if (isInserting) {
      context.missing(_comandoMeta);
    }
    if (data.containsKey('resposta_bruta')) {
      context.handle(
        _respostaBrutaMeta,
        respostaBruta.isAcceptableOrUnknown(
          data['resposta_bruta']!,
          _respostaBrutaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_respostaBrutaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawFrame map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawFrame(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ts'],
      )!,
      comando: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comando'],
      )!,
      respostaBruta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resposta_bruta'],
      )!,
    );
  }

  @override
  $RawFramesTable createAlias(String alias) {
    return $RawFramesTable(attachedDatabase, alias);
  }
}

class RawFrame extends DataClass implements Insertable<RawFrame> {
  final int id;
  final String uuid;
  final DateTime? syncedAt;
  final int sessionId;
  final DateTime ts;
  final String comando;
  final String respostaBruta;
  const RawFrame({
    required this.id,
    required this.uuid,
    this.syncedAt,
    required this.sessionId,
    required this.ts,
    required this.comando,
    required this.respostaBruta,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['session_id'] = Variable<int>(sessionId);
    map['ts'] = Variable<DateTime>(ts);
    map['comando'] = Variable<String>(comando);
    map['resposta_bruta'] = Variable<String>(respostaBruta);
    return map;
  }

  RawFramesCompanion toCompanion(bool nullToAbsent) {
    return RawFramesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      sessionId: Value(sessionId),
      ts: Value(ts),
      comando: Value(comando),
      respostaBruta: Value(respostaBruta),
    );
  }

  factory RawFrame.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawFrame(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      ts: serializer.fromJson<DateTime>(json['ts']),
      comando: serializer.fromJson<String>(json['comando']),
      respostaBruta: serializer.fromJson<String>(json['respostaBruta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'sessionId': serializer.toJson<int>(sessionId),
      'ts': serializer.toJson<DateTime>(ts),
      'comando': serializer.toJson<String>(comando),
      'respostaBruta': serializer.toJson<String>(respostaBruta),
    };
  }

  RawFrame copyWith({
    int? id,
    String? uuid,
    Value<DateTime?> syncedAt = const Value.absent(),
    int? sessionId,
    DateTime? ts,
    String? comando,
    String? respostaBruta,
  }) => RawFrame(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    sessionId: sessionId ?? this.sessionId,
    ts: ts ?? this.ts,
    comando: comando ?? this.comando,
    respostaBruta: respostaBruta ?? this.respostaBruta,
  );
  RawFrame copyWithCompanion(RawFramesCompanion data) {
    return RawFrame(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      ts: data.ts.present ? data.ts.value : this.ts,
      comando: data.comando.present ? data.comando.value : this.comando,
      respostaBruta: data.respostaBruta.present
          ? data.respostaBruta.value
          : this.respostaBruta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawFrame(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('ts: $ts, ')
          ..write('comando: $comando, ')
          ..write('respostaBruta: $respostaBruta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uuid, syncedAt, sessionId, ts, comando, respostaBruta);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawFrame &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.syncedAt == this.syncedAt &&
          other.sessionId == this.sessionId &&
          other.ts == this.ts &&
          other.comando == this.comando &&
          other.respostaBruta == this.respostaBruta);
}

class RawFramesCompanion extends UpdateCompanion<RawFrame> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<DateTime?> syncedAt;
  final Value<int> sessionId;
  final Value<DateTime> ts;
  final Value<String> comando;
  final Value<String> respostaBruta;
  const RawFramesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.ts = const Value.absent(),
    this.comando = const Value.absent(),
    this.respostaBruta = const Value.absent(),
  });
  RawFramesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.syncedAt = const Value.absent(),
    required int sessionId,
    required DateTime ts,
    required String comando,
    required String respostaBruta,
  }) : uuid = Value(uuid),
       sessionId = Value(sessionId),
       ts = Value(ts),
       comando = Value(comando),
       respostaBruta = Value(respostaBruta);
  static Insertable<RawFrame> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<DateTime>? syncedAt,
    Expression<int>? sessionId,
    Expression<DateTime>? ts,
    Expression<String>? comando,
    Expression<String>? respostaBruta,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (sessionId != null) 'session_id': sessionId,
      if (ts != null) 'ts': ts,
      if (comando != null) 'comando': comando,
      if (respostaBruta != null) 'resposta_bruta': respostaBruta,
    });
  }

  RawFramesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<DateTime?>? syncedAt,
    Value<int>? sessionId,
    Value<DateTime>? ts,
    Value<String>? comando,
    Value<String>? respostaBruta,
  }) {
    return RawFramesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      syncedAt: syncedAt ?? this.syncedAt,
      sessionId: sessionId ?? this.sessionId,
      ts: ts ?? this.ts,
      comando: comando ?? this.comando,
      respostaBruta: respostaBruta ?? this.respostaBruta,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (comando.present) {
      map['comando'] = Variable<String>(comando.value);
    }
    if (respostaBruta.present) {
      map['resposta_bruta'] = Variable<String>(respostaBruta.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RawFramesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('ts: $ts, ')
          ..write('comando: $comando, ')
          ..write('respostaBruta: $respostaBruta')
          ..write(')'))
        .toString();
  }
}

class $DtcEventsTable extends DtcEvents
    with TableInfo<$DtcEventsTable, DtcEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DtcEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, double>, String>
  freezeFrame = GeneratedColumn<String>(
    'freeze_frame',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  ).withConverter<Map<String, double>>($DtcEventsTable.$converterfreezeFrame);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    syncedAt,
    sessionId,
    ts,
    codigo,
    tipo,
    descricao,
    freezeFrame,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dtc_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DtcEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DtcEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DtcEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ts'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      freezeFrame: $DtcEventsTable.$converterfreezeFrame.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}freeze_frame'],
        )!,
      ),
    );
  }

  @override
  $DtcEventsTable createAlias(String alias) {
    return $DtcEventsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, double>, String> $converterfreezeFrame =
      const DoubleMapConverter();
}

class DtcEvent extends DataClass implements Insertable<DtcEvent> {
  final int id;
  final String uuid;
  final DateTime? syncedAt;
  final int sessionId;
  final DateTime ts;
  final String codigo;
  final String tipo;
  final String descricao;
  final Map<String, double> freezeFrame;
  const DtcEvent({
    required this.id,
    required this.uuid,
    this.syncedAt,
    required this.sessionId,
    required this.ts,
    required this.codigo,
    required this.tipo,
    required this.descricao,
    required this.freezeFrame,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['session_id'] = Variable<int>(sessionId);
    map['ts'] = Variable<DateTime>(ts);
    map['codigo'] = Variable<String>(codigo);
    map['tipo'] = Variable<String>(tipo);
    map['descricao'] = Variable<String>(descricao);
    {
      map['freeze_frame'] = Variable<String>(
        $DtcEventsTable.$converterfreezeFrame.toSql(freezeFrame),
      );
    }
    return map;
  }

  DtcEventsCompanion toCompanion(bool nullToAbsent) {
    return DtcEventsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      sessionId: Value(sessionId),
      ts: Value(ts),
      codigo: Value(codigo),
      tipo: Value(tipo),
      descricao: Value(descricao),
      freezeFrame: Value(freezeFrame),
    );
  }

  factory DtcEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DtcEvent(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      ts: serializer.fromJson<DateTime>(json['ts']),
      codigo: serializer.fromJson<String>(json['codigo']),
      tipo: serializer.fromJson<String>(json['tipo']),
      descricao: serializer.fromJson<String>(json['descricao']),
      freezeFrame: serializer.fromJson<Map<String, double>>(
        json['freezeFrame'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'sessionId': serializer.toJson<int>(sessionId),
      'ts': serializer.toJson<DateTime>(ts),
      'codigo': serializer.toJson<String>(codigo),
      'tipo': serializer.toJson<String>(tipo),
      'descricao': serializer.toJson<String>(descricao),
      'freezeFrame': serializer.toJson<Map<String, double>>(freezeFrame),
    };
  }

  DtcEvent copyWith({
    int? id,
    String? uuid,
    Value<DateTime?> syncedAt = const Value.absent(),
    int? sessionId,
    DateTime? ts,
    String? codigo,
    String? tipo,
    String? descricao,
    Map<String, double>? freezeFrame,
  }) => DtcEvent(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    sessionId: sessionId ?? this.sessionId,
    ts: ts ?? this.ts,
    codigo: codigo ?? this.codigo,
    tipo: tipo ?? this.tipo,
    descricao: descricao ?? this.descricao,
    freezeFrame: freezeFrame ?? this.freezeFrame,
  );
  DtcEvent copyWithCompanion(DtcEventsCompanion data) {
    return DtcEvent(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      ts: data.ts.present ? data.ts.value : this.ts,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      freezeFrame: data.freezeFrame.present
          ? data.freezeFrame.value
          : this.freezeFrame,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DtcEvent(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('ts: $ts, ')
          ..write('codigo: $codigo, ')
          ..write('tipo: $tipo, ')
          ..write('descricao: $descricao, ')
          ..write('freezeFrame: $freezeFrame')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    syncedAt,
    sessionId,
    ts,
    codigo,
    tipo,
    descricao,
    freezeFrame,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DtcEvent &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.syncedAt == this.syncedAt &&
          other.sessionId == this.sessionId &&
          other.ts == this.ts &&
          other.codigo == this.codigo &&
          other.tipo == this.tipo &&
          other.descricao == this.descricao &&
          other.freezeFrame == this.freezeFrame);
}

class DtcEventsCompanion extends UpdateCompanion<DtcEvent> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<DateTime?> syncedAt;
  final Value<int> sessionId;
  final Value<DateTime> ts;
  final Value<String> codigo;
  final Value<String> tipo;
  final Value<String> descricao;
  final Value<Map<String, double>> freezeFrame;
  const DtcEventsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.ts = const Value.absent(),
    this.codigo = const Value.absent(),
    this.tipo = const Value.absent(),
    this.descricao = const Value.absent(),
    this.freezeFrame = const Value.absent(),
  });
  DtcEventsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.syncedAt = const Value.absent(),
    required int sessionId,
    required DateTime ts,
    required String codigo,
    required String tipo,
    required String descricao,
    this.freezeFrame = const Value.absent(),
  }) : uuid = Value(uuid),
       sessionId = Value(sessionId),
       ts = Value(ts),
       codigo = Value(codigo),
       tipo = Value(tipo),
       descricao = Value(descricao);
  static Insertable<DtcEvent> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<DateTime>? syncedAt,
    Expression<int>? sessionId,
    Expression<DateTime>? ts,
    Expression<String>? codigo,
    Expression<String>? tipo,
    Expression<String>? descricao,
    Expression<String>? freezeFrame,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (sessionId != null) 'session_id': sessionId,
      if (ts != null) 'ts': ts,
      if (codigo != null) 'codigo': codigo,
      if (tipo != null) 'tipo': tipo,
      if (descricao != null) 'descricao': descricao,
      if (freezeFrame != null) 'freeze_frame': freezeFrame,
    });
  }

  DtcEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<DateTime?>? syncedAt,
    Value<int>? sessionId,
    Value<DateTime>? ts,
    Value<String>? codigo,
    Value<String>? tipo,
    Value<String>? descricao,
    Value<Map<String, double>>? freezeFrame,
  }) {
    return DtcEventsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      syncedAt: syncedAt ?? this.syncedAt,
      sessionId: sessionId ?? this.sessionId,
      ts: ts ?? this.ts,
      codigo: codigo ?? this.codigo,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      freezeFrame: freezeFrame ?? this.freezeFrame,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (freezeFrame.present) {
      map['freeze_frame'] = Variable<String>(
        $DtcEventsTable.$converterfreezeFrame.toSql(freezeFrame.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DtcEventsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('ts: $ts, ')
          ..write('codigo: $codigo, ')
          ..write('tipo: $tipo, ')
          ..write('descricao: $descricao, ')
          ..write('freezeFrame: $freezeFrame')
          ..write(')'))
        .toString();
  }
}

class $BaselinesTable extends Baselines
    with TableInfo<$BaselinesTable, Baseline> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BaselinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _pidKeyMeta = const VerificationMeta('pidKey');
  @override
  late final GeneratedColumn<String> pidKey = GeneratedColumn<String>(
    'pid_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextoMeta = const VerificationMeta(
    'contexto',
  );
  @override
  late final GeneratedColumn<String> contexto = GeneratedColumn<String>(
    'contexto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nMeta = const VerificationMeta('n');
  @override
  late final GeneratedColumn<int> n = GeneratedColumn<int>(
    'n',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaMeta = const VerificationMeta('media');
  @override
  late final GeneratedColumn<double> media = GeneratedColumn<double>(
    'media',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _m2Meta = const VerificationMeta('m2');
  @override
  late final GeneratedColumn<double> m2 = GeneratedColumn<double>(
    'm2',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    syncedAt,
    vehicleId,
    pidKey,
    contexto,
    n,
    media,
    m2,
    atualizadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'baselines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Baseline> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('pid_key')) {
      context.handle(
        _pidKeyMeta,
        pidKey.isAcceptableOrUnknown(data['pid_key']!, _pidKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_pidKeyMeta);
    }
    if (data.containsKey('contexto')) {
      context.handle(
        _contextoMeta,
        contexto.isAcceptableOrUnknown(data['contexto']!, _contextoMeta),
      );
    } else if (isInserting) {
      context.missing(_contextoMeta);
    }
    if (data.containsKey('n')) {
      context.handle(_nMeta, n.isAcceptableOrUnknown(data['n']!, _nMeta));
    } else if (isInserting) {
      context.missing(_nMeta);
    }
    if (data.containsKey('media')) {
      context.handle(
        _mediaMeta,
        media.isAcceptableOrUnknown(data['media']!, _mediaMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaMeta);
    }
    if (data.containsKey('m2')) {
      context.handle(_m2Meta, m2.isAcceptableOrUnknown(data['m2']!, _m2Meta));
    } else if (isInserting) {
      context.missing(_m2Meta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Baseline map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Baseline(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      pidKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pid_key'],
      )!,
      contexto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contexto'],
      )!,
      n: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n'],
      )!,
      media: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}media'],
      )!,
      m2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}m2'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
    );
  }

  @override
  $BaselinesTable createAlias(String alias) {
    return $BaselinesTable(attachedDatabase, alias);
  }
}

class Baseline extends DataClass implements Insertable<Baseline> {
  final int id;
  final String uuid;
  final DateTime? syncedAt;
  final int vehicleId;
  final String pidKey;
  final String contexto;
  final int n;
  final double media;
  final double m2;
  final DateTime atualizadoEm;
  const Baseline({
    required this.id,
    required this.uuid,
    this.syncedAt,
    required this.vehicleId,
    required this.pidKey,
    required this.contexto,
    required this.n,
    required this.media,
    required this.m2,
    required this.atualizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['pid_key'] = Variable<String>(pidKey);
    map['contexto'] = Variable<String>(contexto);
    map['n'] = Variable<int>(n);
    map['media'] = Variable<double>(media);
    map['m2'] = Variable<double>(m2);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    return map;
  }

  BaselinesCompanion toCompanion(bool nullToAbsent) {
    return BaselinesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      vehicleId: Value(vehicleId),
      pidKey: Value(pidKey),
      contexto: Value(contexto),
      n: Value(n),
      media: Value(media),
      m2: Value(m2),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory Baseline.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Baseline(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      pidKey: serializer.fromJson<String>(json['pidKey']),
      contexto: serializer.fromJson<String>(json['contexto']),
      n: serializer.fromJson<int>(json['n']),
      media: serializer.fromJson<double>(json['media']),
      m2: serializer.fromJson<double>(json['m2']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'pidKey': serializer.toJson<String>(pidKey),
      'contexto': serializer.toJson<String>(contexto),
      'n': serializer.toJson<int>(n),
      'media': serializer.toJson<double>(media),
      'm2': serializer.toJson<double>(m2),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
    };
  }

  Baseline copyWith({
    int? id,
    String? uuid,
    Value<DateTime?> syncedAt = const Value.absent(),
    int? vehicleId,
    String? pidKey,
    String? contexto,
    int? n,
    double? media,
    double? m2,
    DateTime? atualizadoEm,
  }) => Baseline(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    vehicleId: vehicleId ?? this.vehicleId,
    pidKey: pidKey ?? this.pidKey,
    contexto: contexto ?? this.contexto,
    n: n ?? this.n,
    media: media ?? this.media,
    m2: m2 ?? this.m2,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
  );
  Baseline copyWithCompanion(BaselinesCompanion data) {
    return Baseline(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      pidKey: data.pidKey.present ? data.pidKey.value : this.pidKey,
      contexto: data.contexto.present ? data.contexto.value : this.contexto,
      n: data.n.present ? data.n.value : this.n,
      media: data.media.present ? data.media.value : this.media,
      m2: data.m2.present ? data.m2.value : this.m2,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Baseline(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('pidKey: $pidKey, ')
          ..write('contexto: $contexto, ')
          ..write('n: $n, ')
          ..write('media: $media, ')
          ..write('m2: $m2, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    syncedAt,
    vehicleId,
    pidKey,
    contexto,
    n,
    media,
    m2,
    atualizadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Baseline &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.syncedAt == this.syncedAt &&
          other.vehicleId == this.vehicleId &&
          other.pidKey == this.pidKey &&
          other.contexto == this.contexto &&
          other.n == this.n &&
          other.media == this.media &&
          other.m2 == this.m2 &&
          other.atualizadoEm == this.atualizadoEm);
}

class BaselinesCompanion extends UpdateCompanion<Baseline> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<DateTime?> syncedAt;
  final Value<int> vehicleId;
  final Value<String> pidKey;
  final Value<String> contexto;
  final Value<int> n;
  final Value<double> media;
  final Value<double> m2;
  final Value<DateTime> atualizadoEm;
  const BaselinesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.pidKey = const Value.absent(),
    this.contexto = const Value.absent(),
    this.n = const Value.absent(),
    this.media = const Value.absent(),
    this.m2 = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
  });
  BaselinesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.syncedAt = const Value.absent(),
    required int vehicleId,
    required String pidKey,
    required String contexto,
    required int n,
    required double media,
    required double m2,
    required DateTime atualizadoEm,
  }) : uuid = Value(uuid),
       vehicleId = Value(vehicleId),
       pidKey = Value(pidKey),
       contexto = Value(contexto),
       n = Value(n),
       media = Value(media),
       m2 = Value(m2),
       atualizadoEm = Value(atualizadoEm);
  static Insertable<Baseline> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<DateTime>? syncedAt,
    Expression<int>? vehicleId,
    Expression<String>? pidKey,
    Expression<String>? contexto,
    Expression<int>? n,
    Expression<double>? media,
    Expression<double>? m2,
    Expression<DateTime>? atualizadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (pidKey != null) 'pid_key': pidKey,
      if (contexto != null) 'contexto': contexto,
      if (n != null) 'n': n,
      if (media != null) 'media': media,
      if (m2 != null) 'm2': m2,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
    });
  }

  BaselinesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<DateTime?>? syncedAt,
    Value<int>? vehicleId,
    Value<String>? pidKey,
    Value<String>? contexto,
    Value<int>? n,
    Value<double>? media,
    Value<double>? m2,
    Value<DateTime>? atualizadoEm,
  }) {
    return BaselinesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      syncedAt: syncedAt ?? this.syncedAt,
      vehicleId: vehicleId ?? this.vehicleId,
      pidKey: pidKey ?? this.pidKey,
      contexto: contexto ?? this.contexto,
      n: n ?? this.n,
      media: media ?? this.media,
      m2: m2 ?? this.m2,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (pidKey.present) {
      map['pid_key'] = Variable<String>(pidKey.value);
    }
    if (contexto.present) {
      map['contexto'] = Variable<String>(contexto.value);
    }
    if (n.present) {
      map['n'] = Variable<int>(n.value);
    }
    if (media.present) {
      map['media'] = Variable<double>(media.value);
    }
    if (m2.present) {
      map['m2'] = Variable<double>(m2.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BaselinesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('pidKey: $pidKey, ')
          ..write('contexto: $contexto, ')
          ..write('n: $n, ')
          ..write('media: $media, ')
          ..write('m2: $m2, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }
}

class $AnomaliesTable extends Anomalies
    with TableInfo<$AnomaliesTable, Anomaly> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnomaliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pidKeyMeta = const VerificationMeta('pidKey');
  @override
  late final GeneratedColumn<String> pidKey = GeneratedColumn<String>(
    'pid_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextoMeta = const VerificationMeta(
    'contexto',
  );
  @override
  late final GeneratedColumn<String> contexto = GeneratedColumn<String>(
    'contexto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaEsperadaMeta = const VerificationMeta(
    'mediaEsperada',
  );
  @override
  late final GeneratedColumn<double> mediaEsperada = GeneratedColumn<double>(
    'media_esperada',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _desvioPadraoMeta = const VerificationMeta(
    'desvioPadrao',
  );
  @override
  late final GeneratedColumn<double> desvioPadrao = GeneratedColumn<double>(
    'desvio_padrao',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zMeta = const VerificationMeta('z');
  @override
  late final GeneratedColumn<double> z = GeneratedColumn<double>(
    'z',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severidadeMeta = const VerificationMeta(
    'severidade',
  );
  @override
  late final GeneratedColumn<String> severidade = GeneratedColumn<String>(
    'severidade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    syncedAt,
    sessionId,
    ts,
    pidKey,
    contexto,
    valor,
    mediaEsperada,
    desvioPadrao,
    z,
    severidade,
    tipo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anomalies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Anomaly> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('pid_key')) {
      context.handle(
        _pidKeyMeta,
        pidKey.isAcceptableOrUnknown(data['pid_key']!, _pidKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_pidKeyMeta);
    }
    if (data.containsKey('contexto')) {
      context.handle(
        _contextoMeta,
        contexto.isAcceptableOrUnknown(data['contexto']!, _contextoMeta),
      );
    } else if (isInserting) {
      context.missing(_contextoMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('media_esperada')) {
      context.handle(
        _mediaEsperadaMeta,
        mediaEsperada.isAcceptableOrUnknown(
          data['media_esperada']!,
          _mediaEsperadaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaEsperadaMeta);
    }
    if (data.containsKey('desvio_padrao')) {
      context.handle(
        _desvioPadraoMeta,
        desvioPadrao.isAcceptableOrUnknown(
          data['desvio_padrao']!,
          _desvioPadraoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_desvioPadraoMeta);
    }
    if (data.containsKey('z')) {
      context.handle(_zMeta, z.isAcceptableOrUnknown(data['z']!, _zMeta));
    } else if (isInserting) {
      context.missing(_zMeta);
    }
    if (data.containsKey('severidade')) {
      context.handle(
        _severidadeMeta,
        severidade.isAcceptableOrUnknown(data['severidade']!, _severidadeMeta),
      );
    } else if (isInserting) {
      context.missing(_severidadeMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Anomaly map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Anomaly(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ts'],
      )!,
      pidKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pid_key'],
      )!,
      contexto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contexto'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      )!,
      mediaEsperada: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}media_esperada'],
      )!,
      desvioPadrao: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}desvio_padrao'],
      )!,
      z: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}z'],
      )!,
      severidade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severidade'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
    );
  }

  @override
  $AnomaliesTable createAlias(String alias) {
    return $AnomaliesTable(attachedDatabase, alias);
  }
}

class Anomaly extends DataClass implements Insertable<Anomaly> {
  final int id;
  final String uuid;
  final DateTime? syncedAt;
  final int sessionId;
  final DateTime ts;
  final String pidKey;
  final String contexto;
  final double valor;
  final double mediaEsperada;
  final double desvioPadrao;
  final double z;
  final String severidade;
  final String tipo;
  const Anomaly({
    required this.id,
    required this.uuid,
    this.syncedAt,
    required this.sessionId,
    required this.ts,
    required this.pidKey,
    required this.contexto,
    required this.valor,
    required this.mediaEsperada,
    required this.desvioPadrao,
    required this.z,
    required this.severidade,
    required this.tipo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['session_id'] = Variable<int>(sessionId);
    map['ts'] = Variable<DateTime>(ts);
    map['pid_key'] = Variable<String>(pidKey);
    map['contexto'] = Variable<String>(contexto);
    map['valor'] = Variable<double>(valor);
    map['media_esperada'] = Variable<double>(mediaEsperada);
    map['desvio_padrao'] = Variable<double>(desvioPadrao);
    map['z'] = Variable<double>(z);
    map['severidade'] = Variable<String>(severidade);
    map['tipo'] = Variable<String>(tipo);
    return map;
  }

  AnomaliesCompanion toCompanion(bool nullToAbsent) {
    return AnomaliesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      sessionId: Value(sessionId),
      ts: Value(ts),
      pidKey: Value(pidKey),
      contexto: Value(contexto),
      valor: Value(valor),
      mediaEsperada: Value(mediaEsperada),
      desvioPadrao: Value(desvioPadrao),
      z: Value(z),
      severidade: Value(severidade),
      tipo: Value(tipo),
    );
  }

  factory Anomaly.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Anomaly(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      ts: serializer.fromJson<DateTime>(json['ts']),
      pidKey: serializer.fromJson<String>(json['pidKey']),
      contexto: serializer.fromJson<String>(json['contexto']),
      valor: serializer.fromJson<double>(json['valor']),
      mediaEsperada: serializer.fromJson<double>(json['mediaEsperada']),
      desvioPadrao: serializer.fromJson<double>(json['desvioPadrao']),
      z: serializer.fromJson<double>(json['z']),
      severidade: serializer.fromJson<String>(json['severidade']),
      tipo: serializer.fromJson<String>(json['tipo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'sessionId': serializer.toJson<int>(sessionId),
      'ts': serializer.toJson<DateTime>(ts),
      'pidKey': serializer.toJson<String>(pidKey),
      'contexto': serializer.toJson<String>(contexto),
      'valor': serializer.toJson<double>(valor),
      'mediaEsperada': serializer.toJson<double>(mediaEsperada),
      'desvioPadrao': serializer.toJson<double>(desvioPadrao),
      'z': serializer.toJson<double>(z),
      'severidade': serializer.toJson<String>(severidade),
      'tipo': serializer.toJson<String>(tipo),
    };
  }

  Anomaly copyWith({
    int? id,
    String? uuid,
    Value<DateTime?> syncedAt = const Value.absent(),
    int? sessionId,
    DateTime? ts,
    String? pidKey,
    String? contexto,
    double? valor,
    double? mediaEsperada,
    double? desvioPadrao,
    double? z,
    String? severidade,
    String? tipo,
  }) => Anomaly(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    sessionId: sessionId ?? this.sessionId,
    ts: ts ?? this.ts,
    pidKey: pidKey ?? this.pidKey,
    contexto: contexto ?? this.contexto,
    valor: valor ?? this.valor,
    mediaEsperada: mediaEsperada ?? this.mediaEsperada,
    desvioPadrao: desvioPadrao ?? this.desvioPadrao,
    z: z ?? this.z,
    severidade: severidade ?? this.severidade,
    tipo: tipo ?? this.tipo,
  );
  Anomaly copyWithCompanion(AnomaliesCompanion data) {
    return Anomaly(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      ts: data.ts.present ? data.ts.value : this.ts,
      pidKey: data.pidKey.present ? data.pidKey.value : this.pidKey,
      contexto: data.contexto.present ? data.contexto.value : this.contexto,
      valor: data.valor.present ? data.valor.value : this.valor,
      mediaEsperada: data.mediaEsperada.present
          ? data.mediaEsperada.value
          : this.mediaEsperada,
      desvioPadrao: data.desvioPadrao.present
          ? data.desvioPadrao.value
          : this.desvioPadrao,
      z: data.z.present ? data.z.value : this.z,
      severidade: data.severidade.present
          ? data.severidade.value
          : this.severidade,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Anomaly(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('ts: $ts, ')
          ..write('pidKey: $pidKey, ')
          ..write('contexto: $contexto, ')
          ..write('valor: $valor, ')
          ..write('mediaEsperada: $mediaEsperada, ')
          ..write('desvioPadrao: $desvioPadrao, ')
          ..write('z: $z, ')
          ..write('severidade: $severidade, ')
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    syncedAt,
    sessionId,
    ts,
    pidKey,
    contexto,
    valor,
    mediaEsperada,
    desvioPadrao,
    z,
    severidade,
    tipo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Anomaly &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.syncedAt == this.syncedAt &&
          other.sessionId == this.sessionId &&
          other.ts == this.ts &&
          other.pidKey == this.pidKey &&
          other.contexto == this.contexto &&
          other.valor == this.valor &&
          other.mediaEsperada == this.mediaEsperada &&
          other.desvioPadrao == this.desvioPadrao &&
          other.z == this.z &&
          other.severidade == this.severidade &&
          other.tipo == this.tipo);
}

class AnomaliesCompanion extends UpdateCompanion<Anomaly> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<DateTime?> syncedAt;
  final Value<int> sessionId;
  final Value<DateTime> ts;
  final Value<String> pidKey;
  final Value<String> contexto;
  final Value<double> valor;
  final Value<double> mediaEsperada;
  final Value<double> desvioPadrao;
  final Value<double> z;
  final Value<String> severidade;
  final Value<String> tipo;
  const AnomaliesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.ts = const Value.absent(),
    this.pidKey = const Value.absent(),
    this.contexto = const Value.absent(),
    this.valor = const Value.absent(),
    this.mediaEsperada = const Value.absent(),
    this.desvioPadrao = const Value.absent(),
    this.z = const Value.absent(),
    this.severidade = const Value.absent(),
    this.tipo = const Value.absent(),
  });
  AnomaliesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.syncedAt = const Value.absent(),
    required int sessionId,
    required DateTime ts,
    required String pidKey,
    required String contexto,
    required double valor,
    required double mediaEsperada,
    required double desvioPadrao,
    required double z,
    required String severidade,
    required String tipo,
  }) : uuid = Value(uuid),
       sessionId = Value(sessionId),
       ts = Value(ts),
       pidKey = Value(pidKey),
       contexto = Value(contexto),
       valor = Value(valor),
       mediaEsperada = Value(mediaEsperada),
       desvioPadrao = Value(desvioPadrao),
       z = Value(z),
       severidade = Value(severidade),
       tipo = Value(tipo);
  static Insertable<Anomaly> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<DateTime>? syncedAt,
    Expression<int>? sessionId,
    Expression<DateTime>? ts,
    Expression<String>? pidKey,
    Expression<String>? contexto,
    Expression<double>? valor,
    Expression<double>? mediaEsperada,
    Expression<double>? desvioPadrao,
    Expression<double>? z,
    Expression<String>? severidade,
    Expression<String>? tipo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (sessionId != null) 'session_id': sessionId,
      if (ts != null) 'ts': ts,
      if (pidKey != null) 'pid_key': pidKey,
      if (contexto != null) 'contexto': contexto,
      if (valor != null) 'valor': valor,
      if (mediaEsperada != null) 'media_esperada': mediaEsperada,
      if (desvioPadrao != null) 'desvio_padrao': desvioPadrao,
      if (z != null) 'z': z,
      if (severidade != null) 'severidade': severidade,
      if (tipo != null) 'tipo': tipo,
    });
  }

  AnomaliesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<DateTime?>? syncedAt,
    Value<int>? sessionId,
    Value<DateTime>? ts,
    Value<String>? pidKey,
    Value<String>? contexto,
    Value<double>? valor,
    Value<double>? mediaEsperada,
    Value<double>? desvioPadrao,
    Value<double>? z,
    Value<String>? severidade,
    Value<String>? tipo,
  }) {
    return AnomaliesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      syncedAt: syncedAt ?? this.syncedAt,
      sessionId: sessionId ?? this.sessionId,
      ts: ts ?? this.ts,
      pidKey: pidKey ?? this.pidKey,
      contexto: contexto ?? this.contexto,
      valor: valor ?? this.valor,
      mediaEsperada: mediaEsperada ?? this.mediaEsperada,
      desvioPadrao: desvioPadrao ?? this.desvioPadrao,
      z: z ?? this.z,
      severidade: severidade ?? this.severidade,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (pidKey.present) {
      map['pid_key'] = Variable<String>(pidKey.value);
    }
    if (contexto.present) {
      map['contexto'] = Variable<String>(contexto.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (mediaEsperada.present) {
      map['media_esperada'] = Variable<double>(mediaEsperada.value);
    }
    if (desvioPadrao.present) {
      map['desvio_padrao'] = Variable<double>(desvioPadrao.value);
    }
    if (z.present) {
      map['z'] = Variable<double>(z.value);
    }
    if (severidade.present) {
      map['severidade'] = Variable<String>(severidade.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnomaliesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('ts: $ts, ')
          ..write('pidKey: $pidKey, ')
          ..write('contexto: $contexto, ')
          ..write('valor: $valor, ')
          ..write('mediaEsperada: $mediaEsperada, ')
          ..write('desvioPadrao: $desvioPadrao, ')
          ..write('z: $z, ')
          ..write('severidade: $severidade, ')
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }
}

class $TrendWatchesTable extends TrendWatches
    with TableInfo<$TrendWatchesTable, TrendWatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrendWatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _pidKeyMeta = const VerificationMeta('pidKey');
  @override
  late final GeneratedColumn<String> pidKey = GeneratedColumn<String>(
    'pid_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextoMeta = const VerificationMeta(
    'contexto',
  );
  @override
  late final GeneratedColumn<String> contexto = GeneratedColumn<String>(
    'contexto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consecutiveDeviatedSessionsMeta =
      const VerificationMeta('consecutiveDeviatedSessions');
  @override
  late final GeneratedColumn<int> consecutiveDeviatedSessions =
      GeneratedColumn<int>(
        'consecutive_deviated_sessions',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _lastSessionIdMeta = const VerificationMeta(
    'lastSessionId',
  );
  @override
  late final GeneratedColumn<int> lastSessionId = GeneratedColumn<int>(
    'last_session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    syncedAt,
    vehicleId,
    pidKey,
    contexto,
    consecutiveDeviatedSessions,
    lastSessionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trend_watches';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrendWatch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('pid_key')) {
      context.handle(
        _pidKeyMeta,
        pidKey.isAcceptableOrUnknown(data['pid_key']!, _pidKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_pidKeyMeta);
    }
    if (data.containsKey('contexto')) {
      context.handle(
        _contextoMeta,
        contexto.isAcceptableOrUnknown(data['contexto']!, _contextoMeta),
      );
    } else if (isInserting) {
      context.missing(_contextoMeta);
    }
    if (data.containsKey('consecutive_deviated_sessions')) {
      context.handle(
        _consecutiveDeviatedSessionsMeta,
        consecutiveDeviatedSessions.isAcceptableOrUnknown(
          data['consecutive_deviated_sessions']!,
          _consecutiveDeviatedSessionsMeta,
        ),
      );
    }
    if (data.containsKey('last_session_id')) {
      context.handle(
        _lastSessionIdMeta,
        lastSessionId.isAcceptableOrUnknown(
          data['last_session_id']!,
          _lastSessionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrendWatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrendWatch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      pidKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pid_key'],
      )!,
      contexto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contexto'],
      )!,
      consecutiveDeviatedSessions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consecutive_deviated_sessions'],
      )!,
      lastSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_session_id'],
      ),
    );
  }

  @override
  $TrendWatchesTable createAlias(String alias) {
    return $TrendWatchesTable(attachedDatabase, alias);
  }
}

class TrendWatch extends DataClass implements Insertable<TrendWatch> {
  final int id;
  final String uuid;
  final DateTime? syncedAt;
  final int vehicleId;
  final String pidKey;
  final String contexto;
  final int consecutiveDeviatedSessions;
  final int? lastSessionId;
  const TrendWatch({
    required this.id,
    required this.uuid,
    this.syncedAt,
    required this.vehicleId,
    required this.pidKey,
    required this.contexto,
    required this.consecutiveDeviatedSessions,
    this.lastSessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['pid_key'] = Variable<String>(pidKey);
    map['contexto'] = Variable<String>(contexto);
    map['consecutive_deviated_sessions'] = Variable<int>(
      consecutiveDeviatedSessions,
    );
    if (!nullToAbsent || lastSessionId != null) {
      map['last_session_id'] = Variable<int>(lastSessionId);
    }
    return map;
  }

  TrendWatchesCompanion toCompanion(bool nullToAbsent) {
    return TrendWatchesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      vehicleId: Value(vehicleId),
      pidKey: Value(pidKey),
      contexto: Value(contexto),
      consecutiveDeviatedSessions: Value(consecutiveDeviatedSessions),
      lastSessionId: lastSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSessionId),
    );
  }

  factory TrendWatch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrendWatch(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      pidKey: serializer.fromJson<String>(json['pidKey']),
      contexto: serializer.fromJson<String>(json['contexto']),
      consecutiveDeviatedSessions: serializer.fromJson<int>(
        json['consecutiveDeviatedSessions'],
      ),
      lastSessionId: serializer.fromJson<int?>(json['lastSessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'pidKey': serializer.toJson<String>(pidKey),
      'contexto': serializer.toJson<String>(contexto),
      'consecutiveDeviatedSessions': serializer.toJson<int>(
        consecutiveDeviatedSessions,
      ),
      'lastSessionId': serializer.toJson<int?>(lastSessionId),
    };
  }

  TrendWatch copyWith({
    int? id,
    String? uuid,
    Value<DateTime?> syncedAt = const Value.absent(),
    int? vehicleId,
    String? pidKey,
    String? contexto,
    int? consecutiveDeviatedSessions,
    Value<int?> lastSessionId = const Value.absent(),
  }) => TrendWatch(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    vehicleId: vehicleId ?? this.vehicleId,
    pidKey: pidKey ?? this.pidKey,
    contexto: contexto ?? this.contexto,
    consecutiveDeviatedSessions:
        consecutiveDeviatedSessions ?? this.consecutiveDeviatedSessions,
    lastSessionId: lastSessionId.present
        ? lastSessionId.value
        : this.lastSessionId,
  );
  TrendWatch copyWithCompanion(TrendWatchesCompanion data) {
    return TrendWatch(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      pidKey: data.pidKey.present ? data.pidKey.value : this.pidKey,
      contexto: data.contexto.present ? data.contexto.value : this.contexto,
      consecutiveDeviatedSessions: data.consecutiveDeviatedSessions.present
          ? data.consecutiveDeviatedSessions.value
          : this.consecutiveDeviatedSessions,
      lastSessionId: data.lastSessionId.present
          ? data.lastSessionId.value
          : this.lastSessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrendWatch(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('pidKey: $pidKey, ')
          ..write('contexto: $contexto, ')
          ..write('consecutiveDeviatedSessions: $consecutiveDeviatedSessions, ')
          ..write('lastSessionId: $lastSessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    syncedAt,
    vehicleId,
    pidKey,
    contexto,
    consecutiveDeviatedSessions,
    lastSessionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrendWatch &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.syncedAt == this.syncedAt &&
          other.vehicleId == this.vehicleId &&
          other.pidKey == this.pidKey &&
          other.contexto == this.contexto &&
          other.consecutiveDeviatedSessions ==
              this.consecutiveDeviatedSessions &&
          other.lastSessionId == this.lastSessionId);
}

class TrendWatchesCompanion extends UpdateCompanion<TrendWatch> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<DateTime?> syncedAt;
  final Value<int> vehicleId;
  final Value<String> pidKey;
  final Value<String> contexto;
  final Value<int> consecutiveDeviatedSessions;
  final Value<int?> lastSessionId;
  const TrendWatchesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.pidKey = const Value.absent(),
    this.contexto = const Value.absent(),
    this.consecutiveDeviatedSessions = const Value.absent(),
    this.lastSessionId = const Value.absent(),
  });
  TrendWatchesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.syncedAt = const Value.absent(),
    required int vehicleId,
    required String pidKey,
    required String contexto,
    this.consecutiveDeviatedSessions = const Value.absent(),
    this.lastSessionId = const Value.absent(),
  }) : uuid = Value(uuid),
       vehicleId = Value(vehicleId),
       pidKey = Value(pidKey),
       contexto = Value(contexto);
  static Insertable<TrendWatch> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<DateTime>? syncedAt,
    Expression<int>? vehicleId,
    Expression<String>? pidKey,
    Expression<String>? contexto,
    Expression<int>? consecutiveDeviatedSessions,
    Expression<int>? lastSessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (pidKey != null) 'pid_key': pidKey,
      if (contexto != null) 'contexto': contexto,
      if (consecutiveDeviatedSessions != null)
        'consecutive_deviated_sessions': consecutiveDeviatedSessions,
      if (lastSessionId != null) 'last_session_id': lastSessionId,
    });
  }

  TrendWatchesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<DateTime?>? syncedAt,
    Value<int>? vehicleId,
    Value<String>? pidKey,
    Value<String>? contexto,
    Value<int>? consecutiveDeviatedSessions,
    Value<int?>? lastSessionId,
  }) {
    return TrendWatchesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      syncedAt: syncedAt ?? this.syncedAt,
      vehicleId: vehicleId ?? this.vehicleId,
      pidKey: pidKey ?? this.pidKey,
      contexto: contexto ?? this.contexto,
      consecutiveDeviatedSessions:
          consecutiveDeviatedSessions ?? this.consecutiveDeviatedSessions,
      lastSessionId: lastSessionId ?? this.lastSessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (pidKey.present) {
      map['pid_key'] = Variable<String>(pidKey.value);
    }
    if (contexto.present) {
      map['contexto'] = Variable<String>(contexto.value);
    }
    if (consecutiveDeviatedSessions.present) {
      map['consecutive_deviated_sessions'] = Variable<int>(
        consecutiveDeviatedSessions.value,
      );
    }
    if (lastSessionId.present) {
      map['last_session_id'] = Variable<int>(lastSessionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrendWatchesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('pidKey: $pidKey, ')
          ..write('contexto: $contexto, ')
          ..write('consecutiveDeviatedSessions: $consecutiveDeviatedSessions, ')
          ..write('lastSessionId: $lastSessionId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $ReadingsTable readings = $ReadingsTable(this);
  late final $RawFramesTable rawFrames = $RawFramesTable(this);
  late final $DtcEventsTable dtcEvents = $DtcEventsTable(this);
  late final $BaselinesTable baselines = $BaselinesTable(this);
  late final $AnomaliesTable anomalies = $AnomaliesTable(this);
  late final $TrendWatchesTable trendWatches = $TrendWatchesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehicles,
    sessions,
    readings,
    rawFrames,
    dtcEvents,
    baselines,
    anomalies,
    trendWatches,
  ];
}

typedef $$VehiclesTableCreateCompanionBuilder = VehiclesCompanion Function({
  Value<int> id,
  required String uuid,
  Value<DateTime?> syncedAt,
  required String vin,
  required String apelido,
  required String modelo,
  required int ano,
  required double cilindradaL,
  required String tipoCombustivel,
  Value<List<int>> pidsSuportados,
});
typedef $$VehiclesTableUpdateCompanionBuilder = VehiclesCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<DateTime?> syncedAt,
  Value<String> vin,
  Value<String> apelido,
  Value<String> modelo,
  Value<int> ano,
  Value<double> cilindradaL,
  Value<String> tipoCombustivel,
  Value<List<int>> pidsSuportados,
});

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'vehicles__id__sessions__vehicle_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BaselinesTable, List<Baseline>>
  _baselinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.baselines,
    aliasName: 'vehicles__id__baselines__vehicle_id',
  );

  $$BaselinesTableProcessedTableManager get baselinesRefs {
    final manager = $$BaselinesTableTableManager(
      $_db,
      $_db.baselines,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_baselinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TrendWatchesTable, List<TrendWatch>>
  _trendWatchesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trendWatches,
    aliasName: 'vehicles__id__trend_watches__vehicle_id',
  );

  $$TrendWatchesTableProcessedTableManager get trendWatchesRefs {
    final manager = $$TrendWatchesTableTableManager(
      $_db,
      $_db.trendWatches,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_trendWatchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apelido => $composableBuilder(
    column: $table.apelido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelo => $composableBuilder(
    column: $table.modelo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ano => $composableBuilder(
    column: $table.ano,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cilindradaL => $composableBuilder(
    column: $table.cilindradaL,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoCombustivel => $composableBuilder(
    column: $table.tipoCombustivel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String>
  get pidsSuportados => $composableBuilder(
    column: $table.pidsSuportados,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> baselinesRefs(
    Expression<bool> Function($$BaselinesTableFilterComposer f) f,
  ) {
    final $$BaselinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.baselines,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BaselinesTableFilterComposer(
            $db: $db,
            $table: $db.baselines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> trendWatchesRefs(
    Expression<bool> Function($$TrendWatchesTableFilterComposer f) f,
  ) {
    final $$TrendWatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trendWatches,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrendWatchesTableFilterComposer(
            $db: $db,
            $table: $db.trendWatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apelido => $composableBuilder(
    column: $table.apelido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelo => $composableBuilder(
    column: $table.modelo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ano => $composableBuilder(
    column: $table.ano,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cilindradaL => $composableBuilder(
    column: $table.cilindradaL,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoCombustivel => $composableBuilder(
    column: $table.tipoCombustivel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pidsSuportados => $composableBuilder(
    column: $table.pidsSuportados,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get vin =>
      $composableBuilder(column: $table.vin, builder: (column) => column);

  GeneratedColumn<String> get apelido =>
      $composableBuilder(column: $table.apelido, builder: (column) => column);

  GeneratedColumn<String> get modelo =>
      $composableBuilder(column: $table.modelo, builder: (column) => column);

  GeneratedColumn<int> get ano =>
      $composableBuilder(column: $table.ano, builder: (column) => column);

  GeneratedColumn<double> get cilindradaL => $composableBuilder(
    column: $table.cilindradaL,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoCombustivel => $composableBuilder(
    column: $table.tipoCombustivel,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<int>, String> get pidsSuportados =>
      $composableBuilder(
        column: $table.pidsSuportados,
        builder: (column) => column,
      );

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> baselinesRefs<T extends Object>(
    Expression<T> Function($$BaselinesTableAnnotationComposer a) f,
  ) {
    final $$BaselinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.baselines,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BaselinesTableAnnotationComposer(
            $db: $db,
            $table: $db.baselines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> trendWatchesRefs<T extends Object>(
    Expression<T> Function($$TrendWatchesTableAnnotationComposer a) f,
  ) {
    final $$TrendWatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trendWatches,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrendWatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.trendWatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, $$VehiclesTableReferences),
          Vehicle,
          PrefetchHooks Function({
            bool sessionsRefs,
            bool baselinesRefs,
            bool trendWatchesRefs,
          })
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String> vin = const Value.absent(),
                Value<String> apelido = const Value.absent(),
                Value<String> modelo = const Value.absent(),
                Value<int> ano = const Value.absent(),
                Value<double> cilindradaL = const Value.absent(),
                Value<String> tipoCombustivel = const Value.absent(),
                Value<List<int>> pidsSuportados = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                vin: vin,
                apelido: apelido,
                modelo: modelo,
                ano: ano,
                cilindradaL: cilindradaL,
                tipoCombustivel: tipoCombustivel,
                pidsSuportados: pidsSuportados,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                Value<DateTime?> syncedAt = const Value.absent(),
                required String vin,
                required String apelido,
                required String modelo,
                required int ano,
                required double cilindradaL,
                required String tipoCombustivel,
                Value<List<int>> pidsSuportados = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                vin: vin,
                apelido: apelido,
                modelo: modelo,
                ano: ano,
                cilindradaL: cilindradaL,
                tipoCombustivel: tipoCombustivel,
                pidsSuportados: pidsSuportados,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionsRefs = false,
                baselinesRefs = false,
                trendWatchesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionsRefs) db.sessions,
                    if (baselinesRefs) db.baselines,
                    if (trendWatchesRefs) db.trendWatches,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionsRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          Session
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (baselinesRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          Baseline
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._baselinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).baselinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trendWatchesRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          TrendWatch
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._trendWatchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).trendWatchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, $$VehiclesTableReferences),
      Vehicle,
      PrefetchHooks Function({
        bool sessionsRefs,
        bool baselinesRefs,
        bool trendWatchesRefs,
      })
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required String uuid,
  Value<DateTime?> syncedAt,
  required int vehicleId,
  required DateTime iniciadaEm,
  Value<DateTime?> encerradaEm,
  required String protocolo,
  required String adaptador,
  required String origem,
  Value<double?> distanciaKm,
  Value<int?> duracaoS,
  Value<double?> consumoMedioKml,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<DateTime?> syncedAt,
  Value<int> vehicleId,
  Value<DateTime> iniciadaEm,
  Value<DateTime?> encerradaEm,
  Value<String> protocolo,
  Value<String> adaptador,
  Value<String> origem,
  Value<double?> distanciaKm,
  Value<int?> duracaoS,
  Value<double?> consumoMedioKml,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('sessions__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReadingsTable, List<Reading>> _readingsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.readings,
    aliasName: 'sessions__id__readings__session_id',
  );

  $$ReadingsTableProcessedTableManager get readingsRefs {
    final manager = $$ReadingsTableTableManager(
      $_db,
      $_db.readings,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RawFramesTable, List<RawFrame>>
  _rawFramesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rawFrames,
    aliasName: 'sessions__id__raw_frames__session_id',
  );

  $$RawFramesTableProcessedTableManager get rawFramesRefs {
    final manager = $$RawFramesTableTableManager(
      $_db,
      $_db.rawFrames,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rawFramesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DtcEventsTable, List<DtcEvent>>
  _dtcEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dtcEvents,
    aliasName: 'sessions__id__dtc_events__session_id',
  );

  $$DtcEventsTableProcessedTableManager get dtcEventsRefs {
    final manager = $$DtcEventsTableTableManager(
      $_db,
      $_db.dtcEvents,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dtcEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AnomaliesTable, List<Anomaly>>
  _anomaliesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.anomalies,
    aliasName: 'sessions__id__anomalies__session_id',
  );

  $$AnomaliesTableProcessedTableManager get anomaliesRefs {
    final manager = $$AnomaliesTableTableManager(
      $_db,
      $_db.anomalies,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_anomaliesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get iniciadaEm => $composableBuilder(
    column: $table.iniciadaEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get encerradaEm => $composableBuilder(
    column: $table.encerradaEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protocolo => $composableBuilder(
    column: $table.protocolo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adaptador => $composableBuilder(
    column: $table.adaptador,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanciaKm => $composableBuilder(
    column: $table.distanciaKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duracaoS => $composableBuilder(
    column: $table.duracaoS,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get consumoMedioKml => $composableBuilder(
    column: $table.consumoMedioKml,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> readingsRefs(
    Expression<bool> Function($$ReadingsTableFilterComposer f) f,
  ) {
    final $$ReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readings,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingsTableFilterComposer(
            $db: $db,
            $table: $db.readings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rawFramesRefs(
    Expression<bool> Function($$RawFramesTableFilterComposer f) f,
  ) {
    final $$RawFramesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rawFrames,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RawFramesTableFilterComposer(
            $db: $db,
            $table: $db.rawFrames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dtcEventsRefs(
    Expression<bool> Function($$DtcEventsTableFilterComposer f) f,
  ) {
    final $$DtcEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dtcEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DtcEventsTableFilterComposer(
            $db: $db,
            $table: $db.dtcEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> anomaliesRefs(
    Expression<bool> Function($$AnomaliesTableFilterComposer f) f,
  ) {
    final $$AnomaliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.anomalies,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnomaliesTableFilterComposer(
            $db: $db,
            $table: $db.anomalies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get iniciadaEm => $composableBuilder(
    column: $table.iniciadaEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get encerradaEm => $composableBuilder(
    column: $table.encerradaEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocolo => $composableBuilder(
    column: $table.protocolo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adaptador => $composableBuilder(
    column: $table.adaptador,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanciaKm => $composableBuilder(
    column: $table.distanciaKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duracaoS => $composableBuilder(
    column: $table.duracaoS,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get consumoMedioKml => $composableBuilder(
    column: $table.consumoMedioKml,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get iniciadaEm => $composableBuilder(
    column: $table.iniciadaEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get encerradaEm => $composableBuilder(
    column: $table.encerradaEm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get protocolo =>
      $composableBuilder(column: $table.protocolo, builder: (column) => column);

  GeneratedColumn<String> get adaptador =>
      $composableBuilder(column: $table.adaptador, builder: (column) => column);

  GeneratedColumn<String> get origem =>
      $composableBuilder(column: $table.origem, builder: (column) => column);

  GeneratedColumn<double> get distanciaKm => $composableBuilder(
    column: $table.distanciaKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duracaoS =>
      $composableBuilder(column: $table.duracaoS, builder: (column) => column);

  GeneratedColumn<double> get consumoMedioKml => $composableBuilder(
    column: $table.consumoMedioKml,
    builder: (column) => column,
  );

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> readingsRefs<T extends Object>(
    Expression<T> Function($$ReadingsTableAnnotationComposer a) f,
  ) {
    final $$ReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readings,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.readings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rawFramesRefs<T extends Object>(
    Expression<T> Function($$RawFramesTableAnnotationComposer a) f,
  ) {
    final $$RawFramesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rawFrames,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RawFramesTableAnnotationComposer(
            $db: $db,
            $table: $db.rawFrames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dtcEventsRefs<T extends Object>(
    Expression<T> Function($$DtcEventsTableAnnotationComposer a) f,
  ) {
    final $$DtcEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dtcEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DtcEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.dtcEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> anomaliesRefs<T extends Object>(
    Expression<T> Function($$AnomaliesTableAnnotationComposer a) f,
  ) {
    final $$AnomaliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.anomalies,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnomaliesTableAnnotationComposer(
            $db: $db,
            $table: $db.anomalies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({
            bool vehicleId,
            bool readingsRefs,
            bool rawFramesRefs,
            bool dtcEventsRefs,
            bool anomaliesRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<DateTime> iniciadaEm = const Value.absent(),
                Value<DateTime?> encerradaEm = const Value.absent(),
                Value<String> protocolo = const Value.absent(),
                Value<String> adaptador = const Value.absent(),
                Value<String> origem = const Value.absent(),
                Value<double?> distanciaKm = const Value.absent(),
                Value<int?> duracaoS = const Value.absent(),
                Value<double?> consumoMedioKml = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                vehicleId: vehicleId,
                iniciadaEm: iniciadaEm,
                encerradaEm: encerradaEm,
                protocolo: protocolo,
                adaptador: adaptador,
                origem: origem,
                distanciaKm: distanciaKm,
                duracaoS: duracaoS,
                consumoMedioKml: consumoMedioKml,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                Value<DateTime?> syncedAt = const Value.absent(),
                required int vehicleId,
                required DateTime iniciadaEm,
                Value<DateTime?> encerradaEm = const Value.absent(),
                required String protocolo,
                required String adaptador,
                required String origem,
                Value<double?> distanciaKm = const Value.absent(),
                Value<int?> duracaoS = const Value.absent(),
                Value<double?> consumoMedioKml = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                vehicleId: vehicleId,
                iniciadaEm: iniciadaEm,
                encerradaEm: encerradaEm,
                protocolo: protocolo,
                adaptador: adaptador,
                origem: origem,
                distanciaKm: distanciaKm,
                duracaoS: duracaoS,
                consumoMedioKml: consumoMedioKml,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vehicleId = false,
                readingsRefs = false,
                rawFramesRefs = false,
                dtcEventsRefs = false,
                anomaliesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (readingsRefs) db.readings,
                    if (rawFramesRefs) db.rawFrames,
                    if (dtcEventsRefs) db.dtcEvents,
                    if (anomaliesRefs) db.anomalies,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (vehicleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vehicleId,
                            referencedTable: $$SessionsTableReferences
                                ._vehicleIdTable(db),
                            referencedColumn: $$SessionsTableReferences
                                ._vehicleIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (readingsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          Reading
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._readingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).readingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rawFramesRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          RawFrame
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._rawFramesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).rawFramesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dtcEventsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          DtcEvent
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._dtcEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).dtcEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (anomaliesRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          Anomaly
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._anomaliesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).anomaliesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({
        bool vehicleId,
        bool readingsRefs,
        bool rawFramesRefs,
        bool dtcEventsRefs,
        bool anomaliesRefs,
      })
    >;
typedef $$ReadingsTableCreateCompanionBuilder = ReadingsCompanion Function({
  Value<int> id,
  required String uuid,
  Value<DateTime?> syncedAt,
  required int sessionId,
  required DateTime ts,
  required String pidKey,
  required double valor,
  required String contexto,
});
typedef $$ReadingsTableUpdateCompanionBuilder = ReadingsCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<DateTime?> syncedAt,
  Value<int> sessionId,
  Value<DateTime> ts,
  Value<String> pidKey,
  Value<double> valor,
  Value<String> contexto,
});

final class $$ReadingsTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingsTable, Reading> {
  $$ReadingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('readings__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pidKey => $composableBuilder(
    column: $table.pidKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contexto => $composableBuilder(
    column: $table.contexto,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pidKey => $composableBuilder(
    column: $table.pidKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contexto => $composableBuilder(
    column: $table.contexto,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<String> get pidKey =>
      $composableBuilder(column: $table.pidKey, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<String> get contexto =>
      $composableBuilder(column: $table.contexto, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingsTable,
          Reading,
          $$ReadingsTableFilterComposer,
          $$ReadingsTableOrderingComposer,
          $$ReadingsTableAnnotationComposer,
          $$ReadingsTableCreateCompanionBuilder,
          $$ReadingsTableUpdateCompanionBuilder,
          (Reading, $$ReadingsTableReferences),
          Reading,
          PrefetchHooks Function({bool sessionId})
        > {
  $$ReadingsTableTableManager(_$AppDatabase db, $ReadingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<DateTime> ts = const Value.absent(),
                Value<String> pidKey = const Value.absent(),
                Value<double> valor = const Value.absent(),
                Value<String> contexto = const Value.absent(),
              }) => ReadingsCompanion(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                sessionId: sessionId,
                ts: ts,
                pidKey: pidKey,
                valor: valor,
                contexto: contexto,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                Value<DateTime?> syncedAt = const Value.absent(),
                required int sessionId,
                required DateTime ts,
                required String pidKey,
                required double valor,
                required String contexto,
              }) => ReadingsCompanion.insert(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                sessionId: sessionId,
                ts: ts,
                pidKey: pidKey,
                valor: valor,
                contexto: contexto,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$ReadingsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$ReadingsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingsTable,
      Reading,
      $$ReadingsTableFilterComposer,
      $$ReadingsTableOrderingComposer,
      $$ReadingsTableAnnotationComposer,
      $$ReadingsTableCreateCompanionBuilder,
      $$ReadingsTableUpdateCompanionBuilder,
      (Reading, $$ReadingsTableReferences),
      Reading,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$RawFramesTableCreateCompanionBuilder = RawFramesCompanion Function({
  Value<int> id,
  required String uuid,
  Value<DateTime?> syncedAt,
  required int sessionId,
  required DateTime ts,
  required String comando,
  required String respostaBruta,
});
typedef $$RawFramesTableUpdateCompanionBuilder = RawFramesCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<DateTime?> syncedAt,
  Value<int> sessionId,
  Value<DateTime> ts,
  Value<String> comando,
  Value<String> respostaBruta,
});

final class $$RawFramesTableReferences
    extends BaseReferences<_$AppDatabase, $RawFramesTable, RawFrame> {
  $$RawFramesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('raw_frames__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RawFramesTableFilterComposer
    extends Composer<_$AppDatabase, $RawFramesTable> {
  $$RawFramesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comando => $composableBuilder(
    column: $table.comando,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get respostaBruta => $composableBuilder(
    column: $table.respostaBruta,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RawFramesTableOrderingComposer
    extends Composer<_$AppDatabase, $RawFramesTable> {
  $$RawFramesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comando => $composableBuilder(
    column: $table.comando,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get respostaBruta => $composableBuilder(
    column: $table.respostaBruta,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RawFramesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RawFramesTable> {
  $$RawFramesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<String> get comando =>
      $composableBuilder(column: $table.comando, builder: (column) => column);

  GeneratedColumn<String> get respostaBruta => $composableBuilder(
    column: $table.respostaBruta,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RawFramesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RawFramesTable,
          RawFrame,
          $$RawFramesTableFilterComposer,
          $$RawFramesTableOrderingComposer,
          $$RawFramesTableAnnotationComposer,
          $$RawFramesTableCreateCompanionBuilder,
          $$RawFramesTableUpdateCompanionBuilder,
          (RawFrame, $$RawFramesTableReferences),
          RawFrame,
          PrefetchHooks Function({bool sessionId})
        > {
  $$RawFramesTableTableManager(_$AppDatabase db, $RawFramesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RawFramesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RawFramesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RawFramesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<DateTime> ts = const Value.absent(),
                Value<String> comando = const Value.absent(),
                Value<String> respostaBruta = const Value.absent(),
              }) => RawFramesCompanion(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                sessionId: sessionId,
                ts: ts,
                comando: comando,
                respostaBruta: respostaBruta,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                Value<DateTime?> syncedAt = const Value.absent(),
                required int sessionId,
                required DateTime ts,
                required String comando,
                required String respostaBruta,
              }) => RawFramesCompanion.insert(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                sessionId: sessionId,
                ts: ts,
                comando: comando,
                respostaBruta: respostaBruta,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RawFramesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$RawFramesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$RawFramesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RawFramesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RawFramesTable,
      RawFrame,
      $$RawFramesTableFilterComposer,
      $$RawFramesTableOrderingComposer,
      $$RawFramesTableAnnotationComposer,
      $$RawFramesTableCreateCompanionBuilder,
      $$RawFramesTableUpdateCompanionBuilder,
      (RawFrame, $$RawFramesTableReferences),
      RawFrame,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$DtcEventsTableCreateCompanionBuilder = DtcEventsCompanion Function({
  Value<int> id,
  required String uuid,
  Value<DateTime?> syncedAt,
  required int sessionId,
  required DateTime ts,
  required String codigo,
  required String tipo,
  required String descricao,
  Value<Map<String, double>> freezeFrame,
});
typedef $$DtcEventsTableUpdateCompanionBuilder = DtcEventsCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<DateTime?> syncedAt,
  Value<int> sessionId,
  Value<DateTime> ts,
  Value<String> codigo,
  Value<String> tipo,
  Value<String> descricao,
  Value<Map<String, double>> freezeFrame,
});

final class $$DtcEventsTableReferences
    extends BaseReferences<_$AppDatabase, $DtcEventsTable, DtcEvent> {
  $$DtcEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('dtc_events__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DtcEventsTableFilterComposer
    extends Composer<_$AppDatabase, $DtcEventsTable> {
  $$DtcEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, double>,
    Map<String, double>,
    String
  >
  get freezeFrame => $composableBuilder(
    column: $table.freezeFrame,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DtcEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $DtcEventsTable> {
  $$DtcEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freezeFrame => $composableBuilder(
    column: $table.freezeFrame,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DtcEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DtcEventsTable> {
  $$DtcEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, double>, String>
  get freezeFrame => $composableBuilder(
    column: $table.freezeFrame,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DtcEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DtcEventsTable,
          DtcEvent,
          $$DtcEventsTableFilterComposer,
          $$DtcEventsTableOrderingComposer,
          $$DtcEventsTableAnnotationComposer,
          $$DtcEventsTableCreateCompanionBuilder,
          $$DtcEventsTableUpdateCompanionBuilder,
          (DtcEvent, $$DtcEventsTableReferences),
          DtcEvent,
          PrefetchHooks Function({bool sessionId})
        > {
  $$DtcEventsTableTableManager(_$AppDatabase db, $DtcEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DtcEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DtcEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DtcEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<DateTime> ts = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<Map<String, double>> freezeFrame = const Value.absent(),
              }) => DtcEventsCompanion(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                sessionId: sessionId,
                ts: ts,
                codigo: codigo,
                tipo: tipo,
                descricao: descricao,
                freezeFrame: freezeFrame,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                Value<DateTime?> syncedAt = const Value.absent(),
                required int sessionId,
                required DateTime ts,
                required String codigo,
                required String tipo,
                required String descricao,
                Value<Map<String, double>> freezeFrame = const Value.absent(),
              }) => DtcEventsCompanion.insert(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                sessionId: sessionId,
                ts: ts,
                codigo: codigo,
                tipo: tipo,
                descricao: descricao,
                freezeFrame: freezeFrame,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DtcEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$DtcEventsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$DtcEventsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DtcEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DtcEventsTable,
      DtcEvent,
      $$DtcEventsTableFilterComposer,
      $$DtcEventsTableOrderingComposer,
      $$DtcEventsTableAnnotationComposer,
      $$DtcEventsTableCreateCompanionBuilder,
      $$DtcEventsTableUpdateCompanionBuilder,
      (DtcEvent, $$DtcEventsTableReferences),
      DtcEvent,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$BaselinesTableCreateCompanionBuilder = BaselinesCompanion Function({
  Value<int> id,
  required String uuid,
  Value<DateTime?> syncedAt,
  required int vehicleId,
  required String pidKey,
  required String contexto,
  required int n,
  required double media,
  required double m2,
  required DateTime atualizadoEm,
});
typedef $$BaselinesTableUpdateCompanionBuilder = BaselinesCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<DateTime?> syncedAt,
  Value<int> vehicleId,
  Value<String> pidKey,
  Value<String> contexto,
  Value<int> n,
  Value<double> media,
  Value<double> m2,
  Value<DateTime> atualizadoEm,
});

final class $$BaselinesTableReferences
    extends BaseReferences<_$AppDatabase, $BaselinesTable, Baseline> {
  $$BaselinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('baselines__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BaselinesTableFilterComposer
    extends Composer<_$AppDatabase, $BaselinesTable> {
  $$BaselinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pidKey => $composableBuilder(
    column: $table.pidKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contexto => $composableBuilder(
    column: $table.contexto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n => $composableBuilder(
    column: $table.n,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get media => $composableBuilder(
    column: $table.media,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get m2 => $composableBuilder(
    column: $table.m2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BaselinesTableOrderingComposer
    extends Composer<_$AppDatabase, $BaselinesTable> {
  $$BaselinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pidKey => $composableBuilder(
    column: $table.pidKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contexto => $composableBuilder(
    column: $table.contexto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n => $composableBuilder(
    column: $table.n,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get media => $composableBuilder(
    column: $table.media,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get m2 => $composableBuilder(
    column: $table.m2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BaselinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BaselinesTable> {
  $$BaselinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get pidKey =>
      $composableBuilder(column: $table.pidKey, builder: (column) => column);

  GeneratedColumn<String> get contexto =>
      $composableBuilder(column: $table.contexto, builder: (column) => column);

  GeneratedColumn<int> get n =>
      $composableBuilder(column: $table.n, builder: (column) => column);

  GeneratedColumn<double> get media =>
      $composableBuilder(column: $table.media, builder: (column) => column);

  GeneratedColumn<double> get m2 =>
      $composableBuilder(column: $table.m2, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BaselinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BaselinesTable,
          Baseline,
          $$BaselinesTableFilterComposer,
          $$BaselinesTableOrderingComposer,
          $$BaselinesTableAnnotationComposer,
          $$BaselinesTableCreateCompanionBuilder,
          $$BaselinesTableUpdateCompanionBuilder,
          (Baseline, $$BaselinesTableReferences),
          Baseline,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$BaselinesTableTableManager(_$AppDatabase db, $BaselinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BaselinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BaselinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BaselinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<String> pidKey = const Value.absent(),
                Value<String> contexto = const Value.absent(),
                Value<int> n = const Value.absent(),
                Value<double> media = const Value.absent(),
                Value<double> m2 = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
              }) => BaselinesCompanion(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                vehicleId: vehicleId,
                pidKey: pidKey,
                contexto: contexto,
                n: n,
                media: media,
                m2: m2,
                atualizadoEm: atualizadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                Value<DateTime?> syncedAt = const Value.absent(),
                required int vehicleId,
                required String pidKey,
                required String contexto,
                required int n,
                required double media,
                required double m2,
                required DateTime atualizadoEm,
              }) => BaselinesCompanion.insert(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                vehicleId: vehicleId,
                pidKey: pidKey,
                contexto: contexto,
                n: n,
                media: media,
                m2: m2,
                atualizadoEm: atualizadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BaselinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vehicleId,
                        referencedTable: $$BaselinesTableReferences
                            ._vehicleIdTable(db),
                        referencedColumn: $$BaselinesTableReferences
                            ._vehicleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BaselinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BaselinesTable,
      Baseline,
      $$BaselinesTableFilterComposer,
      $$BaselinesTableOrderingComposer,
      $$BaselinesTableAnnotationComposer,
      $$BaselinesTableCreateCompanionBuilder,
      $$BaselinesTableUpdateCompanionBuilder,
      (Baseline, $$BaselinesTableReferences),
      Baseline,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$AnomaliesTableCreateCompanionBuilder = AnomaliesCompanion Function({
  Value<int> id,
  required String uuid,
  Value<DateTime?> syncedAt,
  required int sessionId,
  required DateTime ts,
  required String pidKey,
  required String contexto,
  required double valor,
  required double mediaEsperada,
  required double desvioPadrao,
  required double z,
  required String severidade,
  required String tipo,
});
typedef $$AnomaliesTableUpdateCompanionBuilder = AnomaliesCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<DateTime?> syncedAt,
  Value<int> sessionId,
  Value<DateTime> ts,
  Value<String> pidKey,
  Value<String> contexto,
  Value<double> valor,
  Value<double> mediaEsperada,
  Value<double> desvioPadrao,
  Value<double> z,
  Value<String> severidade,
  Value<String> tipo,
});

final class $$AnomaliesTableReferences
    extends BaseReferences<_$AppDatabase, $AnomaliesTable, Anomaly> {
  $$AnomaliesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('anomalies__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnomaliesTableFilterComposer
    extends Composer<_$AppDatabase, $AnomaliesTable> {
  $$AnomaliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pidKey => $composableBuilder(
    column: $table.pidKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contexto => $composableBuilder(
    column: $table.contexto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mediaEsperada => $composableBuilder(
    column: $table.mediaEsperada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get desvioPadrao => $composableBuilder(
    column: $table.desvioPadrao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get z => $composableBuilder(
    column: $table.z,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severidade => $composableBuilder(
    column: $table.severidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnomaliesTableOrderingComposer
    extends Composer<_$AppDatabase, $AnomaliesTable> {
  $$AnomaliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pidKey => $composableBuilder(
    column: $table.pidKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contexto => $composableBuilder(
    column: $table.contexto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mediaEsperada => $composableBuilder(
    column: $table.mediaEsperada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get desvioPadrao => $composableBuilder(
    column: $table.desvioPadrao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get z => $composableBuilder(
    column: $table.z,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severidade => $composableBuilder(
    column: $table.severidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnomaliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnomaliesTable> {
  $$AnomaliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<String> get pidKey =>
      $composableBuilder(column: $table.pidKey, builder: (column) => column);

  GeneratedColumn<String> get contexto =>
      $composableBuilder(column: $table.contexto, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<double> get mediaEsperada => $composableBuilder(
    column: $table.mediaEsperada,
    builder: (column) => column,
  );

  GeneratedColumn<double> get desvioPadrao => $composableBuilder(
    column: $table.desvioPadrao,
    builder: (column) => column,
  );

  GeneratedColumn<double> get z =>
      $composableBuilder(column: $table.z, builder: (column) => column);

  GeneratedColumn<String> get severidade => $composableBuilder(
    column: $table.severidade,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnomaliesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnomaliesTable,
          Anomaly,
          $$AnomaliesTableFilterComposer,
          $$AnomaliesTableOrderingComposer,
          $$AnomaliesTableAnnotationComposer,
          $$AnomaliesTableCreateCompanionBuilder,
          $$AnomaliesTableUpdateCompanionBuilder,
          (Anomaly, $$AnomaliesTableReferences),
          Anomaly,
          PrefetchHooks Function({bool sessionId})
        > {
  $$AnomaliesTableTableManager(_$AppDatabase db, $AnomaliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnomaliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnomaliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnomaliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<DateTime> ts = const Value.absent(),
                Value<String> pidKey = const Value.absent(),
                Value<String> contexto = const Value.absent(),
                Value<double> valor = const Value.absent(),
                Value<double> mediaEsperada = const Value.absent(),
                Value<double> desvioPadrao = const Value.absent(),
                Value<double> z = const Value.absent(),
                Value<String> severidade = const Value.absent(),
                Value<String> tipo = const Value.absent(),
              }) => AnomaliesCompanion(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                sessionId: sessionId,
                ts: ts,
                pidKey: pidKey,
                contexto: contexto,
                valor: valor,
                mediaEsperada: mediaEsperada,
                desvioPadrao: desvioPadrao,
                z: z,
                severidade: severidade,
                tipo: tipo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                Value<DateTime?> syncedAt = const Value.absent(),
                required int sessionId,
                required DateTime ts,
                required String pidKey,
                required String contexto,
                required double valor,
                required double mediaEsperada,
                required double desvioPadrao,
                required double z,
                required String severidade,
                required String tipo,
              }) => AnomaliesCompanion.insert(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                sessionId: sessionId,
                ts: ts,
                pidKey: pidKey,
                contexto: contexto,
                valor: valor,
                mediaEsperada: mediaEsperada,
                desvioPadrao: desvioPadrao,
                z: z,
                severidade: severidade,
                tipo: tipo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AnomaliesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$AnomaliesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$AnomaliesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AnomaliesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnomaliesTable,
      Anomaly,
      $$AnomaliesTableFilterComposer,
      $$AnomaliesTableOrderingComposer,
      $$AnomaliesTableAnnotationComposer,
      $$AnomaliesTableCreateCompanionBuilder,
      $$AnomaliesTableUpdateCompanionBuilder,
      (Anomaly, $$AnomaliesTableReferences),
      Anomaly,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$TrendWatchesTableCreateCompanionBuilder =
    TrendWatchesCompanion Function({
      Value<int> id,
      required String uuid,
      Value<DateTime?> syncedAt,
      required int vehicleId,
      required String pidKey,
      required String contexto,
      Value<int> consecutiveDeviatedSessions,
      Value<int?> lastSessionId,
    });
typedef $$TrendWatchesTableUpdateCompanionBuilder =
    TrendWatchesCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<DateTime?> syncedAt,
      Value<int> vehicleId,
      Value<String> pidKey,
      Value<String> contexto,
      Value<int> consecutiveDeviatedSessions,
      Value<int?> lastSessionId,
    });

final class $$TrendWatchesTableReferences
    extends BaseReferences<_$AppDatabase, $TrendWatchesTable, TrendWatch> {
  $$TrendWatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('trend_watches__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrendWatchesTableFilterComposer
    extends Composer<_$AppDatabase, $TrendWatchesTable> {
  $$TrendWatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pidKey => $composableBuilder(
    column: $table.pidKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contexto => $composableBuilder(
    column: $table.contexto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consecutiveDeviatedSessions => $composableBuilder(
    column: $table.consecutiveDeviatedSessions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSessionId => $composableBuilder(
    column: $table.lastSessionId,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrendWatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrendWatchesTable> {
  $$TrendWatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pidKey => $composableBuilder(
    column: $table.pidKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contexto => $composableBuilder(
    column: $table.contexto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consecutiveDeviatedSessions => $composableBuilder(
    column: $table.consecutiveDeviatedSessions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSessionId => $composableBuilder(
    column: $table.lastSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrendWatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrendWatchesTable> {
  $$TrendWatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get pidKey =>
      $composableBuilder(column: $table.pidKey, builder: (column) => column);

  GeneratedColumn<String> get contexto =>
      $composableBuilder(column: $table.contexto, builder: (column) => column);

  GeneratedColumn<int> get consecutiveDeviatedSessions => $composableBuilder(
    column: $table.consecutiveDeviatedSessions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSessionId => $composableBuilder(
    column: $table.lastSessionId,
    builder: (column) => column,
  );

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrendWatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrendWatchesTable,
          TrendWatch,
          $$TrendWatchesTableFilterComposer,
          $$TrendWatchesTableOrderingComposer,
          $$TrendWatchesTableAnnotationComposer,
          $$TrendWatchesTableCreateCompanionBuilder,
          $$TrendWatchesTableUpdateCompanionBuilder,
          (TrendWatch, $$TrendWatchesTableReferences),
          TrendWatch,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$TrendWatchesTableTableManager(_$AppDatabase db, $TrendWatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrendWatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrendWatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrendWatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<String> pidKey = const Value.absent(),
                Value<String> contexto = const Value.absent(),
                Value<int> consecutiveDeviatedSessions = const Value.absent(),
                Value<int?> lastSessionId = const Value.absent(),
              }) => TrendWatchesCompanion(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                vehicleId: vehicleId,
                pidKey: pidKey,
                contexto: contexto,
                consecutiveDeviatedSessions: consecutiveDeviatedSessions,
                lastSessionId: lastSessionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                Value<DateTime?> syncedAt = const Value.absent(),
                required int vehicleId,
                required String pidKey,
                required String contexto,
                Value<int> consecutiveDeviatedSessions = const Value.absent(),
                Value<int?> lastSessionId = const Value.absent(),
              }) => TrendWatchesCompanion.insert(
                id: id,
                uuid: uuid,
                syncedAt: syncedAt,
                vehicleId: vehicleId,
                pidKey: pidKey,
                contexto: contexto,
                consecutiveDeviatedSessions: consecutiveDeviatedSessions,
                lastSessionId: lastSessionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrendWatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vehicleId,
                        referencedTable: $$TrendWatchesTableReferences
                            ._vehicleIdTable(db),
                        referencedColumn: $$TrendWatchesTableReferences
                            ._vehicleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrendWatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrendWatchesTable,
      TrendWatch,
      $$TrendWatchesTableFilterComposer,
      $$TrendWatchesTableOrderingComposer,
      $$TrendWatchesTableAnnotationComposer,
      $$TrendWatchesTableCreateCompanionBuilder,
      $$TrendWatchesTableUpdateCompanionBuilder,
      (TrendWatch, $$TrendWatchesTableReferences),
      TrendWatch,
      PrefetchHooks Function({bool vehicleId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$ReadingsTableTableManager get readings =>
      $$ReadingsTableTableManager(_db, _db.readings);
  $$RawFramesTableTableManager get rawFrames =>
      $$RawFramesTableTableManager(_db, _db.rawFrames);
  $$DtcEventsTableTableManager get dtcEvents =>
      $$DtcEventsTableTableManager(_db, _db.dtcEvents);
  $$BaselinesTableTableManager get baselines =>
      $$BaselinesTableTableManager(_db, _db.baselines);
  $$AnomaliesTableTableManager get anomalies =>
      $$AnomaliesTableTableManager(_db, _db.anomalies);
  $$TrendWatchesTableTableManager get trendWatches =>
      $$TrendWatchesTableTableManager(_db, _db.trendWatches);
}
