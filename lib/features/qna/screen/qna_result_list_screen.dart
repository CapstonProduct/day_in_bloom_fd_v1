import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class QnaResultListScreen extends StatefulWidget {
  const QnaResultListScreen({super.key});

  @override
  State<QnaResultListScreen> createState() => _QnaResultListScreenState();
}

class _QnaResultListScreenState extends State<QnaResultListScreen> {
  late DateTime _selectedWeek;
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _selectedWeek = DateTime.now();
    _weekDates = _generateWeekDates(_selectedWeek);
  }

  List<DateTime> _generateWeekDates(DateTime selectedDate) {
    DateTime startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  void _onWeekChanged(int weeksOffset) {
    setState(() {
      _selectedWeek = _selectedWeek.add(Duration(days: weeksOffset * 7));
      _weekDates = _generateWeekDates(_selectedWeek);
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedWeek,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedWeek) {
      setState(() {
        _selectedWeek = pickedDate;
        _weekDates = _generateWeekDates(_selectedWeek);
      });
    }
  }

  String _getFormattedWeekRange(DateTime date) {
    DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    return "${DateFormat('yyyy.MM.dd').format(startOfWeek)} ~ ${DateFormat('yyyy.MM.dd').format(endOfWeek)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "지난 건강 문답 분석결과"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => _onWeekChanged(-1),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getFormattedWeekRange(_selectedWeek),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, size: 20, color: Colors.green),
                        onPressed: () => _pickDate(context),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.black87),
                  onPressed: () => _onWeekChanged(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _weekDates.length,
              itemBuilder: (context, index) {
                String formattedDate = DateFormat('yyyy.MM.dd').format(_weekDates[index]);
                return GestureDetector(
                  onTap: () {
                    context.go('/homeQna/healthList/healthDetail', extra: _weekDates[index]);
                  },
                  child: Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.green.shade300, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "⭐ $formattedDate 분석결과",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
