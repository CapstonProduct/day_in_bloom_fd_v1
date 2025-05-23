import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';

class ReportTotalScoreScreen extends StatefulWidget {
  const ReportTotalScoreScreen({super.key});

  @override
  State<ReportTotalScoreScreen> createState() => _ReportTotalScoreScreenState();
}

class _ReportTotalScoreScreenState extends State<ReportTotalScoreScreen> {
  late Future<Map<String, dynamic>> _reportData;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _reportData = fetchReportData();
      _isInitialized = true;
    }
  }

  Future<Map<String, dynamic>> fetchReportData() async {
    final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'];
    final rawDate = GoRouterState.of(context).uri.queryParameters['date'];

    if (encodedId == null || rawDate == null) {
      throw Exception("사용자 ID 또는 날짜가 누락되었습니다.");
    }

    final formattedDate = _formatDate(rawDate);
    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception("ROOT_API_GATEWAY_URL이 .env에 설정되지 않았습니다.");
    }

    final url = Uri.parse('$baseUrl/reports?encodedId=$encodedId&report_date=$formattedDate');
    debugPrint("API 호출: $url");

    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode != 200) {
      throw Exception("API 호출 실패: ${response.body}");
    }

    return json.decode(response.body);
  }

  String _formatDate(String rawDate) {
    try {
      final cleaned = rawDate.replaceAll(RegExp(r'\s+'), '').replaceAll('/', '-');
      final parsed = DateTime.parse(cleaned);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      throw Exception("날짜 형식 오류: $rawDate");
    }
  }

  String formatMinutes(dynamic value) {
    int minutes;
    if (value is int) {
      minutes = value;
    } else if (value is String) {
      minutes = int.tryParse(value) ?? 0;
    } else {
      return '0분';
    }

    final hours = minutes ~/ 60;
    final remaining = minutes % 60;

    if (hours > 0) {
      return '$hours시간 ${remaining}분';
    } else {
      return '$remaining분';
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _reportData = fetchReportData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';

    return Scaffold(
      appBar: CustomAppBar(title: "$elderlyName 어르신 건강 리포트"),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.green,
        backgroundColor: Colors.white,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _reportData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            } else if (snapshot.hasError) {
              return Center(child: Text("오류 발생: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("데이터가 없습니다."));
            }

            final data = snapshot.data!;
            final int totalScore = int.tryParse(data['overall_health_score']?.toString() ?? '0') ?? 0;
            final String stress = '${data['stress_score']?.toString() ?? "0"}점';
            final String exercise = formatMinutes(data['total_exercise_time']);
            final String sleep = formatMinutes(data['total_sleep_time']);

            final List<Map<String, String>> healthData = [
              {'label': '스트레스 점수', 'value': stress},
              {'label': '운동 시간', 'value': exercise},
              {'label': '수면 시간', 'value': sleep},
            ];

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "전체 종합 점수",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 50),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: totalScore / 100,
                          strokeWidth: 3,
                          backgroundColor: Colors.blue[100],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue,
                              spreadRadius: 5,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "$totalScore",
                            style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: healthData.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              healthData[index]['label']!,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black45),
                            ),
                            Text(
                              healthData[index]['value']!,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
