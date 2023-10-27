import 'dart:async';
import 'package:flow/src/location.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'back.dart';
import 'package:flow/src/orderstable.dart';

class Apps extends StatefulWidget {
  const Apps({Key? key}) : super(key: key);

  @override
  State<Apps> createState() => _AppsState();
}

class _AppsState extends State<Apps> {
  late DateTime firstDate;
  late DateTime lastDate;
  List<Map<String, dynamic>> orders = [];

  //Future<bool> _onWillPop() async {
  //  return (await showDialog(
  //    context: context,
  //    builder: (context) => AlertDialog(
  //      title: const Text('Are you sure?'),
  //      content: const Text('Do you want to exit an App'),
  //      actions: <Widget>[
  //        TextButton(
  //          onPressed: () => Navigator.of(context).pop(false),
  //          child: const Text('No'),
  //        ),
  //        TextButton(
  //          onPressed: () => Navigator.of(context).pop(true),
  //          child: const Text('Yes'),
  //        ),
  //      ],
  //    ),
  //  )) ?? false;
  //}

  @override
  void initState() {
    workMark = setStatus();
    var checkD1 = box.get('firstDate');
    var checkD2 = box.get('lastDate');

    if( (checkD1 == null) && (checkD2 == null)){
      firstDate = DateTime.now();
      lastDate = firstDate;
    }else{
      firstDate = checkD1;
      lastDate = checkD2;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Ваши заявки'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                refreshData();
                Timer(const Duration(milliseconds: 500), () {
                  Navigator.popAndPushNamed(context, '/appsScreen');
                });
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              width: 350,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  onPressed: () {
                    showDialog(
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
                    );
                  },
                  child: workMark
                      ? const Text('Завершить рабочий день')
                      : const Text('Начать рабочий день')),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Заявки c ',
                  style: TextStyle(color: Colors.blueGrey),
                ),
                OutlinedButton(
                    onPressed: () async {
                      DateTime? newDate = await dateWidget(context);
                      if (newDate == null) return;
                      box.put('firstDate', newDate);
                      setState(() {
                        firstDate = newDate;
                      });
                    },
                    child: Text(DateFormat('dd.MM.yyyy').format(firstDate),
                        style: const TextStyle(color: Colors.black54))),
                const Text(' по ', style: TextStyle(color: Colors.blueGrey)),
                OutlinedButton(
                    onPressed: () async {
                      DateTime? newDate = await dateWidget(context);
                      if (newDate == null) return;
                      box.put('lastDate', newDate);
                      setState(() {
                        lastDate = newDate;
                      });
                    },
                    child: Text(DateFormat('dd.MM.yyyy').format(lastDate),
                        style: const TextStyle(color: Colors.black54))),
              ],
            ),
            _getTableButton(
              start: firstDate,
              end: lastDate
            )
          ],
        ),
      ),
    );
  }



  Widget _getTableButton({required DateTime start, required DateTime end}) {
    return ElevatedButton(
      onPressed: () async {
        await setCurrOrders(start: start, end: end).then((value) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return TablePage(
                  orders: value,
                );
              },
            ),
          );
        });
      },
      child: const Text(
        'Получить заявки',
      ),
    );
  }
}

Future<DateTime?> dateWidget(BuildContext context) async {
  return showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.black54,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black54, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      locale: const Locale('ru', 'RU'),
      initialDate: DateTime.now(),
      firstDate: DateTime.utc(2018, 1, 1),
      lastDate: DateTime.utc(2030, 3, 14));
}

