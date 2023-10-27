import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

Future<Position> curLocation() async {
  Position curPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  return curPosition;
}
permissionCheck(BuildContext context) async {
  //SharedPreferences preferences = await SharedPreferences.getInstance();
  //await preferences.clear();
  PermissionStatus cameraStatus =
  await Permission.camera.request();
  PermissionStatus locationStatus =
  await Permission.location.request();
  await Permission.storage.request();
  if (locationStatus == PermissionStatus.granted) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Доступк к геолокации получен'),
            backgroundColor: Colors.green));
  }
  if (locationStatus == PermissionStatus.denied) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Для работы необходим доступ к геолокации'),
            backgroundColor: Colors.orangeAccent));
  }
  if (locationStatus ==
      PermissionStatus.permanentlyDenied) {
    openAppSettings();
  }
  if (cameraStatus == PermissionStatus.granted) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Доступ к камере получен'),
            backgroundColor: Colors.green));
  }
  if (cameraStatus == PermissionStatus.denied) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Для работы необходим доступ к камере'),
            backgroundColor: Colors.orangeAccent));
  }
  if (cameraStatus == PermissionStatus.permanentlyDenied){
    openAppSettings();
  }
}