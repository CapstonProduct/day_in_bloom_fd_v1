import 'dart:convert';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class CalendarWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final String encodedId;

  const CalendarWidget({
    super.key,
    required this.onDateSelected,
    required this.encodedId,
  });

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime? _focusedDay;
  DateTime? _selectedDay;
  final TextEditingController _dateController = TextEditingController();
  Map<String, Map<String, dynamic>> _markerMap = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _updateTextField();
    _fetchMarkersFromServer();
  }

  Future<void> _fetchMarkersFromServer() async {
    final encodedId = widget.encodedId; 

    debugPrint('📌 [Calendar] 전달받은 encodedId: $encodedId');
    
    if (encodedId.isEmpty) return;

    final uri = Uri.parse(
      'https://1dzzkwh851.execute-api.ap-northeast-2.amazonaws.com/Prod/calendar',
    ).replace(queryParameters: {'encodedId': encodedId});

    try {
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final List<dynamic> markerData = jsonDecode(response.body);
        setState(() {
          _markerMap = {
            for (var item in markerData)
              DateFormat('yyyy-MM-dd').format(DateTime.parse(item['date'])): {
                'marker_type': item['marker_type'],
                'has_report': item['has_report'] ?? false,
              }
          };
        });
      } else {
        debugPrint('마커 데이터 로드 실패: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('마커 API 호출 에러: $e');
    }
  }

  void _updateTextField() {
    if (_selectedDay != null) {
      _dateController.text = DateFormat('yyyy/MM/dd').format(_selectedDay!);
    }
  }

  void _onTextFieldSubmitted(String value) {
    try {
      DateTime parsedDate = DateFormat('yyyy/MM/dd').parse(value);
      final first = DateTime.utc(2020, 1, 1);
      final last = DateTime.utc(2060, 12, 31);

      if (parsedDate.isBefore(first) || parsedDate.isAfter(last)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⛔ 2020/01/01 ~ 2060/12/31 사이의 날짜를 입력해주세요.')),
        );
        parsedDate = parsedDate.isBefore(first) ? first : last;
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
            defaultBuilder: (context, date, _) {
              final key = DateFormat('yyyy-MM-dd').format(date);
              final data = _markerMap[key];

              final marker = data?['marker_type'];
              final hasReport = data?['has_report'];

              Widget dayText = Text(
                '${date.day}',
                style: TextStyle(color: Colors.black),
              );

              List<Widget> children = [dayText];

              if (hasReport != true) {
                children.add(
                  Opacity(
                    opacity: 0.6,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }

              if (marker != null && marker != 'none') {
                children.add(
                  Opacity(
                    opacity: 0.4,
                    child: Image.asset(
                      getImagePathFromMarker(marker),
                      width: 35,
                      height: 35,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              }

              return Stack(
                alignment: Alignment.center,
                children: children,
              );
            },
          ),
        ),
      ],
    );
  }
}

String getImagePathFromMarker(String marker) {
  switch (marker) {
    case 'seed':
      return 'assets/flower_phase/flower_phase0.png';
    case 'sprout':
      return 'assets/flower_phase/flower_phase1.png';
    case 'leaf':
      return 'assets/flower_phase/flower_phase2.png';
    case 'flowerbud':
      return 'assets/flower_phase/flower_phase3.png';
    case 'flower':
      return 'assets/flower_phase/flower_phase4.png';
    default:
      return '';
  }
}
