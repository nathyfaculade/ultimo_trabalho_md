import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import '../model/ponto_turistico.dart';

class DatabaseProvider {
  static const _dbName = 'cadastro_do_turismo.db';
  static const _dbVersion = 2;

  DatabaseProvider._init();
  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = '$databasesPath/$_dbName';
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE ${PontoTuristico.fielTabela} (
        ${PontoTuristico.fielId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${PontoTuristico.fielNome} TEXT,
        ${PontoTuristico.fielDescricao} TEXT NOT NULL,
        ${PontoTuristico.fielData} TEXT,
        ${PontoTuristico.fielDiferenciais} TEXT,
        ${PontoTuristico.fielLatitude} TEXT,
        ${PontoTuristico.fielLongitude} TEXT,
        ${PontoTuristico.fielLocalizacao} TEXT,
        ${PontoTuristico.fielCep} TEXT,
        ${PontoTuristico.fielFinalizada} INTEGER NOT NULL DEFAULT 0
      );
    ''');
  }


  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    switch (oldVersion) {
      case 3:
        await db.execute(''' 
          ALTER TABLE ${PontoTuristico.fielTabela}
          ADD COLUMN  ${PontoTuristico.fielCep} TEXT DEFAULT '';
        ''');
        break;
      case 4:
        await db.execute(''' 
          UPDATE ${PontoTuristico.fielTabela}
          SET  ${PontoTuristico.fielCep} =  ''
           WHERE ${PontoTuristico.fielCep} IS NULL;
        ''');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}