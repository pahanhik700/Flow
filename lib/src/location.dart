import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flow/main.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import '/src/calendar.dart';
import '/src/speedtest.dart';
import 'back.dart';
import 'camera.dart';
import 'help.dart';
import 'applications.dart';

late bool workMark;

enum MenuItems { item1, item2, item3, item4, item5, item6 }

class CustomMap extends StatefulWidget {
  const CustomMap({Key? key}) : super(key: key);

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  GoogleMapController? _controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? selectedMarker;
  int _markerIdCounter = 1;
  LatLng? markerPosition;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  void addCustomIcon(){
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'lib/src/assets/map-pin-100.png')
        .then((value) => {
          setState((){
            markerIcon = value;
          })
    });
  }
  static const LatLng _center =
      LatLng(43.122249, 131.917066); //LatLng(48.864716, 2.349014);
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
  void initState() {
    refreshData();
    workMark = setStatus();
    _addPoint();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _addPoint() {
    List<dynamic>? orders = box.get('ordersData');
    if(orders != null){
      final int markerCount = orders.length;
      if (markerCount == 100) {
        return;
      }
      for (var element in orders) {
        final String markerIdVal = 'marker_id_$_markerIdCounter';
        final MarkerId markerId = MarkerId(markerIdVal);
        final Marker marker = Marker(
            markerId: markerId,
            position: LatLng(element['geometry'][0], element['geometry'][1]),
            infoWindow: InfoWindow(
                title: element['action'], snippet: element['description']),
            icon: markerIcon);
        _markerIdCounter++;
        setState(() {
          markers[markerId] = marker;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: const Padding(
          padding: EdgeInsets.only(top: 85),
          child: ReadyButton(),
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Добрый день!\n${box.get('fullName')}'),
          actions: [
            IconButton(
                onPressed: () async {
                  refreshData();
                  Timer(const Duration(milliseconds: 500), () {
                    Navigator.popAndPushNamed(context, '/firstScreen');
                  });
                },
                icon: const Icon(Icons.refresh)),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Calendar()));
                },
                icon: const Icon(Icons.calendar_month_outlined)),
            PopupMenuButton<MenuItems>(
                onSelected: (value) {
                  if (value == MenuItems.item1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WebViewSpeed()),
                    );
                  }
                  if (value == MenuItems.item2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyStatefulWidget()),
                    );
                    box.delete('csrf');
                    dio.get('/session/destroy');
                  }
                  if (value == MenuItems.item6) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpPage()),
                    );
                  }
                },
                itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: MenuItems.item1,
                          child: Text('Проверить скорость')),
                      const PopupMenuItem(
                          value: MenuItems.item2,
                          child: Text('Сменить пользователя')),
                      //const PopupMenuItem(
                      //    value: MenuItems.item3,
                      //    child: Text('Авторизация WFM')),
                      //const PopupMenuItem(
                      //    value: MenuItems.item4, child: Text('Настройки')),
                      //const PopupMenuItem(
                      //    value: MenuItems.item5, child: Text('Помощь')),
                      const PopupMenuItem(
                          value: MenuItems.item6, child: Text('О приложении'))
                    ])
          ],
        ),
        body: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              GoogleMap(
                compassEnabled: false,
                zoomControlsEnabled: false,
                padding: const EdgeInsets.only(bottom: 100),
                mapType: MapType.normal,
                myLocationEnabled: true,
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: _center,
                  zoom: 12,
                ),
                markers: Set<Marker>.of(markers.values),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    FloatingActionButton(
                        heroTag: 'btn1',
                        onPressed: () {
                          fetchOrderInfo();
                          box.delete('ordersData');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Apps()));
                        },
                        child: const Icon(Icons.format_list_bulleted_sharp)),
                    const Spacer(),
                    FloatingActionButton(
                      heroTag: 'btn2',
                      onPressed: () async {},
                      backgroundColor: const Color(0xff212a5e),
                      child: const Icon(Icons.camera_alt_outlined),
                    ),
                    const Spacer(),
                    FloatingActionButton(
                        heroTag: 'btn4',
                        child: const Icon(Icons.phone),
                        onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                title: const Text('Доступные номера'),
                                content: showNumbersInfo())))
                  ],
                ),
              )
            ]));
  }
}

class ReadyButton extends StatefulWidget {
  const ReadyButton({Key? key}) : super(key: key);

  @override
  State<ReadyButton> createState() => _ReadyButtonState();
}

class _ReadyButtonState extends State<ReadyButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'btn3',
      onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: workMark
              ? const Text('Завершение дня')
              : const Text('Готовность к работе'),
          content: workMark
              ? const Text('Подтвердите завершение дня!')
              : const Text('Подтвердите готовность к работе!'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Отмена')),
            TextButton(
              onPressed: () async {
                setState(() {
                  workMark = !workMark;
                });
                setAgentStatus(workMark);
                Navigator.of(context).pop();
              },
              child: const Text('Подтверждаю'),
            )
          ],
        ),
      ),
      backgroundColor: workMark ? Colors.red : Colors.green,
      child: workMark ? const Text('Стоп') : const Text('Пуск'),
    );
  }
}

Widget showNumbersInfo() {
  List<dynamic> map = box.get('numberList');
  return SizedBox(
    height: 400.0,
    width: 300.0,
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: map.length,
      itemBuilder: (BuildContext context, int i) {
        return Container(
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.grey, width: 1.5))),
          child: ListTile(
            leading: const Icon(Icons.account_box_outlined),
            title: Text(map[i]['description']),
            subtitle: Text(map[i]['telb']),
            onTap: () {
              UrlLauncher.launch("tel://${map[i]['telb']}");
            },
          ),
        );
      },
    ),
  );
}

class AppLatLong {
  final double lat;
  final double long;

  const AppLatLong({required this.lat, required this.long});
}
