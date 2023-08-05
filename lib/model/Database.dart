
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// assuming that your file is called filename.dart. This will give an error at
// first, but it's needed for drift to know about the generated code
part 'Database.g.dart';

class Buildings extends Table{
  IntColumn get id => integer().nullable().autoIncrement()();
  TextColumn get name => text().withLength(min: 0, max: 50)();
  IntColumn get sort => integer().nullable().clientDefault(() => 99)();
}

class Floors extends Table{
  IntColumn get id => integer().nullable().autoIncrement()();
  IntColumn get buildingId => integer()();
  TextColumn get name => text().withLength(min: 0, max: 50)();
  IntColumn get sort => integer().nullable().clientDefault(() => 99)();
}


@DriftDatabase(tables: [Buildings,Floors])
class HermesDatabase extends _$HermesDatabase  {
  // we tell the database where to store the data with this constructor
  HermesDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}