import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:garagem_app/database/garage_status_db.dart';

class DatabaseService {
  final name = 'database.db';
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      debugPrint("INFORMAÇÃO --- A _database existe");
      return _database!;
    } else {
      debugPrint("INFORMAÇÃO --- A _database não existe, iniciando o processo de criação");
      _database = await _initialize();
      debugPrint("INFORMAÇÃO --- _database criada e inicializada com sucesso!");
      return _database!;
    }
  }

  Future<String> get fullPath async {
    debugPrint("INFORMAÇÃO --- Criando e obtendo o caminho da _database");
    final path = await getDatabasesPath();
    debugPrint("INFORMAÇÃO --- Caminho criado com sucesso: '$path'");
    return join(path, name);
  }

  Future<Database> _initialize() async {
    debugPrint("INFORMAÇÃO --- Inicializando a _database");
    try {
      final path = await fullPath;
      var database = await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
        singleInstance: true,
      );
      debugPrint("INFORMAÇÃO --- _database aberta com sucesso");
      return database;
    } catch (e) {
      debugPrint("ERRO --- Ao inicializar o banco de dados: $e");
      return Future.error("ERRO --- Ao inicializar o banco de dados: $e");
    }
  }

  Future<void> _createDatabase(Database database, int version) async {
    final tableName = GarageStatusDB().tableName;
    try{
      debugPrint("INFORMAÇÃO --- Criando as tabelas na $name");
      await GarageStatusDB().createTable(database);
      debugPrint("INFORMAÇÃO --- As tabelas da $name acabaram de serem criadas");
    } catch (e) {
      debugPrint("ERRO --- Ao criar as tabelas na $name : $e");
      return Future.error("ERRO --- Ao criar a tabela $tableName na $name : $e");
    }
  }

  Future<void> initializeDatabase() async {
    try {
      await database;
    } catch (e) {
      debugPrint("ERRO --- Ao inicializar a _database: $e");
    }
  }
}
