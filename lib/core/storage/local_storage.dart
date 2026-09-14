import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'local_storage.g.dart';

@DataClassName('ProductRow')
class ProductRows extends Table {
  IntColumn get id => integer()();

  TextColumn get title => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  TextColumn get category => text().withDefault(const Constant(''))();

  RealColumn get price => real().withDefault(const Constant(0))();

  RealColumn get discountPercentage => real().withDefault(const Constant(0))();

  RealColumn get rating => real().withDefault(const Constant(0))();

  IntColumn get stock => integer().withDefault(const Constant(0))();

  TextColumn get brand => text().withDefault(const Constant(''))();

  TextColumn get thumbnail => text().withDefault(const Constant(''))();

  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KeyValueRow')
class KeyValueRows extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [ProductRows, KeyValueRows])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase({required String name})
    : super(
        driftDatabase(
          name: name,
          native: const DriftNativeOptions(shareAcrossIsolates: true),
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  LocalDatabase.forTesting(super.executor) : super();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {},
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<String?> readSetting(String key) async {
    final row = await (select(
      keyValueRows,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeSetting(String key, String value) => into(
    keyValueRows,
  ).insertOnConflictUpdate(KeyValueRow(key: key, value: value));

  Future<void> deleteSetting(String key) =>
      (delete(keyValueRows)..where((t) => t.key.equals(key))).go();

  Future<void> clearUserData() => transaction(() async {
    await delete(productRows).go();
  });
}
