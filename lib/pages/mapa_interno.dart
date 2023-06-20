import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  MapaPage({Key? key, required this.latitude, required this.longitude}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final _controller = Completer<GoogleMapController>();
  StreamSubscription<Position>? _subscription;
  double _distancia = 0.0;

  @override
  void initState() {
    super.initState();
    _monitorarLocalizacao();
    _calcularDistancia();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _subscription = null;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usando Mapa Interno'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: {
                Marker(
                  markerId: MarkerId('1'),
                  position: LatLng(widget.latitude, widget.longitude),
                  infoWindow: InfoWindow(title: 'Destino'),
                ),
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitude, widget.longitude),
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: true,
            ),
          ),
          Text('Distância até o ponto turístico: ${_distancia.toStringAsFixed(2)} km'
          ),
        ],
      ),
    );
  }

  void _monitorarLocalizacao() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    _subscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position posicao) async {
        final controller = await _controller.future;
        final zoom = await controller.getZoomLevel();
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(posicao.latitude, posicao.longitude), zoom: zoom),
          ),
        );
        _calcularDistancia();
      },
    );
  }

  void _calcularDistancia() async {
    Position? localizacaoAtual = await Geolocator.getCurrentPosition();
    if (localizacaoAtual != null) {
      double distanciaEmMetros = await Geolocator.distanceBetween(
        localizacaoAtual.latitude,
        localizacaoAtual.longitude,
        widget.latitude,
        widget.longitude,
      );
      double distanciaEmKm = distanciaEmMetros / 1000;
      setState(() {
        _distancia = distanciaEmKm;
      });
    }
  }
}
