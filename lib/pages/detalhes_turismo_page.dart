import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import '../model/ponto_turistico.dart';
import 'mapa_interno.dart';

class DetalhesTurismoPage extends StatefulWidget {
  final PontoTuristico pontoturistico;

  const DetalhesTurismoPage({Key? key, required this.pontoturistico}) : super(key: key);

  @override
  _DetalhesTurismoPageState createState() => _DetalhesTurismoPageState();
}

class _DetalhesTurismoPageState extends State<DetalhesTurismoPage> {

  Position? _localizacaoAtual;
  var _distancia;

  String get _latitude => _localizacaoAtual?.latitude.toString() ?? '';
  String get _longitude => _localizacaoAtual?.longitude.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Turismo'),
      ),
      body: _criarBody(),
    );
  }

  Widget _criarBody() => Padding(
    padding: EdgeInsets.all(10),
    child: Column(
      children: [
        Row(
          children: [
            Campo(descricao: 'Código: '),
            Valor(valor: '${widget.pontoturistico.id}'),
          ],
        ),
        Row(
          children: [
            Campo(descricao: 'Nome: '),
            Valor(valor: widget.pontoturistico.nome),
          ],
        ),
        Row(
          children: [
            Campo(descricao: 'Descrição: '),
            Valor(valor: widget.pontoturistico.descricao),
          ],
        ),
        Row(
          children: [
            Campo(descricao: 'Data: '),
            Valor(valor: widget.pontoturistico.dataCadastroFormatado),
          ],
        ),
        Row(
          children: [
            Campo(descricao: 'Diferenciais: '),
            Valor(valor: widget.pontoturistico.diferenciais),
          ],
        ),
        Row(
          children: [
            Campo(descricao: 'Localização de cadastro: '),
            Valor(
              valor: 'Latitude: ${widget.pontoturistico.latitude}\nLongitude: ${widget.pontoturistico.longitude}',
            ),
            ElevatedButton(
                onPressed: _abrirCoordenadasNoMapaExterno,
                child: Icon(Icons.map)
            ),
            ElevatedButton(
                onPressed: _abrirCoordenadasNoMapaInterno,
                child: Icon(Icons.map)
            ),
          ],
        ),
        Row(
          children: [
            Campo(descricao: 'Localização Ponto Turístico: '),
            Valor(
              valor: widget.pontoturistico.localizacao,
            ),
            ElevatedButton(
                onPressed: _abrirNoMapaExterno,
                child: Icon(Icons.map)
            ),
          ],
        ),
        Row(
          children: [
            Campo(descricao: 'Cep: '),
            Valor(valor: widget.pontoturistico.cep),
          ],
        ),

        Row(
          children: [
            Campo(descricao: 'finalizada: '),
            Valor(valor: widget.pontoturistico.finalizada ? 'Sim' : 'Não'),
          ],
        ),
        // Row(
        //   children: [
        //     ElevatedButton(
        //         onPressed: _calcularDistancia,
        //         child: Icon(Icons.map)
        //     ),
        //     Campo(descricao: 'Calculo de distância: '),
        //     Valor(
        //       valor:  'Distância $_calcularDistancia',
        //     ),
        //   ],
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(
                Icons.route,
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Calculo da distância'),
              onPressed: _calcularDistancia,
            )
          ],
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(8), // Define um raio de borda para deixar os cantos arredondados
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              ' ${_localizacaoAtual == null ? "--" : _distancia}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  void _calcularDistancia(){
    _obterLocalizacaoAtual();
  }

  void _obterLocalizacaoAtual() async{
    bool servicoHabilitado = await _servicoHabilitado();
    if(!servicoHabilitado){
      return;
    }
    bool permissoesPermitidas = await _verificaPermissoes();
    if(!permissoesPermitidas){
      return;
    }
    Position posicao = await Geolocator.getCurrentPosition();
    setState(() {
      _localizacaoAtual = posicao;
      _distancia = Geolocator.distanceBetween(
          posicao.latitude,
          posicao.longitude,
          double.parse(widget.pontoturistico.latitude),
          double.parse(widget.pontoturistico.longitude));
      if(_distancia > 1000){
        var _distanciaKM = _distancia/1000;
        _distancia = "${double.parse((_distanciaKM).toStringAsFixed(2))}KM";
      }else{
        _distancia = "${_distancia.toStringAsFixed(2)}M";
      }
    });
  }

  Future<bool> _servicoHabilitado() async {
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      await _mostrarMensagemDialog(
          'Para utilizar este recurso, é '
              ' necessário acessar as configurações '
              ' para permitir a utilização do serviço de localização.'
      );
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }


  Future<bool> _verificaPermissoes() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        await _mostrarMensagemDialog('Falta de permissão');
        return false;
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      await _mostrarMensagemDialog(
          'Para utilizar este recurso,'
              ' é necessário acessar as configurações'
              ' para permitir a utilização do serviço de localização!!'
      );
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  Future<void> _mostrarMensagemDialog(String mensagem) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: Text(mensagem),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarMensagem(String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(mensagem)
        )
    );
  }

  void _abrirNoMapaExterno(){
    if (widget.pontoturistico.localizacao.isEmpty) {
      return;
    }
    MapsLauncher.launchQuery(widget.pontoturistico.localizacao);
  }

  void _abrirCoordenadasNoMapaExterno() {
    if (widget.pontoturistico.latitude.isEmpty || widget.pontoturistico.longitude.isEmpty ) {
      return;
    }
    MapsLauncher.launchCoordinates(double.parse(widget.pontoturistico.latitude), double.parse(widget.pontoturistico.longitude));
  }

  void _abrirCoordenadasNoMapaInterno(){
    if (widget.pontoturistico.latitude.isEmpty || widget.pontoturistico.longitude.isEmpty ){
      return;
    }
    Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) => MapaPage(
          latitude: double.parse(widget.pontoturistico.latitude), longitude: double.parse(widget.pontoturistico.longitude)
      ),
      ),
    );
  }
}

class Campo extends StatelessWidget {
  final String descricao;

  const Campo({Key? key, required this.descricao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Text(
        descricao,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class Valor extends StatelessWidget {
  final String valor;

  const Valor({Key? key, required this.valor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Text(valor),
    );
  }
}
