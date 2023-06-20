import 'package:json_annotation/json_annotation.dart';

//essa pagina faz parte do
part 'cep_model.g.dart';

//Defindo o CEP
@JsonSerializable()
class Endereco {

  // A ? permite receber um null dentro do campo
  final String? cep;
  final String? logradouro;
  final String? complemento;
  final String? bairro;
  final String? localidade;
  final String? uf;
  final String? ibge;
  final String? gia;
  @JsonKey(name: 'ddd') // Marca que recebe um DDD mas o nome dentro do sistema vai ser codigoArea
  final String? codigoArea;
  final String? siafi;

  //Retornando os campos, que podem ou não ser preenchidos
  Endereco({this.cep, this.logradouro, this.complemento, this.bairro, this.localidade, this.uf,
    this.ibge, this.gia, this.codigoArea, this.siafi});

  factory Endereco.fromJson(Map<String, dynamic> json) => _$EnderecoFromJson(json);
  Map<String, dynamic> toJson() => _$EnderecoToJson(this);
}
