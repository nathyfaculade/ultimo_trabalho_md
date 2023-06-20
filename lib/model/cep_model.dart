import 'package:json_annotation/json_annotation.dart';

part 'cep_model.g.dart';


@JsonSerializable()
class Endereco {

  final String? cep;
  final String? logradouro;
  final String? complemento;
  final String? bairro;
  final String? localidade;
  final String? uf;
  final String? ibge;
  final String? gia;
  @JsonKey(name: 'ddd')
  final String? codigoArea;
  final String? siafi;

  Endereco({this.cep, this.logradouro, this.complemento, this.bairro, this.localidade, this.uf,
    this.ibge, this.gia, this.codigoArea, this.siafi});

  factory Endereco.fromJson(Map<String, dynamic> json) => _$EnderecoFromJson(json);
  Map<String, dynamic> toJson() => _$EnderecoToJson(this);
}
