import 'package:flow/src/back.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

import 'appwindow.dart';

class TablePage extends StatefulWidget {
  const TablePage({
    Key? key,
    required this.orders,
  }) : super(key: key);
  final List<dynamic> orders;

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  late bool status;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заявки')),
      body: HorizontalDataTable(
        leftHandSideColumnWidth: 130,
        rightHandSideColumnWidth: 820,
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        leftSideItemBuilder: _generateFirstColumnRow,
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: widget.orders.length,
        rowSeparatorWidget: const Divider(
          color: Colors.black38,
          height: 1.0,
          thickness: 0.0,
        ),
        leftHandSideColBackgroundColor: const Color(0xFFFFFFFF),
        rightHandSideColBackgroundColor: const Color(0xFFFFFFFF),
        itemExtent: 61,
      ),
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('KN-номер', 130),
      _getTitleItemWidget('Статус', 120),
      _getTitleItemWidget('Адрес', 200),
      _getTitleItemWidget('Тип заказчика', 100),
      _getTitleItemWidget('Что сделать', 200),
      _getTitleItemWidget('Описание', 200),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      width: width,
      height: 56,
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AppWindow(knNumber: widget.orders[index]['kn_number'], info: widget.orders[index]['tech_data']);
            },
          ),
        );
      },
      child: Container(
        width: 120,
        height: 60,
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: Alignment.centerLeft,
        child: Text(widget.orders[index]['kn_number']),
      ),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    widget.orders[index]['status'] == 'Выполнена'
        ? status = true
        : status = false;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AppWindow(knNumber: widget.orders[index]['kn_number'], info: widget.orders[index]['tech_data']);
            },
          ),
        );
      },
      child: Row(
        children: <Widget>[
          Container(
            width: 120,
            height: 60,
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Icon(status ? Icons.done : Icons.notifications_active,
                    color: status ? Colors.green : Colors.red),
                Text(status ? 'Выполнена' : 'В работе')
              ],
            ),
          ),
          Container(
            width: 200,
            height: 60,
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            child: Text(widget.orders[index]['address']),
          ),
          Container(
            width: 100,
            height: 60,
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            child: Text(widget.orders[index]['customer_type']),
          ),
          Container(
            width: 200,
            height: 60,
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            child: Text(widget.orders[index]['action']),
          ),
          Container(
            width: 200,
            height: 60,
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            child: Text(widget.orders[index]['description']),
          ),
        ],
      ),
    );
  }
}
