import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dao/turismo_dao.dart';
import '../model/ponto_turistico.dart';
import '../widgets/conteudo_form_dialog.dart';
import 'detalhes_turismo_page.dart';
import 'filtro_page.dart';

class ListaTurismoPage extends StatefulWidget {

  @override
  _ListaTurismoPageState createState() => _ListaTurismoPageState();
}

class _ListaTurismoPageState extends State<ListaTurismoPage> {

  static const ACAO_EDITAR = 'editar';
  static const ACAO_EXCLUIR = 'excluir';
  static const ACAO_VISUALIZAR = 'visualizar';

  final _turismos = <PontoTuristico>[];
  final _dao = TurismoDao();
  var _carregando = false;

  @override
  void initState() {
    // super.initState();
    _atualizarLista();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _criarAppBar(),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo Ponto Turístico',
        child: const Icon(Icons.add),
        onPressed: _abrirForm,
      ),
    );
  }

  //APPBAR
  AppBar _criarAppBar() {
    return AppBar(
      title: const Text('Gerenciador de Pontos Turísticos'),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filtro e Ordenação',
          onPressed: _abrirPaginaFiltro,
        ),
      ],
    );
  }

   //BODY
    Widget _criarBody(){
      //Mostra o carregamento com o circulo e texto
      if (_carregando) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Tela de carregamento circular mostrando o progresso
            Align(
              alignment: AlignmentDirectional.center,
              child: CircularProgressIndicator(),
            ),
            Align(
              alignment: AlignmentDirectional.center,
              child: Padding(
                padding: EdgeInsets.only(top:10),
                child: Text(
                  'Carregando seus pontos turisticos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor
                  ),
                ),
              ),
            ),
          ],
        );
      } //_Carregando termina aqui

      //Texto na tela inicial caso não tenha pontos cadastrados
      if (_turismos.isEmpty){
        return Center(
          child: Text(
            'Nenhum Ponto Turistico Cadastrado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor
            ),
          ),
        );
      } //_Turismo termina aqui

      //ListView
      return ListView.separated(
        itemCount: _turismos.length,
        itemBuilder: (BuildContext context, int index) {
          final turismo = _turismos[index];
          return PopupMenuButton<String>(
            child: ListTile(

              //CheckBox do Ponto Turistico - Se marcado ou não
              leading: Checkbox(
                value: turismo.finalizada,
                onChanged: (bool? checked) {
                  setState(() {
                    turismo.finalizada = checked == true;
                  });
                  _dao.salvar(turismo);
                },
              ),

              //Campo para listar as informações do Ponto Turistico na tela inicial
              // Titulo com nome do ponto turistico
              title: Text(
                '${turismo.id} - ${turismo.nome}',
                style: TextStyle(
                  decoration:
                  turismo.finalizada ? TextDecoration.lineThrough : null,
                  color: turismo.finalizada ? Colors.grey : null,
                ),
              ),

              //Data do cadastro do ponto turistico
              subtitle: Text(turismo.dataCadastro == null
                  ? 'Tarefa sem data de inserção'
                  : 'Data Cadastro - ${turismo.dataCadastroFormatado}',
                style: TextStyle(
                  decoration:
                  turismo.finalizada ? TextDecoration.lineThrough : null,
                  color: turismo.finalizada ? Colors.grey : null,
                ),
              ),
            ),

            //Botão para Editar, Excluir ou Visualizar o Ponto Turistico Cadastrado
            itemBuilder: (_) => _criarItensMenuPopup(),
            onSelected: (String valorSelecionado) {
              if (valorSelecionado == ACAO_EDITAR) {
                _abrirForm(turismo: turismo);
              } else if (valorSelecionado == ACAO_EXCLUIR) {
                _excluir(turismo);
              } else {
                _abrirPaginaDetalhesTurismo(turismo);
              }
            },
          );
        },
        separatorBuilder: (_, __) => Divider(),
      );
    }

    // TELA COM AÇÕES DE EDITAR, EXCLUIR OU VISUALIZAR
    List<PopupMenuEntry<String>> _criarItensMenuPopup() => [
      //AÇÃO EDITAR
      PopupMenuItem(
        value: ACAO_EDITAR,
        child: Row(
          children: const [
            Icon(Icons.edit, color: Colors.black),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Editar'),
            ),
          ],
        ),
      ),
      //AÇÃO EXCLUIR
      PopupMenuItem(
        value: ACAO_EXCLUIR,
        child: Row(
          children: const [
            Icon(Icons.delete, color: Colors.red),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Excluir'),
            ),
          ],
        ),
      ),
      //AÇÃO VISUALIZAR
      PopupMenuItem(
        value: ACAO_VISUALIZAR,
        child: Row(
          children: const [
            Icon(Icons.info, color: Colors.blue),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Visualizar'),
            ),
          ],
        ),
      ),
    ];

    //Abre o FORMS para cadastramento do novo ponto turistico
    void _abrirForm({PontoTuristico? turismo}){
      final key = GlobalKey<ConteudoFormDialogState>();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            turismo == null ? 'Novo Ponto Turistico' : 'Alterar Ponto Turistico ${turismo.id}',
          ),
          content: ConteudoFormDialog(
            key: key,
            turismoAtual: turismo,
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () {
                if (key.currentState?.dadosValidos() != true) {
                  return;
                }
                Navigator.of(context).pop();
                final novoTurismo = key.currentState!.novoTurismo;
                _dao.salvar(novoTurismo).then((success) {
                  if (success) {
                    _atualizarLista(); //_Atualizar lista foi feito depois
                  }
                });
              },
            ),
          ],
        ),
      );
    }

    //Exclui o ponto turistico e atualiza a tela
    void _excluir(PontoTuristico turismo){
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Atenção'),
              ),
            ],
          ),
          content: Text('Esse registro será removido definitivamente.'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                if (turismo.id == null) {
                  return;
                }
                _dao.remover(turismo.id!).then((success) {
                  if (success) {
                    _atualizarLista();
                  }
                });
              },
            ),
          ],
        ),
      );
    }

    void _abrirPaginaFiltro() async {
      final navigator = Navigator.of(context);
      final alterouValores = await navigator.pushNamed(FiltroPage.routeName);
      if (alterouValores == true) {
        _atualizarLista();
      }
    }

    void _abrirPaginaDetalhesTurismo(PontoTuristico turismo) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalhesTurismoPage(
              pontoturistico: turismo,
            ),
          )
      );
    }

    void _atualizarLista() async {
      setState(() {
        _carregando = true;
      });
      final prefs = await SharedPreferences.getInstance();
      final campoOrdenacao =
          prefs.getString(FiltroPage.chaveCampoOrdenacao) ?? PontoTuristico.fielId;
      final usarOrdemDecrescente =
          prefs.getBool(FiltroPage.chaveUsarOrdemDecrescente) == true;
      final filtroDescricao =
          prefs.getString(FiltroPage.chaveCampoDescricao) ?? '';
      final filtroDiferenciais =
          prefs.getString(FiltroPage.chaveCampoDiferenciais) ?? '';
      final filtroNome =
          prefs.getString(FiltroPage.chaveCampoNome) ?? '';
      final turismos = await _dao.listar(
        filtro: filtroDescricao,
        campoOrdenacao: campoOrdenacao,
        usarOrdemDecrescente: usarOrdemDecrescente,
      );
      setState(() {
        _turismos.clear();
        _carregando = false;
        if (turismos.isNotEmpty) {
          _turismos.addAll(turismos);
        }
      });
    }
}




















