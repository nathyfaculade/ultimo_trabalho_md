
import 'package:intl/intl.dart';

class PontoTuristico{

  static const fielTabela = 'ponto_turistico';
  static const fielId = 'id';
  static const fielNome = 'nome';
  static const fielDescricao = 'descricao';
  static const fielData = 'data';
  static const fielDiferenciais = 'diferenciais';
  static const fielLongitude = 'longitude';
  static const fielLatitude = 'latitude';
  static const fielLocalizacao = 'localizacao';
  static const fielCep = 'cep';
  static const fielFinalizada = 'finalizada';

  int? id;
  String nome;
  String descricao;
  String diferenciais;
  DateTime? dataCadastro = DateTime.now();
  String longitude;
  String latitude;
  String localizacao;
  String cep;
  bool finalizada;


  PontoTuristico({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.diferenciais,
    required this.longitude,
    required this.latitude,
    required this.localizacao,
    required this.cep,
    this.finalizada = false,
    this.dataCadastro
  });

  String get dataCadastroFormatado{
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return formattedDate;
  }

  Map<String, dynamic> toMap() => {
    fielId: id == 0 ? null: id,
    fielNome: nome,
    fielDescricao: descricao,
    fielDiferenciais: diferenciais,
    fielData:
    dataCadastro == null ? null : DateFormat("yyyy-MM-dd").format(dataCadastro!),
    fielLongitude:longitude,
    fielLatitude:latitude,
    fielLocalizacao:localizacao,
    fielCep:cep,
    fielFinalizada: finalizada ? 1 : 0
  };

  factory PontoTuristico.fromMap(Map<String, dynamic> map) => PontoTuristico(
    id: map[fielId] is int ? map[fielId] : null,
    nome: map[fielNome] is String ? map[fielNome] : '',
    descricao: map[fielDescricao] is String ? map[fielDescricao] : '',
    diferenciais: map[fielDiferenciais] is String ? map[fielDiferenciais] : '',
    dataCadastro: map[fielData] is String
        ? DateFormat("yyyy-MM-dd").parse(map[fielData])
        : null,
    latitude: map[fielLatitude] is String ? map[fielLatitude] : '',
    longitude: map[fielLongitude] is String ? map[fielLongitude] : '',
    localizacao: map[fielLocalizacao] is String ? map[fielLocalizacao] : '',
    cep: map[fielCep] is String ? map[fielCep] : '',
    finalizada: map[fielFinalizada] == 1,
  );
}




















