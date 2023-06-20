import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../model/cep_model.dart';
import '../model/ponto_turistico.dart';
import '../services/cep_service.dart';

class ConteudoFormDialog extends StatefulWidget{
  final PontoTuristico? turismoAtual;
  ConteudoFormDialog({Key? key, this.turismoAtual}) : super (key: key);

  @override
  ConteudoFormDialogState createState() => ConteudoFormDialogState();
}

class ConteudoFormDialogState extends State<ConteudoFormDialog> {
  final _service = CepService();
  final _cepFormater = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {'#' : RegExp(r'[0-9]')}
  );
  var _loading = false;
  Endereco? _cep;

  Position? _localizacaoAtual;
  final _controller = TextEditingController();

  String get _textoLocalizacao => _localizacaoAtual == null ? '' :
  'Latitude: ${_localizacaoAtual!.latitude}  |  Longitude: ${_localizacaoAtual!.longitude}';

  String get _latitude => _localizacaoAtual?.latitude.toString() ?? '';
  String get _longitude => _localizacaoAtual?.longitude.toString() ?? '';

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaooController = TextEditingController();
  final _diferenciaisController = TextEditingController();
  final _dataController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _longitudeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _cepController = TextEditingController();

  //Inicia todas os campos
  @override
  void iniState(){
    super.initState();
    if (widget.turismoAtual != null){
      _nomeController.text = widget.turismoAtual!.nome;
      _diferenciaisController.text = widget.turismoAtual!.diferenciais;
      _descricaooController.text = widget.turismoAtual!.descricao;
      _dataController.text = widget.turismoAtual!.dataCadastroFormatado;
      _longitudeController.text = widget.turismoAtual!.longitude;
      _latitudeController.text = widget.turismoAtual!.latitude;
      _localizacaoController.text = widget.turismoAtual!.localizacao;
      _cepController.text = widget.turismoAtual!.cep;
    };
  }

  Widget build(BuildContext context){
    return Form(
        key: _formKey,
        child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today),
                Text("Data: ${_dataController.text.isEmpty ? _dateFormat.format(DateTime.now()) : _dataController.text}")
              ],
            ),
            Divider(color: Colors.white,),
            //Campo para receber o nome do ponto turistico
            TextFormField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
              validator: (String? valor){
                if (valor == null || valor.isEmpty){
                  return 'Informe o nome:';
                }
                return null;
              },
            ),
            //Campo para receber a descrição do ponto turistico
            TextFormField(
              controller: _descricaooController,
              decoration: InputDecoration(labelText: 'Descrição'),
              validator: (String? valor){
                if (valor == null || valor.isEmpty){
                  return 'Informe a descrição:';
                }
                return null;
              },
            ),
            //Campo para receber o diferencial do ponto turistico
            TextFormField(
              controller: _diferenciaisController,
              decoration: InputDecoration(labelText: 'Diferenciais'),
              validator: (String? valor){
                if (valor == null || valor.isEmpty){
                  return 'Informe os diferenciais:';
                }
                return null;
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: _cepController,
                decoration: InputDecoration(
                  labelText: 'CEP',
                  suffixIcon: _loading ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ) : IconButton(
                    onPressed: _findCep,
                    icon: const Icon(Icons.search),
                  ),
                ),
                inputFormatters: [_cepFormater],
                validator: (String? value){
                  if(value == null || value.isEmpty ||
                      !_cepFormater.isFill()){
                    return 'Informe um cep válido!';
                  }
                  return null;
                },
              ),
            ),
            Container(height: 10),
            ..._buildWidgets(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: _localizacaoController,
                decoration: InputDecoration(
                    labelText: 'Nome do Ponto Turistico',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.map),
                      tooltip: 'Abrir no mapa',
                      onPressed: _abrirNoMapaExterno,
                    )
                ),
              ),
            ),
            Divider(color: Colors.white,),
            ElevatedButton(
              child: Text('Obter Localização Atual'),
              onPressed: _obterLocalizacaoAtual,
            ),
            if(_localizacaoAtual != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [Expanded(child: Text(_textoLocalizacao),),ElevatedButton(onPressed: _abrirCoordenadasNoMapaExterno,child: Icon(Icons.map)),],
                ),
              ),
            ],
        ),
        )
        );
  }
  bool dadosValidos() => _formKey.currentState?.validate() == true;

  PontoTuristico get novoTurismo => PontoTuristico(
      id: widget.turismoAtual?.id ?? 0,
      nome: _nomeController.text,
      descricao: _descricaooController.text,
      diferenciais: _diferenciaisController.text,
      latitude: _latitude,
      longitude: _longitude,
      localizacao: _localizacaoController.text,
      cep: _cepController.text,
      dataCadastro: DateTime.now()
  );

  void _abrirNoMapaExterno(){
    if(_localizacaoController.text.trim().isEmpty){
      return;
    }
    MapsLauncher.launchQuery(_localizacaoController.text);
  }

  //Permissões permitidas
  Future<bool> _permissoesPermitidas() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if(permissao == LocationPermission.denied){
        _mostrarMensagem('Não será possível utilizar o recusro por falta de permissão');
        return false;
      }
    }
    if(permissao == LocationPermission.deniedForever){
      await _mostrarMensagemDialog(
          'Para utilizar esse recurso, você deverá acessar as configurações '
              'do app permitir a utilização do serviço de localização');
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  //Obtém a localização atual
  void _obterLocalizacaoAtual() async {
    bool servicoHabilitado = await _servicoHabilitado();
    if(!servicoHabilitado){
      return;
    }
    bool permissoesPermitidas = await _permissoesPermitidas();
    if(!permissoesPermitidas){
      return;
    }
    _localizacaoAtual = await Geolocator.getCurrentPosition();
    setState(() {

    });
  }

  void _abrirCoordenadasNoMapaExterno() {
    if(_localizacaoAtual == null){
      return;
    }
    MapsLauncher.launchCoordinates(_localizacaoAtual!.latitude, _localizacaoAtual!.longitude);
  }


  Future<bool> _servicoHabilitado() async {
    bool servicoHabilotado = await Geolocator.isLocationServiceEnabled();
    if(!servicoHabilotado){
      await _mostrarMensagemDialog('Para utilizar esse recurso, você deverá habilitar o serviço de localização '
          'no dispositivo');
      Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }


  Future<void> _mostrarMensagemDialog(String mensagem) async{
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Atenção'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _mostrarMensagem(String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  List<Widget> _buildWidgets(){
    final List<Widget> widgets = [];
    if(_cep != null){
      final map = _cep!.toJson();
      for(final key in map.keys){
        widgets.add(Text('$key:  ${map[key]}'));

      }
    }
    return widgets;
  }
  Future<void> _findCep() async {
    if(_formKey.currentState == null || !_formKey.currentState!.validate()){
      return;
    }
    setState(() {
      _loading = true;
    });
    try{
      _cep = await _service.findCepAsObject(_cepFormater.getUnmaskedText());
    }catch(e){
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ocorreu um erro, tente noavamente! \n'
              'ERRO: ${e.toString()}')
      ));
    }
    setState(() {
      _loading = false;
    });
  }
}