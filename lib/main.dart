import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:camera/camera.dart';

import '/src/back.dart';
import '/src/services.dart';
import '/src/location.dart';
import '/src/camera.dart';
import '/src/calendar.dart';
import '/src/speedtest.dart';
import 'src/applications.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

bool authorised = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('appData');
  client = DioClient();
  dio = await client.configureDio();
  authorised = await isAuthorised();
  box.put('userID', await setUserId());

  //cameraInitialize
  //try {
  //  cameras = await availableCameras();
  //} on CameraException catch (e) {
  //  print('Error in fetching the cameras: $e');
  //}
  //final mainCamera = cameras.first;

  //timer for making points
  const oneMin = Duration(seconds: 60);
  Timer.periodic(oneMin, (Timer t) {
    if (box.get('status') == 'ON') postGeopos();
  });

  initializeDateFormatting().then((_) async => runApp(MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US'), Locale('ru', 'RU')],
        debugShowCheckedModeBanner: false,
        initialRoute: (authorised) ? '/firstScreen' : '/',
        routes: {
          '/': (context) => MyStatefulWidget(),
          '/firstScreen': (context) => CustomMap(),
        //  '/cameraScreen': (context) => CameraScreen(camera: mainCamera),
          '/appsScreen': (context) => Apps()
        },
      )));
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _AuthForm();
}

class _AuthForm extends State<MyStatefulWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController login = TextEditingController();
  TextEditingController password = TextEditingController();
  late bool _passwordVisible;

  @override
  void initState() {
    _passwordVisible = false;
    permissionCheck(context); // запрос доступа приложению к сервисам андроида
    super.initState();
  }

  @override
  void dispose() {
    login.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            title: const Text('Авторизация'),
            centerTitle: true,
          ),
      body: Form(
          key: _formKey,
          child: Padding(
              padding: const EdgeInsets.all(20),
              child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: login,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.isValidEmail()) {
                      return 'Некорректный Email';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(), labelText: 'Email'),
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  obscureText: !_passwordVisible,
                  controller: password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите правильный пароль';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Пароль',
                      suffixIcon: IconButton(
                        icon: Icon(_passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        color: Colors.grey,
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      )),
                ),
                Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width / 2,
                                  MediaQuery.of(context).size.height / 20),
                              alignment: Alignment.center),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              bool authRes = await auth(
                                  login: login.text, password: password.text);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: Text('Авторизация'),
                                      backgroundColor: Colors.green));
                              if (authRes) {
                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const CustomMap()));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Text('Ошибка авторизации'),
                                        backgroundColor: Colors.red));
                              }
                            }
                          },
                          child: const Text('Войти')),
                    ))
              ]))),
    );
  }
}
