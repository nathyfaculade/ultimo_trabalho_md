import '../database/database_provider.dart';

import '../model/ponto_turistico.dart';

class TurismoDao {
  final databaseProvider = DatabaseProvider.instance;

  Future<bool> salvar(PontoTuristico pontoturistico) async {
    final database = await databaseProvider.database;
    final valores = pontoturistico.toMap();
    if (pontoturistico.id == 0) {
      pontoturistico.id = await database.insert(PontoTuristico.fielTabela, valores);
      return true;
    } else {
      final registrosAtualizados = await database.update(
        PontoTuristico.fielTabela,
        valores,
        where: '${PontoTuristico.fielId} = ?',
        whereArgs: [pontoturistico.id],
      );
      return registrosAtualizados > 0;
    }
  }

  Future<bool> remover(int id) async {
    final database = await databaseProvider.database;
    final registrosAtualizados = await database.delete(
      PontoTuristico.fielTabela,
      where: '${PontoTuristico.fielId} = ?',
      whereArgs: [id],
    );
    return registrosAtualizados > 0;
  }

  Future<List<PontoTuristico>> listar({
    String filtro = '',
    String campoOrdenacao = PontoTuristico.fielId,
    bool usarOrdemDecrescente = false,
  }) async {
    String? where;
    if (filtro.isNotEmpty) {
      where = "UPPER(${PontoTuristico.fielDescricao}) LIKE '${filtro.toUpperCase()}%'";
    }
    var orderBy = campoOrdenacao;
    if (usarOrdemDecrescente) {
      orderBy += ' DESC';
    }
    final database = await databaseProvider.database;
    final resultado = await database.query(
      PontoTuristico.fielTabela,
      columns: [
        PontoTuristico.fielId,
        PontoTuristico.fielNome,
        PontoTuristico.fielDescricao,
        PontoTuristico.fielDiferenciais,
        PontoTuristico.fielData,
        PontoTuristico.fielLatitude,
        PontoTuristico.fielLocalizacao,
        PontoTuristico.fielCep,
        PontoTuristico.fielLongitude
      ],
      where: where,
      orderBy: orderBy,
    );
    return resultado.map((m) => PontoTuristico.fromMap(m)).toList();
  }
}