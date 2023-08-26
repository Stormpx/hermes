// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Database.dart';

// ignore_for_file: type=lint
class $HermesTable extends Hermes with TableInfo<$HermesTable, Herme> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HermesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? 'hermes';
  @override
  String get actualTableName => 'hermes';
  @override
  VerificationContext validateIntegrity(Insertable<Herme> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Herme map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Herme(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
    );
  }

  @override
  $HermesTable createAlias(String alias) {
    return $HermesTable(attachedDatabase, alias);
  }
}

class Herme extends DataClass implements Insertable<Herme> {
  final int? id;
  const Herme({this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    return map;
  }

  HermesCompanion toCompanion(bool nullToAbsent) {
    return HermesCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
    );
  }

  factory Herme.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Herme(
      id: serializer.fromJson<int?>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
    };
  }

  Herme copyWith({Value<int?> id = const Value.absent()}) => Herme(
        id: id.present ? id.value : this.id,
      );
  @override
  String toString() {
    return (StringBuffer('Herme(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Herme && other.id == this.id);
}

class HermesCompanion extends UpdateCompanion<Herme> {
  final Value<int?> id;
  const HermesCompanion({
    this.id = const Value.absent(),
  });
  HermesCompanion.insert({
    this.id = const Value.absent(),
  });
  static Insertable<Herme> custom({
    Expression<int>? id,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
    });
  }

  HermesCompanion copyWith({Value<int?>? id}) {
    return HermesCompanion(
      id: id ?? this.id,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HermesCompanion(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }
}

class $BuildingsTable extends Buildings
    with TableInfo<$BuildingsTable, Building> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuildingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
      'sort', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: Constant(99));
  @override
  List<GeneratedColumn> get $columns => [id, name, sort];
  @override
  String get aliasedName => _alias ?? 'buildings';
  @override
  String get actualTableName => 'buildings';
  @override
  VerificationContext validateIntegrity(Insertable<Building> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
          _sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Building map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Building(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort']),
    );
  }

  @override
  $BuildingsTable createAlias(String alias) {
    return $BuildingsTable(attachedDatabase, alias);
  }
}

class Building extends DataClass implements Insertable<Building> {
  final int? id;
  final String name;
  final int? sort;
  const Building({this.id, required this.name, this.sort});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sort != null) {
      map['sort'] = Variable<int>(sort);
    }
    return map;
  }

  BuildingsCompanion toCompanion(bool nullToAbsent) {
    return BuildingsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      name: Value(name),
      sort: sort == null && nullToAbsent ? const Value.absent() : Value(sort),
    );
  }

  factory Building.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Building(
      id: serializer.fromJson<int?>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sort: serializer.fromJson<int?>(json['sort']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'name': serializer.toJson<String>(name),
      'sort': serializer.toJson<int?>(sort),
    };
  }

  Building copyWith(
          {Value<int?> id = const Value.absent(),
          String? name,
          Value<int?> sort = const Value.absent()}) =>
      Building(
        id: id.present ? id.value : this.id,
        name: name ?? this.name,
        sort: sort.present ? sort.value : this.sort,
      );
  @override
  String toString() {
    return (StringBuffer('Building(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sort);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Building &&
          other.id == this.id &&
          other.name == this.name &&
          other.sort == this.sort);
}

class BuildingsCompanion extends UpdateCompanion<Building> {
  final Value<int?> id;
  final Value<String> name;
  final Value<int?> sort;
  const BuildingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sort = const Value.absent(),
  });
  BuildingsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sort = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Building> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sort,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sort != null) 'sort': sort,
    });
  }

  BuildingsCompanion copyWith(
      {Value<int?>? id, Value<String>? name, Value<int?>? sort}) {
    return BuildingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sort: sort ?? this.sort,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuildingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }
}

class $FloorsTable extends Floors with TableInfo<$FloorsTable, Floor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FloorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _buildingIdMeta =
      const VerificationMeta('buildingId');
  @override
  late final GeneratedColumn<int> buildingId = GeneratedColumn<int>(
      'building_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
      'sort', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: Constant(99));
  @override
  List<GeneratedColumn> get $columns => [id, buildingId, name, sort];
  @override
  String get aliasedName => _alias ?? 'floors';
  @override
  String get actualTableName => 'floors';
  @override
  VerificationContext validateIntegrity(Insertable<Floor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('building_id')) {
      context.handle(
          _buildingIdMeta,
          buildingId.isAcceptableOrUnknown(
              data['building_id']!, _buildingIdMeta));
    } else if (isInserting) {
      context.missing(_buildingIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
          _sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Floor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Floor(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      buildingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}building_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort']),
    );
  }

  @override
  $FloorsTable createAlias(String alias) {
    return $FloorsTable(attachedDatabase, alias);
  }
}

class Floor extends DataClass implements Insertable<Floor> {
  final int? id;
  final int buildingId;
  final String name;
  final int? sort;
  const Floor(
      {this.id, required this.buildingId, required this.name, this.sort});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['building_id'] = Variable<int>(buildingId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sort != null) {
      map['sort'] = Variable<int>(sort);
    }
    return map;
  }

  FloorsCompanion toCompanion(bool nullToAbsent) {
    return FloorsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      buildingId: Value(buildingId),
      name: Value(name),
      sort: sort == null && nullToAbsent ? const Value.absent() : Value(sort),
    );
  }

  factory Floor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Floor(
      id: serializer.fromJson<int?>(json['id']),
      buildingId: serializer.fromJson<int>(json['buildingId']),
      name: serializer.fromJson<String>(json['name']),
      sort: serializer.fromJson<int?>(json['sort']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'buildingId': serializer.toJson<int>(buildingId),
      'name': serializer.toJson<String>(name),
      'sort': serializer.toJson<int?>(sort),
    };
  }

  Floor copyWith(
          {Value<int?> id = const Value.absent(),
          int? buildingId,
          String? name,
          Value<int?> sort = const Value.absent()}) =>
      Floor(
        id: id.present ? id.value : this.id,
        buildingId: buildingId ?? this.buildingId,
        name: name ?? this.name,
        sort: sort.present ? sort.value : this.sort,
      );
  @override
  String toString() {
    return (StringBuffer('Floor(')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('name: $name, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, buildingId, name, sort);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Floor &&
          other.id == this.id &&
          other.buildingId == this.buildingId &&
          other.name == this.name &&
          other.sort == this.sort);
}

class FloorsCompanion extends UpdateCompanion<Floor> {
  final Value<int?> id;
  final Value<int> buildingId;
  final Value<String> name;
  final Value<int?> sort;
  const FloorsCompanion({
    this.id = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.name = const Value.absent(),
    this.sort = const Value.absent(),
  });
  FloorsCompanion.insert({
    this.id = const Value.absent(),
    required int buildingId,
    required String name,
    this.sort = const Value.absent(),
  })  : buildingId = Value(buildingId),
        name = Value(name);
  static Insertable<Floor> custom({
    Expression<int>? id,
    Expression<int>? buildingId,
    Expression<String>? name,
    Expression<int>? sort,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (buildingId != null) 'building_id': buildingId,
      if (name != null) 'name': name,
      if (sort != null) 'sort': sort,
    });
  }

  FloorsCompanion copyWith(
      {Value<int?>? id,
      Value<int>? buildingId,
      Value<String>? name,
      Value<int?>? sort}) {
    return FloorsCompanion(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      name: name ?? this.name,
      sort: sort ?? this.sort,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (buildingId.present) {
      map['building_id'] = Variable<int>(buildingId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FloorsCompanion(')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('name: $name, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _floorIdMeta =
      const VerificationMeta('floorId');
  @override
  late final GeneratedColumn<int> floorId = GeneratedColumn<int>(
      'floor_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
      'sort', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: Constant(99));
  static const VerificationMeta _rentMeta = const VerificationMeta('rent');
  @override
  late final GeneratedColumn<double> rent = GeneratedColumn<double>(
      'rent', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  static const VerificationMeta _electFeeMeta =
      const VerificationMeta('electFee');
  @override
  late final GeneratedColumn<double> electFee = GeneratedColumn<double>(
      'elect_fee', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  static const VerificationMeta _waterFeeMeta =
      const VerificationMeta('waterFee');
  @override
  late final GeneratedColumn<double> waterFee = GeneratedColumn<double>(
      'water_fee', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  static const VerificationMeta _leastMarkDateMeta =
      const VerificationMeta('leastMarkDate');
  @override
  late final GeneratedColumn<DateTime> leastMarkDate =
      GeneratedColumn<DateTime>('least_mark_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, floorId, name, sort, rent, electFee, waterFee, leastMarkDate];
  @override
  String get aliasedName => _alias ?? 'rooms';
  @override
  String get actualTableName => 'rooms';
  @override
  VerificationContext validateIntegrity(Insertable<Room> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('floor_id')) {
      context.handle(_floorIdMeta,
          floorId.isAcceptableOrUnknown(data['floor_id']!, _floorIdMeta));
    } else if (isInserting) {
      context.missing(_floorIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
          _sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    }
    if (data.containsKey('rent')) {
      context.handle(
          _rentMeta, rent.isAcceptableOrUnknown(data['rent']!, _rentMeta));
    }
    if (data.containsKey('elect_fee')) {
      context.handle(_electFeeMeta,
          electFee.isAcceptableOrUnknown(data['elect_fee']!, _electFeeMeta));
    }
    if (data.containsKey('water_fee')) {
      context.handle(_waterFeeMeta,
          waterFee.isAcceptableOrUnknown(data['water_fee']!, _waterFeeMeta));
    }
    if (data.containsKey('least_mark_date')) {
      context.handle(
          _leastMarkDateMeta,
          leastMarkDate.isAcceptableOrUnknown(
              data['least_mark_date']!, _leastMarkDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      floorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}floor_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort']),
      rent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rent']),
      electFee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}elect_fee']),
      waterFee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}water_fee']),
      leastMarkDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}least_mark_date']),
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class Room extends DataClass implements Insertable<Room> {
  final int? id;
  final int floorId;
  final String name;
  final int? sort;
  final double? rent;
  final double? electFee;
  final double? waterFee;
  final DateTime? leastMarkDate;
  const Room(
      {this.id,
      required this.floorId,
      required this.name,
      this.sort,
      this.rent,
      this.electFee,
      this.waterFee,
      this.leastMarkDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['floor_id'] = Variable<int>(floorId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sort != null) {
      map['sort'] = Variable<int>(sort);
    }
    if (!nullToAbsent || rent != null) {
      map['rent'] = Variable<double>(rent);
    }
    if (!nullToAbsent || electFee != null) {
      map['elect_fee'] = Variable<double>(electFee);
    }
    if (!nullToAbsent || waterFee != null) {
      map['water_fee'] = Variable<double>(waterFee);
    }
    if (!nullToAbsent || leastMarkDate != null) {
      map['least_mark_date'] = Variable<DateTime>(leastMarkDate);
    }
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      floorId: Value(floorId),
      name: Value(name),
      sort: sort == null && nullToAbsent ? const Value.absent() : Value(sort),
      rent: rent == null && nullToAbsent ? const Value.absent() : Value(rent),
      electFee: electFee == null && nullToAbsent
          ? const Value.absent()
          : Value(electFee),
      waterFee: waterFee == null && nullToAbsent
          ? const Value.absent()
          : Value(waterFee),
      leastMarkDate: leastMarkDate == null && nullToAbsent
          ? const Value.absent()
          : Value(leastMarkDate),
    );
  }

  factory Room.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      id: serializer.fromJson<int?>(json['id']),
      floorId: serializer.fromJson<int>(json['floorId']),
      name: serializer.fromJson<String>(json['name']),
      sort: serializer.fromJson<int?>(json['sort']),
      rent: serializer.fromJson<double?>(json['rent']),
      electFee: serializer.fromJson<double?>(json['electFee']),
      waterFee: serializer.fromJson<double?>(json['waterFee']),
      leastMarkDate: serializer.fromJson<DateTime?>(json['leastMarkDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'floorId': serializer.toJson<int>(floorId),
      'name': serializer.toJson<String>(name),
      'sort': serializer.toJson<int?>(sort),
      'rent': serializer.toJson<double?>(rent),
      'electFee': serializer.toJson<double?>(electFee),
      'waterFee': serializer.toJson<double?>(waterFee),
      'leastMarkDate': serializer.toJson<DateTime?>(leastMarkDate),
    };
  }

  Room copyWith(
          {Value<int?> id = const Value.absent(),
          int? floorId,
          String? name,
          Value<int?> sort = const Value.absent(),
          Value<double?> rent = const Value.absent(),
          Value<double?> electFee = const Value.absent(),
          Value<double?> waterFee = const Value.absent(),
          Value<DateTime?> leastMarkDate = const Value.absent()}) =>
      Room(
        id: id.present ? id.value : this.id,
        floorId: floorId ?? this.floorId,
        name: name ?? this.name,
        sort: sort.present ? sort.value : this.sort,
        rent: rent.present ? rent.value : this.rent,
        electFee: electFee.present ? electFee.value : this.electFee,
        waterFee: waterFee.present ? waterFee.value : this.waterFee,
        leastMarkDate:
            leastMarkDate.present ? leastMarkDate.value : this.leastMarkDate,
      );
  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('id: $id, ')
          ..write('floorId: $floorId, ')
          ..write('name: $name, ')
          ..write('sort: $sort, ')
          ..write('rent: $rent, ')
          ..write('electFee: $electFee, ')
          ..write('waterFee: $waterFee, ')
          ..write('leastMarkDate: $leastMarkDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, floorId, name, sort, rent, electFee, waterFee, leastMarkDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.id == this.id &&
          other.floorId == this.floorId &&
          other.name == this.name &&
          other.sort == this.sort &&
          other.rent == this.rent &&
          other.electFee == this.electFee &&
          other.waterFee == this.waterFee &&
          other.leastMarkDate == this.leastMarkDate);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<int?> id;
  final Value<int> floorId;
  final Value<String> name;
  final Value<int?> sort;
  final Value<double?> rent;
  final Value<double?> electFee;
  final Value<double?> waterFee;
  final Value<DateTime?> leastMarkDate;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.floorId = const Value.absent(),
    this.name = const Value.absent(),
    this.sort = const Value.absent(),
    this.rent = const Value.absent(),
    this.electFee = const Value.absent(),
    this.waterFee = const Value.absent(),
    this.leastMarkDate = const Value.absent(),
  });
  RoomsCompanion.insert({
    this.id = const Value.absent(),
    required int floorId,
    required String name,
    this.sort = const Value.absent(),
    this.rent = const Value.absent(),
    this.electFee = const Value.absent(),
    this.waterFee = const Value.absent(),
    this.leastMarkDate = const Value.absent(),
  })  : floorId = Value(floorId),
        name = Value(name);
  static Insertable<Room> custom({
    Expression<int>? id,
    Expression<int>? floorId,
    Expression<String>? name,
    Expression<int>? sort,
    Expression<double>? rent,
    Expression<double>? electFee,
    Expression<double>? waterFee,
    Expression<DateTime>? leastMarkDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (floorId != null) 'floor_id': floorId,
      if (name != null) 'name': name,
      if (sort != null) 'sort': sort,
      if (rent != null) 'rent': rent,
      if (electFee != null) 'elect_fee': electFee,
      if (waterFee != null) 'water_fee': waterFee,
      if (leastMarkDate != null) 'least_mark_date': leastMarkDate,
    });
  }

  RoomsCompanion copyWith(
      {Value<int?>? id,
      Value<int>? floorId,
      Value<String>? name,
      Value<int?>? sort,
      Value<double?>? rent,
      Value<double?>? electFee,
      Value<double?>? waterFee,
      Value<DateTime?>? leastMarkDate}) {
    return RoomsCompanion(
      id: id ?? this.id,
      floorId: floorId ?? this.floorId,
      name: name ?? this.name,
      sort: sort ?? this.sort,
      rent: rent ?? this.rent,
      electFee: electFee ?? this.electFee,
      waterFee: waterFee ?? this.waterFee,
      leastMarkDate: leastMarkDate ?? this.leastMarkDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (floorId.present) {
      map['floor_id'] = Variable<int>(floorId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (rent.present) {
      map['rent'] = Variable<double>(rent.value);
    }
    if (electFee.present) {
      map['elect_fee'] = Variable<double>(electFee.value);
    }
    if (waterFee.present) {
      map['water_fee'] = Variable<double>(waterFee.value);
    }
    if (leastMarkDate.present) {
      map['least_mark_date'] = Variable<DateTime>(leastMarkDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('floorId: $floorId, ')
          ..write('name: $name, ')
          ..write('sort: $sort, ')
          ..write('rent: $rent, ')
          ..write('electFee: $electFee, ')
          ..write('waterFee: $waterFee, ')
          ..write('leastMarkDate: $leastMarkDate')
          ..write(')'))
        .toString();
  }
}

class $RoomDaysTable extends RoomDays with TableInfo<$RoomDaysTable, RoomDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
      'room_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _electMeta = const VerificationMeta('elect');
  @override
  late final GeneratedColumn<double> elect = GeneratedColumn<double>(
      'elect', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  static const VerificationMeta _waterMeta = const VerificationMeta('water');
  @override
  late final GeneratedColumn<double> water = GeneratedColumn<double>(
      'water', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, roomId, date, elect, water];
  @override
  String get aliasedName => _alias ?? 'room_days';
  @override
  String get actualTableName => 'room_days';
  @override
  VerificationContext validateIntegrity(Insertable<RoomDay> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('elect')) {
      context.handle(
          _electMeta, elect.isAcceptableOrUnknown(data['elect']!, _electMeta));
    }
    if (data.containsKey('water')) {
      context.handle(
          _waterMeta, water.isAcceptableOrUnknown(data['water']!, _waterMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {roomId, date},
      ];
  @override
  RoomDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomDay(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}room_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      elect: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}elect']),
      water: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}water']),
    );
  }

  @override
  $RoomDaysTable createAlias(String alias) {
    return $RoomDaysTable(attachedDatabase, alias);
  }
}

class RoomDay extends DataClass implements Insertable<RoomDay> {
  final int? id;
  final int roomId;
  final DateTime date;
  final double? elect;
  final double? water;
  const RoomDay(
      {this.id,
      required this.roomId,
      required this.date,
      this.elect,
      this.water});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['room_id'] = Variable<int>(roomId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || elect != null) {
      map['elect'] = Variable<double>(elect);
    }
    if (!nullToAbsent || water != null) {
      map['water'] = Variable<double>(water);
    }
    return map;
  }

  RoomDaysCompanion toCompanion(bool nullToAbsent) {
    return RoomDaysCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      roomId: Value(roomId),
      date: Value(date),
      elect:
          elect == null && nullToAbsent ? const Value.absent() : Value(elect),
      water:
          water == null && nullToAbsent ? const Value.absent() : Value(water),
    );
  }

  factory RoomDay.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomDay(
      id: serializer.fromJson<int?>(json['id']),
      roomId: serializer.fromJson<int>(json['roomId']),
      date: serializer.fromJson<DateTime>(json['date']),
      elect: serializer.fromJson<double?>(json['elect']),
      water: serializer.fromJson<double?>(json['water']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'roomId': serializer.toJson<int>(roomId),
      'date': serializer.toJson<DateTime>(date),
      'elect': serializer.toJson<double?>(elect),
      'water': serializer.toJson<double?>(water),
    };
  }

  RoomDay copyWith(
          {Value<int?> id = const Value.absent(),
          int? roomId,
          DateTime? date,
          Value<double?> elect = const Value.absent(),
          Value<double?> water = const Value.absent()}) =>
      RoomDay(
        id: id.present ? id.value : this.id,
        roomId: roomId ?? this.roomId,
        date: date ?? this.date,
        elect: elect.present ? elect.value : this.elect,
        water: water.present ? water.value : this.water,
      );
  @override
  String toString() {
    return (StringBuffer('RoomDay(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('date: $date, ')
          ..write('elect: $elect, ')
          ..write('water: $water')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roomId, date, elect, water);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomDay &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.date == this.date &&
          other.elect == this.elect &&
          other.water == this.water);
}

class RoomDaysCompanion extends UpdateCompanion<RoomDay> {
  final Value<int?> id;
  final Value<int> roomId;
  final Value<DateTime> date;
  final Value<double?> elect;
  final Value<double?> water;
  const RoomDaysCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.date = const Value.absent(),
    this.elect = const Value.absent(),
    this.water = const Value.absent(),
  });
  RoomDaysCompanion.insert({
    this.id = const Value.absent(),
    required int roomId,
    required DateTime date,
    this.elect = const Value.absent(),
    this.water = const Value.absent(),
  })  : roomId = Value(roomId),
        date = Value(date);
  static Insertable<RoomDay> custom({
    Expression<int>? id,
    Expression<int>? roomId,
    Expression<DateTime>? date,
    Expression<double>? elect,
    Expression<double>? water,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (date != null) 'date': date,
      if (elect != null) 'elect': elect,
      if (water != null) 'water': water,
    });
  }

  RoomDaysCompanion copyWith(
      {Value<int?>? id,
      Value<int>? roomId,
      Value<DateTime>? date,
      Value<double?>? elect,
      Value<double?>? water}) {
    return RoomDaysCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      date: date ?? this.date,
      elect: elect ?? this.elect,
      water: water ?? this.water,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (elect.present) {
      map['elect'] = Variable<double>(elect.value);
    }
    if (water.present) {
      map['water'] = Variable<double>(water.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomDaysCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('date: $date, ')
          ..write('elect: $elect, ')
          ..write('water: $water')
          ..write(')'))
        .toString();
  }
}

class $RoomOptionsTable extends RoomOptions
    with TableInfo<$RoomOptionsTable, RoomOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
      'room_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<double> fee = GeneratedColumn<double>(
      'fee', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, roomId, name, fee];
  @override
  String get aliasedName => _alias ?? 'room_options';
  @override
  String get actualTableName => 'room_options';
  @override
  VerificationContext validateIntegrity(Insertable<RoomOption> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('fee')) {
      context.handle(
          _feeMeta, fee.isAcceptableOrUnknown(data['fee']!, _feeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoomOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomOption(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}room_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      fee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fee']),
    );
  }

  @override
  $RoomOptionsTable createAlias(String alias) {
    return $RoomOptionsTable(attachedDatabase, alias);
  }
}

class RoomOption extends DataClass implements Insertable<RoomOption> {
  final int? id;
  final int roomId;
  final String name;
  final double? fee;
  const RoomOption(
      {this.id, required this.roomId, required this.name, this.fee});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['room_id'] = Variable<int>(roomId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || fee != null) {
      map['fee'] = Variable<double>(fee);
    }
    return map;
  }

  RoomOptionsCompanion toCompanion(bool nullToAbsent) {
    return RoomOptionsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      roomId: Value(roomId),
      name: Value(name),
      fee: fee == null && nullToAbsent ? const Value.absent() : Value(fee),
    );
  }

  factory RoomOption.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomOption(
      id: serializer.fromJson<int?>(json['id']),
      roomId: serializer.fromJson<int>(json['roomId']),
      name: serializer.fromJson<String>(json['name']),
      fee: serializer.fromJson<double?>(json['fee']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'roomId': serializer.toJson<int>(roomId),
      'name': serializer.toJson<String>(name),
      'fee': serializer.toJson<double?>(fee),
    };
  }

  RoomOption copyWith(
          {Value<int?> id = const Value.absent(),
          int? roomId,
          String? name,
          Value<double?> fee = const Value.absent()}) =>
      RoomOption(
        id: id.present ? id.value : this.id,
        roomId: roomId ?? this.roomId,
        name: name ?? this.name,
        fee: fee.present ? fee.value : this.fee,
      );
  @override
  String toString() {
    return (StringBuffer('RoomOption(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('fee: $fee')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roomId, name, fee);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomOption &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.name == this.name &&
          other.fee == this.fee);
}

class RoomOptionsCompanion extends UpdateCompanion<RoomOption> {
  final Value<int?> id;
  final Value<int> roomId;
  final Value<String> name;
  final Value<double?> fee;
  const RoomOptionsCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.name = const Value.absent(),
    this.fee = const Value.absent(),
  });
  RoomOptionsCompanion.insert({
    this.id = const Value.absent(),
    required int roomId,
    required String name,
    this.fee = const Value.absent(),
  })  : roomId = Value(roomId),
        name = Value(name);
  static Insertable<RoomOption> custom({
    Expression<int>? id,
    Expression<int>? roomId,
    Expression<String>? name,
    Expression<double>? fee,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (name != null) 'name': name,
      if (fee != null) 'fee': fee,
    });
  }

  RoomOptionsCompanion copyWith(
      {Value<int?>? id,
      Value<int>? roomId,
      Value<String>? name,
      Value<double?>? fee}) {
    return RoomOptionsCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      fee: fee ?? this.fee,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fee.present) {
      map['fee'] = Variable<double>(fee.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomOptionsCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('fee: $fee')
          ..write(')'))
        .toString();
  }
}

class $RoomSnapshotsTable extends RoomSnapshots
    with TableInfo<$RoomSnapshotsTable, RoomSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
      'room_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _snapshotStartDateMeta =
      const VerificationMeta('snapshotStartDate');
  @override
  late final GeneratedColumn<DateTime> snapshotStartDate =
      GeneratedColumn<DateTime>('snapshot_start_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _snapshotEndDateMeta =
      const VerificationMeta('snapshotEndDate');
  @override
  late final GeneratedColumn<DateTime> snapshotEndDate =
      GeneratedColumn<DateTime>('snapshot_end_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _rentMeta = const VerificationMeta('rent');
  @override
  late final GeneratedColumn<double> rent = GeneratedColumn<double>(
      'rent', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  static const VerificationMeta _electFeeMeta =
      const VerificationMeta('electFee');
  @override
  late final GeneratedColumn<double> electFee = GeneratedColumn<double>(
      'elect_fee', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  static const VerificationMeta _waterFeeMeta =
      const VerificationMeta('waterFee');
  @override
  late final GeneratedColumn<double> waterFee = GeneratedColumn<double>(
      'water_fee', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  static const VerificationMeta _electMeta = const VerificationMeta('elect');
  @override
  late final GeneratedColumn<double> elect = GeneratedColumn<double>(
      'elect', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  static const VerificationMeta _waterMeta = const VerificationMeta('water');
  @override
  late final GeneratedColumn<double> water = GeneratedColumn<double>(
      'water', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        roomId,
        snapshotStartDate,
        snapshotEndDate,
        rent,
        electFee,
        waterFee,
        elect,
        water,
        totalAmount
      ];
  @override
  String get aliasedName => _alias ?? 'room_snapshots';
  @override
  String get actualTableName => 'room_snapshots';
  @override
  VerificationContext validateIntegrity(Insertable<RoomSnapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('snapshot_start_date')) {
      context.handle(
          _snapshotStartDateMeta,
          snapshotStartDate.isAcceptableOrUnknown(
              data['snapshot_start_date']!, _snapshotStartDateMeta));
    } else if (isInserting) {
      context.missing(_snapshotStartDateMeta);
    }
    if (data.containsKey('snapshot_end_date')) {
      context.handle(
          _snapshotEndDateMeta,
          snapshotEndDate.isAcceptableOrUnknown(
              data['snapshot_end_date']!, _snapshotEndDateMeta));
    } else if (isInserting) {
      context.missing(_snapshotEndDateMeta);
    }
    if (data.containsKey('rent')) {
      context.handle(
          _rentMeta, rent.isAcceptableOrUnknown(data['rent']!, _rentMeta));
    }
    if (data.containsKey('elect_fee')) {
      context.handle(_electFeeMeta,
          electFee.isAcceptableOrUnknown(data['elect_fee']!, _electFeeMeta));
    }
    if (data.containsKey('water_fee')) {
      context.handle(_waterFeeMeta,
          waterFee.isAcceptableOrUnknown(data['water_fee']!, _waterFeeMeta));
    }
    if (data.containsKey('elect')) {
      context.handle(
          _electMeta, elect.isAcceptableOrUnknown(data['elect']!, _electMeta));
    }
    if (data.containsKey('water')) {
      context.handle(
          _waterMeta, water.isAcceptableOrUnknown(data['water']!, _waterMeta));
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoomSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomSnapshot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}room_id'])!,
      snapshotStartDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}snapshot_start_date'])!,
      snapshotEndDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}snapshot_end_date'])!,
      rent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rent']),
      electFee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}elect_fee']),
      waterFee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}water_fee']),
      elect: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}elect']),
      water: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}water']),
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount']),
    );
  }

  @override
  $RoomSnapshotsTable createAlias(String alias) {
    return $RoomSnapshotsTable(attachedDatabase, alias);
  }
}

class RoomSnapshot extends DataClass implements Insertable<RoomSnapshot> {
  final int? id;
  final int roomId;
  final DateTime snapshotStartDate;
  final DateTime snapshotEndDate;
  final double? rent;
  final double? electFee;
  final double? waterFee;
  final double? elect;
  final double? water;
  final double? totalAmount;
  const RoomSnapshot(
      {this.id,
      required this.roomId,
      required this.snapshotStartDate,
      required this.snapshotEndDate,
      this.rent,
      this.electFee,
      this.waterFee,
      this.elect,
      this.water,
      this.totalAmount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['room_id'] = Variable<int>(roomId);
    map['snapshot_start_date'] = Variable<DateTime>(snapshotStartDate);
    map['snapshot_end_date'] = Variable<DateTime>(snapshotEndDate);
    if (!nullToAbsent || rent != null) {
      map['rent'] = Variable<double>(rent);
    }
    if (!nullToAbsent || electFee != null) {
      map['elect_fee'] = Variable<double>(electFee);
    }
    if (!nullToAbsent || waterFee != null) {
      map['water_fee'] = Variable<double>(waterFee);
    }
    if (!nullToAbsent || elect != null) {
      map['elect'] = Variable<double>(elect);
    }
    if (!nullToAbsent || water != null) {
      map['water'] = Variable<double>(water);
    }
    if (!nullToAbsent || totalAmount != null) {
      map['total_amount'] = Variable<double>(totalAmount);
    }
    return map;
  }

  RoomSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return RoomSnapshotsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      roomId: Value(roomId),
      snapshotStartDate: Value(snapshotStartDate),
      snapshotEndDate: Value(snapshotEndDate),
      rent: rent == null && nullToAbsent ? const Value.absent() : Value(rent),
      electFee: electFee == null && nullToAbsent
          ? const Value.absent()
          : Value(electFee),
      waterFee: waterFee == null && nullToAbsent
          ? const Value.absent()
          : Value(waterFee),
      elect:
          elect == null && nullToAbsent ? const Value.absent() : Value(elect),
      water:
          water == null && nullToAbsent ? const Value.absent() : Value(water),
      totalAmount: totalAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(totalAmount),
    );
  }

  factory RoomSnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomSnapshot(
      id: serializer.fromJson<int?>(json['id']),
      roomId: serializer.fromJson<int>(json['roomId']),
      snapshotStartDate:
          serializer.fromJson<DateTime>(json['snapshotStartDate']),
      snapshotEndDate: serializer.fromJson<DateTime>(json['snapshotEndDate']),
      rent: serializer.fromJson<double?>(json['rent']),
      electFee: serializer.fromJson<double?>(json['electFee']),
      waterFee: serializer.fromJson<double?>(json['waterFee']),
      elect: serializer.fromJson<double?>(json['elect']),
      water: serializer.fromJson<double?>(json['water']),
      totalAmount: serializer.fromJson<double?>(json['totalAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'roomId': serializer.toJson<int>(roomId),
      'snapshotStartDate': serializer.toJson<DateTime>(snapshotStartDate),
      'snapshotEndDate': serializer.toJson<DateTime>(snapshotEndDate),
      'rent': serializer.toJson<double?>(rent),
      'electFee': serializer.toJson<double?>(electFee),
      'waterFee': serializer.toJson<double?>(waterFee),
      'elect': serializer.toJson<double?>(elect),
      'water': serializer.toJson<double?>(water),
      'totalAmount': serializer.toJson<double?>(totalAmount),
    };
  }

  RoomSnapshot copyWith(
          {Value<int?> id = const Value.absent(),
          int? roomId,
          DateTime? snapshotStartDate,
          DateTime? snapshotEndDate,
          Value<double?> rent = const Value.absent(),
          Value<double?> electFee = const Value.absent(),
          Value<double?> waterFee = const Value.absent(),
          Value<double?> elect = const Value.absent(),
          Value<double?> water = const Value.absent(),
          Value<double?> totalAmount = const Value.absent()}) =>
      RoomSnapshot(
        id: id.present ? id.value : this.id,
        roomId: roomId ?? this.roomId,
        snapshotStartDate: snapshotStartDate ?? this.snapshotStartDate,
        snapshotEndDate: snapshotEndDate ?? this.snapshotEndDate,
        rent: rent.present ? rent.value : this.rent,
        electFee: electFee.present ? electFee.value : this.electFee,
        waterFee: waterFee.present ? waterFee.value : this.waterFee,
        elect: elect.present ? elect.value : this.elect,
        water: water.present ? water.value : this.water,
        totalAmount: totalAmount.present ? totalAmount.value : this.totalAmount,
      );
  @override
  String toString() {
    return (StringBuffer('RoomSnapshot(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('snapshotStartDate: $snapshotStartDate, ')
          ..write('snapshotEndDate: $snapshotEndDate, ')
          ..write('rent: $rent, ')
          ..write('electFee: $electFee, ')
          ..write('waterFee: $waterFee, ')
          ..write('elect: $elect, ')
          ..write('water: $water, ')
          ..write('totalAmount: $totalAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roomId, snapshotStartDate,
      snapshotEndDate, rent, electFee, waterFee, elect, water, totalAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomSnapshot &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.snapshotStartDate == this.snapshotStartDate &&
          other.snapshotEndDate == this.snapshotEndDate &&
          other.rent == this.rent &&
          other.electFee == this.electFee &&
          other.waterFee == this.waterFee &&
          other.elect == this.elect &&
          other.water == this.water &&
          other.totalAmount == this.totalAmount);
}

class RoomSnapshotsCompanion extends UpdateCompanion<RoomSnapshot> {
  final Value<int?> id;
  final Value<int> roomId;
  final Value<DateTime> snapshotStartDate;
  final Value<DateTime> snapshotEndDate;
  final Value<double?> rent;
  final Value<double?> electFee;
  final Value<double?> waterFee;
  final Value<double?> elect;
  final Value<double?> water;
  final Value<double?> totalAmount;
  const RoomSnapshotsCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.snapshotStartDate = const Value.absent(),
    this.snapshotEndDate = const Value.absent(),
    this.rent = const Value.absent(),
    this.electFee = const Value.absent(),
    this.waterFee = const Value.absent(),
    this.elect = const Value.absent(),
    this.water = const Value.absent(),
    this.totalAmount = const Value.absent(),
  });
  RoomSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required int roomId,
    required DateTime snapshotStartDate,
    required DateTime snapshotEndDate,
    this.rent = const Value.absent(),
    this.electFee = const Value.absent(),
    this.waterFee = const Value.absent(),
    this.elect = const Value.absent(),
    this.water = const Value.absent(),
    this.totalAmount = const Value.absent(),
  })  : roomId = Value(roomId),
        snapshotStartDate = Value(snapshotStartDate),
        snapshotEndDate = Value(snapshotEndDate);
  static Insertable<RoomSnapshot> custom({
    Expression<int>? id,
    Expression<int>? roomId,
    Expression<DateTime>? snapshotStartDate,
    Expression<DateTime>? snapshotEndDate,
    Expression<double>? rent,
    Expression<double>? electFee,
    Expression<double>? waterFee,
    Expression<double>? elect,
    Expression<double>? water,
    Expression<double>? totalAmount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (snapshotStartDate != null) 'snapshot_start_date': snapshotStartDate,
      if (snapshotEndDate != null) 'snapshot_end_date': snapshotEndDate,
      if (rent != null) 'rent': rent,
      if (electFee != null) 'elect_fee': electFee,
      if (waterFee != null) 'water_fee': waterFee,
      if (elect != null) 'elect': elect,
      if (water != null) 'water': water,
      if (totalAmount != null) 'total_amount': totalAmount,
    });
  }

  RoomSnapshotsCompanion copyWith(
      {Value<int?>? id,
      Value<int>? roomId,
      Value<DateTime>? snapshotStartDate,
      Value<DateTime>? snapshotEndDate,
      Value<double?>? rent,
      Value<double?>? electFee,
      Value<double?>? waterFee,
      Value<double?>? elect,
      Value<double?>? water,
      Value<double?>? totalAmount}) {
    return RoomSnapshotsCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      snapshotStartDate: snapshotStartDate ?? this.snapshotStartDate,
      snapshotEndDate: snapshotEndDate ?? this.snapshotEndDate,
      rent: rent ?? this.rent,
      electFee: electFee ?? this.electFee,
      waterFee: waterFee ?? this.waterFee,
      elect: elect ?? this.elect,
      water: water ?? this.water,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (snapshotStartDate.present) {
      map['snapshot_start_date'] = Variable<DateTime>(snapshotStartDate.value);
    }
    if (snapshotEndDate.present) {
      map['snapshot_end_date'] = Variable<DateTime>(snapshotEndDate.value);
    }
    if (rent.present) {
      map['rent'] = Variable<double>(rent.value);
    }
    if (electFee.present) {
      map['elect_fee'] = Variable<double>(electFee.value);
    }
    if (waterFee.present) {
      map['water_fee'] = Variable<double>(waterFee.value);
    }
    if (elect.present) {
      map['elect'] = Variable<double>(elect.value);
    }
    if (water.present) {
      map['water'] = Variable<double>(water.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('snapshotStartDate: $snapshotStartDate, ')
          ..write('snapshotEndDate: $snapshotEndDate, ')
          ..write('rent: $rent, ')
          ..write('electFee: $electFee, ')
          ..write('waterFee: $waterFee, ')
          ..write('elect: $elect, ')
          ..write('water: $water, ')
          ..write('totalAmount: $totalAmount')
          ..write(')'))
        .toString();
  }
}

class $RoomSnapshotItemsTable extends RoomSnapshotItems
    with TableInfo<$RoomSnapshotItemsTable, RoomSnapshotItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomSnapshotItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
      'room_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _snapshotIdMeta =
      const VerificationMeta('snapshotId');
  @override
  late final GeneratedColumn<int> snapshotId = GeneratedColumn<int>(
      'snapshot_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descMeta = const VerificationMeta('desc');
  @override
  late final GeneratedColumn<String> desc = GeneratedColumn<String>(
      'desc', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<double> fee = GeneratedColumn<double>(
      'fee', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, roomId, snapshotId, name, desc, fee];
  @override
  String get aliasedName => _alias ?? 'room_snapshot_items';
  @override
  String get actualTableName => 'room_snapshot_items';
  @override
  VerificationContext validateIntegrity(Insertable<RoomSnapshotItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('snapshot_id')) {
      context.handle(
          _snapshotIdMeta,
          snapshotId.isAcceptableOrUnknown(
              data['snapshot_id']!, _snapshotIdMeta));
    } else if (isInserting) {
      context.missing(_snapshotIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('desc')) {
      context.handle(
          _descMeta, desc.isAcceptableOrUnknown(data['desc']!, _descMeta));
    }
    if (data.containsKey('fee')) {
      context.handle(
          _feeMeta, fee.isAcceptableOrUnknown(data['fee']!, _feeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoomSnapshotItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomSnapshotItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}room_id'])!,
      snapshotId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}snapshot_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      desc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}desc']),
      fee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fee']),
    );
  }

  @override
  $RoomSnapshotItemsTable createAlias(String alias) {
    return $RoomSnapshotItemsTable(attachedDatabase, alias);
  }
}

class RoomSnapshotItem extends DataClass
    implements Insertable<RoomSnapshotItem> {
  final int? id;
  final int roomId;
  final int snapshotId;
  final String name;
  final String? desc;
  final double? fee;
  const RoomSnapshotItem(
      {this.id,
      required this.roomId,
      required this.snapshotId,
      required this.name,
      this.desc,
      this.fee});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['room_id'] = Variable<int>(roomId);
    map['snapshot_id'] = Variable<int>(snapshotId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || desc != null) {
      map['desc'] = Variable<String>(desc);
    }
    if (!nullToAbsent || fee != null) {
      map['fee'] = Variable<double>(fee);
    }
    return map;
  }

  RoomSnapshotItemsCompanion toCompanion(bool nullToAbsent) {
    return RoomSnapshotItemsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      roomId: Value(roomId),
      snapshotId: Value(snapshotId),
      name: Value(name),
      desc: desc == null && nullToAbsent ? const Value.absent() : Value(desc),
      fee: fee == null && nullToAbsent ? const Value.absent() : Value(fee),
    );
  }

  factory RoomSnapshotItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomSnapshotItem(
      id: serializer.fromJson<int?>(json['id']),
      roomId: serializer.fromJson<int>(json['roomId']),
      snapshotId: serializer.fromJson<int>(json['snapshotId']),
      name: serializer.fromJson<String>(json['name']),
      desc: serializer.fromJson<String?>(json['desc']),
      fee: serializer.fromJson<double?>(json['fee']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'roomId': serializer.toJson<int>(roomId),
      'snapshotId': serializer.toJson<int>(snapshotId),
      'name': serializer.toJson<String>(name),
      'desc': serializer.toJson<String?>(desc),
      'fee': serializer.toJson<double?>(fee),
    };
  }

  RoomSnapshotItem copyWith(
          {Value<int?> id = const Value.absent(),
          int? roomId,
          int? snapshotId,
          String? name,
          Value<String?> desc = const Value.absent(),
          Value<double?> fee = const Value.absent()}) =>
      RoomSnapshotItem(
        id: id.present ? id.value : this.id,
        roomId: roomId ?? this.roomId,
        snapshotId: snapshotId ?? this.snapshotId,
        name: name ?? this.name,
        desc: desc.present ? desc.value : this.desc,
        fee: fee.present ? fee.value : this.fee,
      );
  @override
  String toString() {
    return (StringBuffer('RoomSnapshotItem(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('snapshotId: $snapshotId, ')
          ..write('name: $name, ')
          ..write('desc: $desc, ')
          ..write('fee: $fee')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roomId, snapshotId, name, desc, fee);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomSnapshotItem &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.snapshotId == this.snapshotId &&
          other.name == this.name &&
          other.desc == this.desc &&
          other.fee == this.fee);
}

class RoomSnapshotItemsCompanion extends UpdateCompanion<RoomSnapshotItem> {
  final Value<int?> id;
  final Value<int> roomId;
  final Value<int> snapshotId;
  final Value<String> name;
  final Value<String?> desc;
  final Value<double?> fee;
  const RoomSnapshotItemsCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.snapshotId = const Value.absent(),
    this.name = const Value.absent(),
    this.desc = const Value.absent(),
    this.fee = const Value.absent(),
  });
  RoomSnapshotItemsCompanion.insert({
    this.id = const Value.absent(),
    required int roomId,
    required int snapshotId,
    required String name,
    this.desc = const Value.absent(),
    this.fee = const Value.absent(),
  })  : roomId = Value(roomId),
        snapshotId = Value(snapshotId),
        name = Value(name);
  static Insertable<RoomSnapshotItem> custom({
    Expression<int>? id,
    Expression<int>? roomId,
    Expression<int>? snapshotId,
    Expression<String>? name,
    Expression<String>? desc,
    Expression<double>? fee,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (snapshotId != null) 'snapshot_id': snapshotId,
      if (name != null) 'name': name,
      if (desc != null) 'desc': desc,
      if (fee != null) 'fee': fee,
    });
  }

  RoomSnapshotItemsCompanion copyWith(
      {Value<int?>? id,
      Value<int>? roomId,
      Value<int>? snapshotId,
      Value<String>? name,
      Value<String?>? desc,
      Value<double?>? fee}) {
    return RoomSnapshotItemsCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      snapshotId: snapshotId ?? this.snapshotId,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      fee: fee ?? this.fee,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (snapshotId.present) {
      map['snapshot_id'] = Variable<int>(snapshotId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (desc.present) {
      map['desc'] = Variable<String>(desc.value);
    }
    if (fee.present) {
      map['fee'] = Variable<double>(fee.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomSnapshotItemsCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('snapshotId: $snapshotId, ')
          ..write('name: $name, ')
          ..write('desc: $desc, ')
          ..write('fee: $fee')
          ..write(')'))
        .toString();
  }
}

abstract class _$HermesDatabase extends GeneratedDatabase {
  _$HermesDatabase(QueryExecutor e) : super(e);
  late final $HermesTable hermes = $HermesTable(this);
  late final $BuildingsTable buildings = $BuildingsTable(this);
  late final $FloorsTable floors = $FloorsTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $RoomDaysTable roomDays = $RoomDaysTable(this);
  late final $RoomOptionsTable roomOptions = $RoomOptionsTable(this);
  late final $RoomSnapshotsTable roomSnapshots = $RoomSnapshotsTable(this);
  late final $RoomSnapshotItemsTable roomSnapshotItems =
      $RoomSnapshotItemsTable(this);
  late final BuildingsDao buildingsDao = BuildingsDao(this as HermesDatabase);
  late final FloorsDao floorsDao = FloorsDao(this as HermesDatabase);
  late final RoomsDao roomsDao = RoomsDao(this as HermesDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        hermes,
        buildings,
        floors,
        rooms,
        roomDays,
        roomOptions,
        roomSnapshots,
        roomSnapshotItems
      ];
}
