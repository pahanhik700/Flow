import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'back.dart';

class AppWindow extends StatefulWidget {
  const AppWindow({super.key, required this.knNumber, required this.info});

  final String knNumber;
  final dynamic info;

  @override
  State<AppWindow> createState() => _AppWindowState();
}

class _AppWindowState extends State<AppWindow> {
  static const LatLng _center = LatLng(43.122249, 131.917066);
  GoogleMapController? _controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? selectedMarker;
  int _markerIdCounter = 1;
  LatLng? markerPosition;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'lib/src/assets/map-pin-100.png')
        .then((value) => {
              setState(() {
                markerIcon = value;
              })
            });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      rootBundle.loadString('lib/src/assets/map_style.json').then((mapStyle) {
        _controller?.setMapStyle(mapStyle);
      });
      addCustomIcon();
      super.initState();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Заявка №${widget.knNumber}'),
          centerTitle: true),
      body: SingleChildScrollView(
        child: Column(children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 120,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          alignment: Alignment.centerLeft,
                          backgroundColor:
                              const MaterialStatePropertyAll<Color>(
                                  Colors.green),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ))),
                      child: const Text('Взять в работу',
                          style: TextStyle(color: Colors.black, fontSize: 17))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 120,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        )),
                        backgroundColor:
                            const MaterialStatePropertyAll<Color>(Colors.grey),
                      ),
                      child: const Text('Выполнена успешно',
                          style: TextStyle(fontSize: 16))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 120,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        )),
                        backgroundColor:
                            const MaterialStatePropertyAll<Color>(Colors.grey),
                      ),
                      child: const Text('Перенос/Отмена',
                          style: TextStyle(fontSize: 17))),
                ),
              )
            ],
          ),
          orderTable(widget.info),
          SizedBox(
            width: 500,
            height: 600,
            child: GoogleMap(
                compassEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                myLocationEnabled: true,
                onMapCreated: _onMapCreated,
                scrollGesturesEnabled: true,
                gestureRecognizers: Set()
                  ..add(Factory<PanGestureRecognizer>(
                      () => PanGestureRecognizer())),
                initialCameraPosition:
                    const CameraPosition(target: _center, zoom: 12)),
          ),
        ]),
      ),
    );
  }

  Widget orderTable(dynamic info) {
    String str = '''{
        "car_num":"A123MT125RUS",
    "container_num":"123456789abcd",
    "enter_datetime":"2023-06-21 12:54:48",
    "pincode":"123",
    "destination_place_id":"123321",
    "destination_place_coord":[
    43.105970,
    131.900543
    ]
    }''';
    info = jsonDecode(str);
    const MarkerId markerId = MarkerId('sds');
    final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(info['destination_place_coord'][0], info['destination_place_coord'][1])
        );
    setState(() {
      markers[markerId] = marker;
    });
    return DataTable(
      columns: const [
        DataColumn(
            label: Text('Инмформация',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Данные',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(Text('Номер машины')),
          DataCell(Text(info['car_num'])),
        ]),
        DataRow(cells: [
          const DataCell(Text('Номер контейнера')),
          DataCell(Text(info['container_num'])),
        ]),
        DataRow(cells: [
          const DataCell(Text('Дата разгрузки')),
          DataCell(Text(info['enter_datetime'])),
        ]),
        DataRow(cells: [
          const DataCell(Text('ПИНКОД')),
          DataCell(Text(info['pincode'])),
        ]),
        DataRow(cells: [
          const DataCell(Text('id места')),
          DataCell(Text(info['destination_place_id'])),
        ]),
      ],
    );
  }
}
