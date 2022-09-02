import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'example_popup.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _serviceEnabled; //verifica o GPS (on/off)
  late PermissionStatus _permissionGranted; //verificar a permissão de acesso
  List<Marker> _markers = [];
  List<LatLng> _points = [];
  final PopupController _popupLayerController = PopupController();
  LocationData? _userLocation;
  String? address;
  Future<void> _getUserLocation() async {
    Location location = Location();

    //1. verificar se o serviço de localização está ativado
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    //2. solicitar a permissão para o app acessar a localização
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final _locationData = await location.getLocation();

    Future<List<Geocoding.Placemark>> places;
    double? lat;
    double? lng;
    setState(() {
      _userLocation = _locationData;
      lat = _userLocation!.latitude;
      lng = _userLocation!.longitude;
      places = Geocoding.placemarkFromCoordinates(lat!, lng!,
          localeIdentifier: "pt_BR");
      places.then((value) {
        Geocoding.Placemark place = value[1];
        address = place.street; //nome da rua
        print(_locationData.accuracy); //acurácia da localização
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                child: Column(
                  children: [
                    Flexible(
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(-8.89074, -36.4966),
                          zoom: 2,
                        ),
                        // layers: [
                        // TileLayerOptions(
                        //     urlTemplate:
                        //         "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        //     subdomains: ['a', 'b', 'c']),
                        //   //MarkerLayerOptions(markers: _markers),
                        // PolylineLayerOptions(
                        //     polylineCulling: false,
                        //     polylines: [
                        //       Polyline(
                        //           points: [
                        //             LatLng(-8.89074, -36.4966),
                        //             LatLng(-8.045857068501272,
                        //                 -34.946622304194925),
                        //             LatLng(32.810538, 130.707024),
                        //             LatLng(45.424086683990296,
                        //                 -75.70174554996494),
                        //           ],
                        //           color: Colors.blue,
                        //           strokeWidth: 2.5,
                        //           borderStrokeWidth: 1.0,
                        //           borderColor: Colors.blueAccent)
                        //     ]),
                        // PopupMarkerLayerOptions(
                        //   popupController: _popupLayerController,
                        //   markers: _markers,
                        //   popupBuilder:
                        //       (BuildContext context, Marker marker) =>
                        //           ExamplePopup(marker),
                        // ),
                        //],
                        children: [
                          TileLayerWidget(
                            options: TileLayerOptions(
                                urlTemplate:
                                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c']),
                          ),
                          PolylineLayerWidget(
                            options: PolylineLayerOptions(
                                polylineCulling: false,
                                polylines: [
                                  Polyline(
                                      points: _points,
                                      color: Colors.blue,
                                      strokeWidth: 2.5,
                                      borderStrokeWidth: 1.0,
                                      borderColor: Colors.blueAccent)
                                ]),
                          ),
                          PopupMarkerLayerWidget(
                            options: PopupMarkerLayerOptions(
                              popupController: _popupLayerController,
                              markers: _markers,
                              markerRotateAlignment:
                                  PopupMarkerLayerOptions.rotationAlignmentFor(
                                      AnchorAlign.top),
                              popupBuilder:
                                  (BuildContext context, Marker marker) =>
                                      ExamplePopup(marker),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _points = [
                          LatLng(-8.89074, -36.4966),
                          LatLng(-8.045857068501272, -34.946622304194925),
                          LatLng(32.810538, 130.707024),
                          LatLng(45.424086683990296, -75.70174554996494),
                        ];
                        _markers = [
                          Marker(
                            point: LatLng(-8.89074, -36.4966),
                            builder: (context) => Icon(Icons.pin_drop),
                          ),
                          Marker(
                            point:
                                LatLng(-8.045857068501272, -34.946622304194925),
                            builder: (context) => Icon(
                              Icons.pin_drop,
                              color: Colors.red,
                            ),
                          ),
                          Marker(
                            point: LatLng(32.810538, 130.707024),
                            builder: (context) => Icon(
                              Icons.pin_drop,
                              color: Colors.blue,
                            ),
                          ),
                          Marker(
                            point:
                                LatLng(45.424086683990296, -75.70174554996494),
                            builder: (context) => Icon(
                              Icons.pin_drop,
                              color: Colors.orange,
                            ),
                          ),
                        ];
                      });
                    },
                    child: Text("Where's CS?"),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40)),
                  ),
                  if (_userLocation != null)
                    Text(
                      'LAT: ${_userLocation!.latitude}, LNG: ${_userLocation!.longitude}' +
                          "\n" +
                          "Endereço: " +
                          address!,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
