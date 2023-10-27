import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late Map<DateTime, List<Event>> events;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
      ),
      body: const Column(
        children: [
          Card(
              margin: EdgeInsets.all(8.0),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  side: BorderSide(color: Colors.grey, width: 2.0)),
              child: CalendarTable()),
        ],
      ),
    );
  }
}

class CalendarTable extends StatefulWidget {
  const CalendarTable({Key? key}) : super(key: key);

  @override
  State<CalendarTable> createState() => _CalendarTableState();
}

class _CalendarTableState extends State<CalendarTable> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late TextEditingController _controller;

  loadWorkEvents() async {
    ////TODO load events from base
  }

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2018, 1, 1),
      lastDay: DateTime.utc(2030, 3, 14),
      locale: 'ru_RU',
      rowHeight: 60,
      daysOfWeekHeight: 40,
      shouldFillViewport: false,
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      headerStyle: const HeaderStyle(
        titleCentered: true,
        //titleTextStyle: TextStyle(color: Color(0xFFFFFcF9), fontSize: 20.0),
        decoration: BoxDecoration(
            //color: Color(0xff0288d1),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        formatButtonTextStyle:
            TextStyle(color: Color(0xFFFF6978), fontSize: 16.0),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          size: 30,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          size: 30,
        ),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
          weekendStyle: TextStyle(color: Colors.redAccent, fontSize: 16),
          weekdayStyle: TextStyle(fontSize: 16)),
      calendarStyle: const CalendarStyle(
          tableBorder:
              TableBorder(horizontalInside: BorderSide(color: Colors.grey)),
          weekendTextStyle: TextStyle(color: Colors.redAccent, fontSize: 16),
          defaultTextStyle: TextStyle(fontSize: 16),
          todayDecoration:
              BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
          selectedDecoration:
              BoxDecoration(color: Color(0xff0288d1), shape: BoxShape.circle)),
      eventLoader: (day) {
        return _getEventsForDay(day);
      },
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  _showAddDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: _controller,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {},
                  child: const Text('Добавить'),
                )
              ],
            ));
  }
}

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

final kEvents = LinkedHashMap(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

List<Event> _getEventsForDay(DateTime day) {
  return kEvents[day] ?? [];
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

final _kEventSource = {
  for (var item in List.generate(50, (index) => index))
    DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5): List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}'))
}..addAll({
    kToday: [
      const Event('Today\'s Event 1'),
      const Event('Today\'s Event 2'),
    ],
  });

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
