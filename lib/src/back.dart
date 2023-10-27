import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'package:intl/intl.dart';

//dio package
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '/src/location.dart';

final box = Hive.box('appData');
late Dio dio;
late DioClient client;
const String credentialsEnc =
    'YcvkLhUhWeRFubJDmovkaKIafdzkdx6JIpynLBQznR9tsJeiakdsB5ss+tE7g3wr17N+NKRdLoThioDWWmWq0NZ1nID7+wgpfQvU9m+az/IeAyYvG8LHPQI3VGFaryo/QnO6TGALVnPRzvb5y75iD7D0jn4tcOtK6NPAplbFYBY';

enum UserType {
  agent,
  admin,
  installer,
  aginst,
  agentb2b,
  agentb2c,
  contractor,
  unknown
}

Future<bool> checkConnect(String? csrf) async {
  Response resp;
  bool isConnected = false;
  try {
    resp = await dio.get('/user/connected?_csrf=$csrf');
    isConnected = (resp.statusCode == 200) ? true : false;
  } on DioError catch (e) {
    if (e.response != null) {
      debugPrint('Ошибка клиента!');
      debugPrint('STATUS: ${e.response?.statusCode}');
      debugPrint('DATA: ${e.response?.data}');
      debugPrint('HEADERS: ${e.response?.headers}');
    } else {
      debugPrint('Ошибка при отправке запроса!');
      debugPrint(e.message);
    }
  }
  return isConnected;
}

Future<String> getCsrf() async {
  Response resp;
  resp = await dio.get('/csrfToken');
  return resp.data['_csrf'];
}

Future<String?> checkCsrf() async {
  String csrf;
  Response resp;
  if (box.containsKey('csrf')) {
    csrf = await box.get('csrf');
    if (await checkConnect(csrf) == false) {
      csrf = await getCsrf();
      await box.put('csrf', csrf);
    }
  } else {
    csrf = await getCsrf();
    await box.put('csrf', csrf);
  }
  return csrf;
}

Future<bool> auth({String? login, String? password}) async {
  String? log = login;
  String? pass = password;
  String? csrf = await checkCsrf();
  Map<String, dynamic> queryParameters = {
    '_csrf': csrf,
    'email': log,
    'password': pass
  };

  final redirected =
      await dio.post('/session/create', queryParameters: queryParameters);
  final response = await client
      .recRedirect(redirected.headers.value(HttpHeaders.locationHeader)!);
  if (response.statusCode == 200 && await checkConnect(csrf)) {
    setLastAuthSuccess(true);
    refreshData();
    return true;
  }
  return false;
}

Future<void> refreshData() async {
  String? csrf = await checkCsrf();
  fetchUserType(csrf);
  fetchNumbers(csrf);
  fetchUserData(csrf);
}

Future<bool> isAuthorised() async {
  bool signed;
  String? csrf;
  csrf = await checkCsrf().timeout(const Duration(seconds: 5), onTimeout: () {
    return null;
  });
  signed = await checkConnect(csrf).timeout(const Duration(seconds: 5),
      onTimeout: () {
    return false;
  });
  return signed;
}

class DioClient {
  final dio = Dio();

  Future<Dio> configureDio() async {
    Directory tempDir = await getTemporaryDirectory();
    var cookieJar = PersistCookieJar(
        ignoreExpires: true, storage: FileStorage(tempDir.path));
    dio.interceptors.add(CookieManager(cookieJar));

    // Set default configs
    dio.options.baseUrl = 'https://flow.it4us.ru';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    dio.options.followRedirects = false;
    dio.options.validateStatus =
        (status) => status != null && status >= 200 && status <= 400;
    return dio;
  }

  Future<Response<dynamic>> recRedirect(String url) async {
    Response redirected = await dio.get(url);
    Response response;
    if (redirected.statusCode! > 200 && redirected.statusCode! < 400) {
      response = await recRedirect(
          redirected.headers.value(HttpHeaders.locationHeader)!);
      return response;
    } else if (redirected.statusCode! == 200) {
      return redirected;
    } else {
      throw Exception('Невалидный запрос!');
    }
  }
}

Future<UserType> getUserType() async {
  var userType = box.get('userType');
  return userType;
}

Future<bool> getLastAuthSuccess() async {
  return await box.get('lastAuthSuccess');
}

void setLastAuthSuccess(bool result) async {
  await box.put('lastAuthSuccess', result);
}

void fetchUserType(String? csrf) async {
  Response resp =
      await dio.get('/user/jcurrent_user', queryParameters: {'_csrf': csrf});
  await box.put('userName', resp.data['name']);
  await box.put('userType', resp.data['type']);
}

void fetchUserData(String? csrf) async {
  String fullName, status;
  Response resp =
      await dio.get('/agent/jstatus', queryParameters: {'_csrf': csrf});
  var info = resp.data;
  fullName = info['name'];
  status = info['status'];
  box.put('fullName', fullName);
  box.put('status', status);
}

void setAgentStatus(bool curStatus) async {
  String? csrf = await checkCsrf();
  String chStatus = curStatus ? 'ON' : 'OFF';
  Map<String, dynamic> queryParameters = {'_csrf': csrf, 'status': chStatus};
  dio.post('/agent/ichange_status', queryParameters: queryParameters);
}

void fetchNumbers(String? csrf) async {
  Response resp = await dio.get('/callnumber/jlist?_csrf=$csrf');
  var numdata = resp.data;
  box.put('numberList', numdata);
}

void postGeopos() async {
  String? csrf = await checkCsrf();
  DateTime now = DateTime.now().toUtc();
  String formattedDate = now.toString();
  String? id = box.get('userID');
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  Map<String, dynamic> queryParameters = {
    '_csrf': csrf,
    'agent': id,
    'atime': formattedDate,
    'geometry': '[${position.latitude},${position.longitude}]'
  };
  Response resp =
      await dio.post('/point/create', queryParameters: queryParameters);
}

Future<String> setUserId() async {
  String? identifier = box.get('userName');
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    // если IOS
    var iosDeviceInfo = await deviceInfo.iosInfo;
    identifier = iosDeviceInfo.identifierForVendor;
  } else if (Platform.isAndroid) {
    // если Android
    const androidId = AndroidId();
    identifier = await androidId.getId();
  }
  return identifier!;
}

bool setStatus() {
  return (box.get('status') == 'OFF') ? false : true;
}

Future<bool> setDate({required DateTime date, required String? csrf}) async {
  Response resp;
  String strDate = date.toUtc().toString();
  resp = await dio.post('/session/setDate',
      queryParameters: {'_csrf': csrf, 'date': strDate});
  if (resp.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future<List<dynamic>> fetchOrders(
    {required DateTime start, required DateTime end}) async {
  Response resp;
  List<dynamic> orders;
  String str1Date = DateFormat('dd.MM.yyyy').format(start);
  String str2Date = DateFormat('dd.MM.yyyy').format(end);
  String? csrf = await checkCsrf();
  if (!start.isBefore(end)) {
    var per = start;
    start = end;
    end = per;
  }
  resp = await dio.get('/order/jtable',
      queryParameters: {'_csrf': csrf, 'date1': str1Date, 'date2': str2Date});
  orders = resp.data;
  return orders;
}

class Order {
  int? id;
  String? knNumber;
  String? lastMile;
  String? address;
  String? techData;
  String? assignedTime;
  String? assignedTimeEnd;
  List<dynamic>? extendedInfo;
  List<dynamic>? photos;
  String? agentName;
  String? status;
  String? account;
  String? customer;
  String? customerType;
  String? action;
  String? description;
  String? speedtests;
  String? actionLog;
  String? cableChannelSpended;
  String? cableChannelTime;

  Order(
      {this.id,
      this.knNumber,
      this.lastMile,
      this.address,
      this.techData,
      this.assignedTime,
      this.assignedTimeEnd,
      this.extendedInfo,
      this.photos,
      this.agentName,
      this.status,
      this.account,
      this.customer,
      this.customerType,
      this.action,
      this.description,
      this.speedtests,
      this.actionLog,
      this.cableChannelSpended,
      this.cableChannelTime});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    knNumber = json['kn_number'];
    lastMile = json['last_mile'];
    address = json['address'];
    techData = json['tech_data'];
    assignedTime = json['assigned_time'];
    assignedTimeEnd = json['assigned_time_end'];
    extendedInfo = json['extended_info'];
    photos = json['photos'];
    agentName = json['agent_name'];
    status = json['status'];
    account = json['account'];
    customer = json['customer'];
    customerType = json['customer_type'];
    action = json['action'];
    description = json['description'];
    speedtests = json['speedtests'];
    actionLog = json['action_log'];
    cableChannelSpended = json['cable_channel_spended'];
    cableChannelTime = json['cable_channel_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['kn_number'] = knNumber;
    data['last_mile'] = lastMile;
    data['address'] = address;
    data['tech_data'] = techData;
    data['assigned_time'] = assignedTime;
    data['assigned_time_end'] = assignedTimeEnd;
    if (extendedInfo != null) {
      data['extended_info'] =
          extendedInfo!.map((v) => v.toJson()).toList();
    }
    if (photos != null) {
      data['photos'] = photos!.map((v) => v.toJson()).toList();
    }
    data['agent_name'] = agentName;
    data['status'] = status;
    data['account'] = account;
    data['customer'] = customer;
    data['customer_type'] = customerType;
    data['action'] = action;
    data['description'] = description;
    data['speedtests'] = speedtests;
    data['action_log'] = actionLog;
    data['cable_channel_spended'] = cableChannelSpended;
    data['cable_channel_time'] = cableChannelTime;
    return data;
  }

}

//TODO
Future<List<dynamic>> setCurrOrders({required DateTime start, required DateTime end}) async {
  List<dynamic> orders;
  orders = await fetchOrders(start: start, end: end);
  box.put('ordersData', orders);
  return orders;
}

Future<dynamic> fetchOrderInfo() async{
  dynamic info;
  Response resp;
  String? csrf = await checkCsrf();
  resp = await dio.get('/order/jwatch', queryParameters: {'_csrf': csrf, 'id': 19600239});
  info = resp.data;
  return info;
}




