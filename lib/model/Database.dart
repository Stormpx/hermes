import 'dart:io';
import 'package:drift/isolate.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:hermes/model/Daos.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// assuming that your file is called filename.dart. This will give an error at
// first, but it's needed for drift to know about the generated code
part 'Database.g.dart';

extension Query<Table extends HasResultSet, Row>
    on ResultSetImplementation<Table, Row> {
  Selectable<Row> findAll() {
    return select();
  }

  Selectable<Row> findById(Object id) {
    return select()
      ..where((row) {
        final idColumn = columnsByName['id'];

        if (idColumn == null) {
          throw ArgumentError.value(
              this, 'this', 'Must be a table with an id column');
        }

        if (idColumn.type != DriftSqlType.int) {
          throw ArgumentError('Column `id` is not an integer');
        }

        return idColumn.equals(id);
      });
  }
}

extension Modify<Tbl extends Table, Row extends Insertable<Row>>
    on TableInfo<Tbl, Row> {
  Future<bool> deleteById(Object id) async {
    return await (delete()
              ..where((tbl) {
                final idColumn = columnsByName['id'];

                if (idColumn == null) {
                  throw ArgumentError.value(
                      this, 'this', 'Must be a table with an id column');
                }

                if (idColumn.type != DriftSqlType.int) {
                  throw ArgumentError('Column `id` is not an integer');
                }

                return idColumn.equals(id);
              }))
            .go() !=
        0;
  }
}

class Hermes extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();
}

class Buildings extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();

  TextColumn get name => text().withLength(min: 0, max: 50)();

  IntColumn get sort => integer().nullable().withDefault(Constant(99))();
}

class Floors extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();

  IntColumn get buildingId => integer()();

  TextColumn get name => text().withLength(min: 0, max: 50)();

  IntColumn get sort => integer().nullable().withDefault(Constant(99))();
}

class Rooms extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();

  IntColumn get floorId => integer()();

  TextColumn get name => text().withLength(min: 0, max: 50)();

  IntColumn get sort => integer().nullable().withDefault(Constant(99))();

  RealColumn get rent => real().nullable().withDefault(Constant(0))();

  RealColumn get electFee => real().nullable().withDefault(Constant(0))();

  RealColumn get waterFee => real().nullable().withDefault(Constant(0))();

  DateTimeColumn get leastMarkDate => dateTime().nullable()();
}

class RoomOptions extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();

  IntColumn get roomId => integer()();

  TextColumn get name => text().withLength(min: 0, max: 50)();

  RealColumn get fee => real().nullable().withDefault(Constant(0))();
}

class RoomDays extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();

  IntColumn get roomId => integer()();

  DateTimeColumn get date => dateTime()();

  RealColumn get elect => real().nullable().withDefault(Constant(0))();

  RealColumn get water => real().nullable().withDefault(Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {roomId, date}
      ];
}

class RoomSnapshots extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();

  IntColumn get roomId => integer()();

  DateTimeColumn get snapshotStartDate => dateTime()();

  DateTimeColumn get snapshotEndDate => dateTime()();

  RealColumn get rent => real().nullable().withDefault(Constant(0))();

  RealColumn get electFee => real().nullable().withDefault(Constant(0))();

  RealColumn get waterFee => real().nullable().withDefault(Constant(0))();

  RealColumn get elect => real().nullable().withDefault(Constant(0))();

  RealColumn get water => real().nullable().withDefault(Constant(0))();

  RealColumn get totalAmount => real().nullable().withDefault(Constant(0))();
}

class RoomSnapshotItems extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();

  IntColumn get roomId => integer()();

  IntColumn get snapshotId => integer()();

  TextColumn get name => text().withLength(min: 0, max: 50)();

  TextColumn get desc => text().nullable().withLength(min: 0, max: 500)();

  RealColumn get fee => real().nullable().withDefault(Constant(0))();
}

@DriftDatabase(tables: [
  Hermes,
  Buildings,
  Floors,
  Rooms,
  RoomDays,
  RoomOptions,
  RoomDays,
  RoomSnapshots,
  RoomSnapshotItems
], daos: [
  BuildingsDao,
  FloorsDao,
  RoomsDao
])
class HermesDatabase extends _$HermesDatabase {
  // we tell the database where to store the data with this constructor
  HermesDatabase([File? file]) : super(_openConnection(file));

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(onCreate: (m) async {
      await m.createAll();
    }, onUpgrade: (m, from, to) async {
      if (from == 3) {
        await m.create(hermes);
      }
      if (from <= 4) {
        await m.alterTable(TableMigration(roomSnapshots,
            newColumns: [roomSnapshots.elect, roomSnapshots.water]));
      }
    });
  }

  Future<void> deleteEverything() {
    return transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}

Future<File> databaseFile() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  File file = File(p.join(dbFolder.path, 'db.sqlite'));
  return file;
}

Future<DriftIsolate> createIsolateWithSpawn() async {
  final token = RootIsolateToken.instance;
  return await DriftIsolate.spawn(() {
    // This function runs in a new isolate, so we must first initialize the
    // messenger to use platform channels.
    BackgroundIsolateBinaryMessenger.ensureInitialized(token!);

    // The callback to DriftIsolate.spawn() must return the database connection
    // to use.
    return LazyDatabase(() async {
      // Note that this runs on a background isolate, which only started to
      // support platform channels in Flutter 3.7. For earlier Flutter versions,
      // a workaround is described later in this article.
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      // if(await file.exists()){
      //   await file.delete();
      // }
      return NativeDatabase(file, logStatements: true);
    });
  });
}

QueryExecutor _openConnection([File? file]) {
  return LazyDatabase(() async {
    // Note that this runs on a background isolate, which only started to
    // support platform channels in Flutter 3.7. For earlier Flutter versions,
    // a workaround is described later in this article.
    if (file == null) {
      file = await databaseFile();
    }
    // if(await file.exists()){
    //   await file.delete();
    // }
    return NativeDatabase.createInBackground(file!, logStatements: true);
  });
}
