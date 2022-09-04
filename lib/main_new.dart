import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_ifpe/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';

import 'example_popup.dart';

class NewHomePage extends StatefulWidget {
  final XFile picture;
  final Marker marker;
  const NewHomePage({Key? key, required this.picture, required this.marker})
      : super(key: key);

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  List<Marker> _markers = [];
  List<LatLng> _points = [];

  final PopupController _popupLayerController = PopupController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                children: [
                  Flexible(
                    child: FlutterMap(
                      options: MapOptions(
                        center: LatLng(-8.89074, -36.4966),
                        zoom: 2,
                      ),
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
                            builder: (context) => const Icon(Icons.pin_drop),
                          ),
                          Marker(
                              point: LatLng(
                                  -8.045857068501272, -34.946622304194925),
                              builder: (context) => Image.file(
                                  File(widget.picture.path),
                                  fit: BoxFit.cover)),
                          Marker(
                            point: LatLng(32.810538, 130.707024),
                            builder: (context) => const Icon(
                              Icons.pin_drop,
                              color: Colors.blue,
                            ),
                          ),
                          Marker(
                            point:
                                LatLng(45.424086683990296, -75.70174554996494),
                            builder: (context) => const Icon(
                              Icons.pin_drop,
                              color: Colors.orange,
                            ),
                          ),
                        ];
                        for (var i = 0; i < _markers.length; i++) {
                          if (_markers[i] == widget.marker) {
                            _markers[i] = Marker(
                              point: _markers[i].point,
                              builder: (context) => Image.file(
                                  File(widget.picture.path),
                                  fit: BoxFit.cover),
                            );
                          }
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40)),
                    child: const Text("Where's CS?"),
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
