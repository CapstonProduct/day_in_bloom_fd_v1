import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const CalendarWidget({super.key, required this.onDateSelected});

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime? _focusedDay;
  DateTime? _selectedDay;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _updateTextField();
  }

  void _updateTextField() {
    if (_selectedDay != null) {
      _dateController.text = DateFormat('yyyy/MM/dd').format(_selectedDay!);
    }
  }

  void _onTextFieldSubmitted(String value) {
    try {
      DateTime parsedDate = DateFormat('yyyy/MM/dd').parse(value);
      DateTime firstAllowedDate = DateTime.utc(2020, 1, 1);
      DateTime lastAllowedDate = DateTime.utc(2060, 12, 31);

      if (parsedDate.isBefore(firstAllowedDate) || parsedDate.isAfter(lastAllowedDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⛔ 2020/01/01 ~ 2060/12/31 사이의 날짜를 입력해주세요.')),
        );

        parsedDate = parsedDate.isBefore(firstAllowedDate) ? firstAllowedDate : lastAllowedDate;
      }

      setState(() {
        _selectedDay = parsedDate;
        _focusedDay = parsedDate;
      });
      _updateTextField();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('잘못된 날짜 형식입니다. (예: 2025/03/01)')),
      );
    }
  }


  Future<void> _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? DateTime.now(),
      firstDate: DateTime.utc(2020, 1, 1),
      lastDate: DateTime.utc(2060, 12, 31),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDay = pickedDate;
        _focusedDay = pickedDate;
      });
      _updateTextField();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: '날짜 입력 (YYYY/MM/DD)',
                  labelStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
                keyboardType: TextInputType.datetime,
                onSubmitted: _onTextFieldSubmitted,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.calendar_today),
              color: Colors.orange,
              onPressed: _showDatePicker,
            ),
          ],
        ),
        const SizedBox(height: 10),
        TableCalendar(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2060, 12, 31),
          focusedDay: _focusedDay ?? DateTime.now(),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = selectedDay;
            });
            _updateTextField();
            widget.onDateSelected(selectedDay);
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(fontSize: 12),
            weekendStyle: TextStyle(fontSize: 12, color: Colors.red),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, date, events) {
              if (date.day % 6 == 5) {
                return Center(
                  child: Text(
                    '${date.day}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              } else {
                return Center(
                  child: Image.asset(
                    getImagePath(date),
                    width: 35,
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

String getImagePath(DateTime date) {
  const images = {
    0: "assets/flower_phase/flower_phase0.png",
    1: "assets/flower_phase/flower_phase1.png",
    2: "assets/flower_phase/flower_phase2.png",
    3: "assets/flower_phase/flower_phase3.png",
    4: "assets/flower_phase/flower_phase4.png",
  };

  return images[date.day % 6] ?? "";
}
