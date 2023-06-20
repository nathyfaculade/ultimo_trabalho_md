import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ponto_turistico.dart';

class FiltroPage extends StatefulWidget{
  static const routeName = '/filtro';
  static const chaveCampoOrdenacao = 'campoOrdenacao';
  static const chaveUsarOrdemDecrescente = 'usarOrdemDecrescente';
  static const chaveCampoDescricao = 'campoDescricao';
  static const chaveCampoDiferenciais = 'campoDiferencial';
  static const chaveCampoNome = 'campoNome';

  @override
  _FiltroPageState createState() => _FiltroPageState();

}
class _FiltroPageState extends State<FiltroPage> {

  final _camposParaOrdenacao = {
    PontoTuristico.fielId: 'Código',
    PontoTuristico.fielNome: 'Nome',
    PontoTuristico.fielDescricao: 'Descrição',
    PontoTuristico.fielDescricao: 'Diferenciais',
    PontoTuristico.fielData: 'Data de Cadastro'
  };

  late final SharedPreferences _prefes;
  final _descricaoController = TextEditingController();
  String _campoOrdenacao = PontoTuristico.fielId;
  bool _usarOrdemDecrescente = false;
  bool _alterouValores = false;
  final _diferenciaisController = TextEditingController();
  final _nomeController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _carregaDadosSharedPreferences();
  }

  void _carregaDadosSharedPreferences() async {
    _prefes = await SharedPreferences.getInstance();
    setState(() {
      _campoOrdenacao = _prefes.getString(FiltroPage.chaveCampoOrdenacao) ?? PontoTuristico.fielId;
      _usarOrdemDecrescente = _prefes.getBool(FiltroPage.chaveUsarOrdemDecrescente) == true;
      _descricaoController.text = _prefes.getString(FiltroPage.chaveCampoDescricao) ?? '' ;
      _descricaoController.text =
          _prefes.getString(FiltroPage.chaveCampoDescricao) ?? '';
      _diferenciaisController.text =
          _prefes.getString(FiltroPage.chaveCampoDiferenciais) ?? '';
      _nomeController.text =
          _prefes.getString(FiltroPage.chaveCampoNome) ?? '';

    });
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(title: Text('Filtro e Ordenação'),
        ),
        body: _criarBody(),
      ),
      onWillPop: _onVoltarClick,
    );
  }

  Widget _criarBody() {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: Text('Campos para Ordenação'),
        ),
        for (final campo in _camposParaOrdenacao.keys)
          Row(
            children: [
              Radio(
                value: campo,
                groupValue: _campoOrdenacao,
                onChanged: _onCampoParaOrdenacaoChanged,
              ),
              Text(_camposParaOrdenacao[campo]!),
            ],
          ),
        Divider(),
        Row(
          children: [
            Checkbox(
              value: _usarOrdemDecrescente,
              onChanged: _onUsarOrdemDecrescenteChanged,
            ),
            Text('Usar ordem decrescente'),
          ],
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Informe a descricao de busca',
            ),
            controller: _descricaoController ,
            onChanged: _onFiltroDescricaoChanged,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Informe os diferenciais de busca',
            ),
            controller: _diferenciaisController,
            onChanged: _onFiltroDiferenciaisChanged,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Informe o nome de busca',
            ),
            controller: _nomeController,
            onChanged: _onFiltroNomeChanged,
          ),
        )
      ],
    );
  }

  void _onCampoParaOrdenacaoChanged(String? valor){
    _prefes.setString(FiltroPage.chaveCampoOrdenacao, valor!);
    _alterouValores = true;
    setState(() {
      _campoOrdenacao = valor;
    });
  }

  void _onUsarOrdemDecrescenteChanged(bool? valor){
    _prefes.setBool(FiltroPage.chaveUsarOrdemDecrescente, valor!);
    _alterouValores = true;
    setState(() {
      _usarOrdemDecrescente = valor;
    });
  }

  void _onFiltroDescricaoChanged(String? valor){
    _prefes.setString(FiltroPage.chaveCampoDescricao, valor!);
    _alterouValores = true;
  }

  void _onFiltroDiferenciaisChanged(String? valor){
    _prefes.setString(FiltroPage.chaveCampoDiferenciais, valor!);
    _alterouValores = true;
  }

  void _onFiltroNomeChanged(String? valor){
    _prefes.setString(FiltroPage.chaveCampoNome, valor!);
    _alterouValores = true;
  }

  Future<bool> _onVoltarClick() async {
    Navigator.of(context).pop(_alterouValores);
    return true;
  }
}
