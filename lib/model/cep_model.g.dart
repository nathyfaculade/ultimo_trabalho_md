// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cep_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Endereco _$EnderecoFromJson(Map<String, dynamic> json) => Endereco(
  cep: json['cep'] as String?,
  logradouro: json['logradouro'] as String?,
  complemento: json['complemento'] as String?,
  bairro: json['bairro'] as String?,
  localidade: json['localidade'] as String?,
  uf: json['uf'] as String?,
  ibge: json['ibge'] as String?,
  gia: json['gia'] as String?,
  codigoArea: json['ddd'] as String?,
  siafi: json['siafi'] as String?,
);

Map<String, dynamic> _$EnderecoToJson(Endereco instance) => <String, dynamic>{
  'cep': instance.cep,
  'logradouro': instance.logradouro,
  'complemento': instance.complemento,
  'bairro': instance.bairro,
  'localidade': instance.localidade,
  'uf': instance.uf,
  'ibge': instance.ibge,
  'gia': instance.gia,
  'ddd': instance.codigoArea,
  'siafi': instance.siafi,
};
