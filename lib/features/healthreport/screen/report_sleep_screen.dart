import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';

class ReportSleepScreen extends StatefulWidget {
  const ReportSleepScreen({super.key});

  @override
  State<ReportSleepScreen> createState() => _ReportSleepScreenState();
}

class _ReportSleepScreenState extends State<ReportSleepScreen> {
  late Future<Map<String, dynamic>> _reportData;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _reportData = _fetchReportData();
      _isInitialized = true;
    }
  }

  Future<Map<String, dynamic>> _fetchReportData() async {
    final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'];
    final reportDateRaw = GoRouterState.of(context).uri.queryParameters['date'];

    if (encodedId == null || reportDateRaw == null) {
      throw Exception('사용자 ID 또는 날짜 정보가 없습니다.');
    }

    final formattedDate = _formatDate(reportDateRaw);
    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception(".env에 ROOT_API_GATEWAY_URL이 설정되지 않았습니다.");
    }

    final uri = Uri.parse('$baseUrl/reports?encodedId=$encodedId&report_date=$formattedDate');
    final headers = {"Content-Type": "application/json"};

    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('API 호출 실패: ${response.body}');
    }

    return json.decode(utf8.decode(response.bodyBytes));
  }

  String _formatDate(String rawDate) {
    final sanitized = rawDate.replaceAll('/', '-').replaceAll(' ', '');
    final parsedDate = DateTime.parse(sanitized);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  Future<void> _refreshData() async {
    setState(() {
      _reportData = _fetchReportData();
    });
  }

  Future<String> _fetchSleepGraphUrl() async {
    try {
      final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'];
      final rawDate = GoRouterState.of(context).uri.queryParameters['date'];

      if (encodedId == null || rawDate == null) {
        throw Exception("사용자 ID 또는 날짜가 없습니다.");
      }

      final cleaned = rawDate.replaceAll('/', '-').replaceAll(' ', '');
      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(cleaned));

      final response = await http.post(
        Uri.parse('https://hrag4ozp99.execute-api.ap-northeast-2.amazonaws.com/default/get-graph-report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "encodedId": encodedId,
          "report_date": formattedDate,
          "graph_type": "sleep"
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("그래프 이미지 URL 요청 실패");
      }

      final result = jsonDecode(response.body);
      final url = result['cleanedUrl'];
      if (url == null) throw Exception("cleanedUrl이 응답에 없습니다.");
      return url;
    } catch (e, stack) {
      print('[ERROR] 예외 발생: $e');
      print('[STACKTRACE] $stack');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜 없음';
    final elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';
    const Color primaryColor = Color(0xFF41af7a);

    return Scaffold(
      appBar: CustomAppBar(title: "$elderlyName 어르신 건강 리포트"),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.green,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _reportData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            } else if (snapshot.hasError) {
              return Center(child: Text('에러 발생: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('데이터가 없습니다.'));
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      child: const Text("수면 분석 결과", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      // child: Image.asset(
                      //   'assets/remove_img/sleep_graph_ex.png',
                      //   fit: BoxFit.cover,
                      // ),
                      child: FutureBuilder<String>(
                        future: _fetchSleepGraphUrl(), // 이 함수 아래에 추가로 정의합니다
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return const Text('그래프를 불러올 수 없습니다.');
                          } else {
                            return Image.network(snapshot.data!, fit: BoxFit.cover);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildRowItem("수면 스코어", data['sleep_score']?.toString() ?? '-'),
                  _buildRowItem("예상 산소량 변화", data['spo2_variation']?.toString() ?? '-'),
                  _buildRowItem("수면 중 심박수", data['sleep_heart_rate']?.toString() ?? '-'),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selectedDate, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45)),
                        const SizedBox(height: 8),
                        Text(data['sleep_gpt_analysis'] ?? '분석 내용이 없습니다.', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRowItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF41af7a), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
