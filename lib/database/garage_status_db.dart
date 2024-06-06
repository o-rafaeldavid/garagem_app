import "package:flutter/material.dart";
import "package:sqflite/sqflite.dart";
import "package:garagem_app/database/database_service.dart";
import "package:garagem_app/model/garage_status.dart";

class GarageStatusDB{
  final tableName = "garageStatus";

  /// !! grande observação !!
  /// este .then é extremamente importante, porque haviam ações que estavam a serem feitas em conjunto com o database.execute
  /// e quando isto acontece, a database.execute é cancelada, pelo que o processo de criar uma db era cancelado por consequencia
  /// então, a db voltaria a ser dada como nula enquanto variável em DatabaseService
  /// logo, entrava num ciclo infinito! (e demorou séculos para chegar a isto)
  Future<void> createTable(Database database) async {
    debugPrint("INFORMAÇÃO --- Executando a criação da tabela '$tableName' na base de dados");
    await database.execute(
      '''
        CREATE TABLE IF NOT EXISTS $tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          porta_estado INTEGER NOT NULL DEFAULT 1,
          active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT DEFAULT NULL,
          updated_at TEXT DEFAULT NULL
        )
      '''
    ).then((_) {
      debugPrint("INFORMAÇÃO --- Passado a execução da criação da tabela '$tableName'");
      doesTableExist().then((tableExists) {
        if (tableExists) {
          debugPrint("INFORMAÇÃO --- A tabela '$tableName' já existe!");
        } else {
          debugPrint("INFORMAÇÃO --- Tabela '$tableName' foi criada com sucesso!");
        }
      });
    }).catchError((e) {
      debugPrint("ERRO --- Erro ao criar a tabela '$tableName': $e");
      throw Exception("Erro ao criar a tabela '$tableName': $e");
    });
  }

  ///////
  Future<int> create({required String title}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (title, porta_estado, active, created_at) VALUES (?, 1, 1, "${DateTime.now().toUtc().toIso8601String()}")''',
      [title]
    );
  }

  ///////
  Future<bool> doesTableExist() async {
    final database = await DatabaseService().database;
    final result = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName';",
    );
    return result.isNotEmpty;
  }

  ///////
  Future<List<GarageStatus>> getAll({bool reverse = false}) async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.rawQuery('SELECT * FROM $tableName');

    List<GarageStatus> garageStatusList = List.generate(maps.length, (i) {
      return GarageStatus.fromMap(maps[i]);
    });

    if(reverse) garageStatusList = garageStatusList.reversed.toList();

    return garageStatusList;
  }

  ///////
  Future<GarageStatus?> getLastRow() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> rows = await database.rawQuery(
      'SELECT * FROM $tableName ORDER BY id DESC LIMIT 1',
    );
    if(rows.isNotEmpty){ return GarageStatus.fromMap(rows.first); }
    else{
      debugPrint("ERRO --- método getLastRow() mal executado! --- Não existe nenhuma linha na base de dados, portanto, não existe nenhuma 'última linha' para obter informações!");
      return null;
    }
  }

  ///////
  Future<GarageStatus?> getByID(int id) async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.rawQuery(
      'SELECT * FROM $tableName WHERE id = ?',
      [id],
    );

    if(maps.isNotEmpty){ return GarageStatus.fromMap(maps.first); }
    else{
      debugPrint("ERRO --- método getByID() mal executado! --- Não existe nenhuma linha na base de dados com o id '$id'!");
      return null;
    }
  }

  ///////
  Future<int> updateLastGarage({
    bool? porta_estado,
    bool? active
  }) async {
    final database = await DatabaseService().database;
    final lastRow = await getLastRow();

    if (lastRow != null) {
      return await database.update(
        tableName,
        {
          'porta_estado': (porta_estado ?? lastRow.porta_estado) ? 1 : 0,
          'active': (active ?? lastRow.active) ? 1 : 0,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [lastRow.id],
      );
    } else {
      debugPrint("ERRO --- método update() mal executado! --- Não existe nenhuma 'última linha' para dar update na base de dados! --- OBS: este método utiliza o getLastRow()");
      return 0;
    }
  }

  ///////
  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    debugPrint("INFORMAÇÃO --- Eliminando o id '$id' da tabela '$tableName' ...");
    await database.rawDelete(
      '''DELETE FROM $tableName WHERE id = ?''',
      [id]
    );
    debugPrint("INFORMAÇÃO --- O id '$id' da tabela '$tableName' foi eliminado com sucesso");
  }

  Future<void> deleteTable() async {
    final database = await DatabaseService().database;
    debugPrint("INFORMAÇÃO --- Eliminando a tabela $tableName");
    await database.execute(
      '''
        DROP TABLE IF EXISTS $tableName
      '''
    ).then((_) {
      debugPrint("INFORMAÇÃO --- A tabela '$tableName' foi eliminada com sucesso!");
    }).catchError((e) {
      debugPrint("ERRO --- Erro ao eliminar a tabela '$tableName': $e");
      throw Exception("ERRO --- Erro ao eliminar a tabela '$tableName': $e");
    });
  }
}