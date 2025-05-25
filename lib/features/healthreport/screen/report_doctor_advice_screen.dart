import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';

class ReportDoctorAdviceScreen extends StatefulWidget {
  const ReportDoctorAdviceScreen({super.key});

  @override
  State<ReportDoctorAdviceScreen> createState() => _ReportDoctorAdviceScreenState();
}

class _ReportDoctorAdviceScreenState extends State<ReportDoctorAdviceScreen> {
  late Future<List<Map<String, dynamic>>> _doctorAdviceList;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _doctorAdviceList = _fetchDoctorAdviceList();
      _isInitialized = true;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchDoctorAdviceList() async {
    final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'];
    final rawDate = GoRouterState.of(context).uri.queryParameters['date'];
    final token = await KakaoAuthService.getServerAccessToken();

    if (encodedId == null || rawDate == null) {
      throw Exception('필수 파라미터 누락');
    }

    final formattedDate = _formatDate(rawDate);
    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('ROOT_API_GATEWAY_URL 누락');
    }

    final url = Uri.parse('$baseUrl/advice?encodedId=$encodedId&report_date=$formattedDate&role=doctor');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      debugPrint("조언 API 실패: ${response.body}");
      return [];
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return List<Map<String, dynamic>>.from(decoded['comments'] ?? []);
  }

  String _formatDate(String rawDate) {
    final cleaned = rawDate.replaceAll(RegExp(r'\s+'), '').replaceAll('/', '-');
    final parsed = DateTime.parse(cleaned);
    return DateFormat('yyyy-MM-dd').format(parsed);
  }

  Future<void> _refreshAdvice() async {
    setState(() {
      _doctorAdviceList = _fetchDoctorAdviceList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜 없음';
    final elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';
    final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'];

    return Scaffold(
      appBar: CustomAppBar(title: "$elderlyName 어르신 건강 리포트"),
      body: RefreshIndicator(
        onRefresh: _refreshAdvice,
        color: Colors.green,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _doctorAdviceList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            } else if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "해당 날짜에 등록된 조언이 없거나\n네트워크가 불안정합니다.",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final adviceList = snapshot.data ?? [];

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      "의사 선생님 조언",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF41af7a),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        child: const Text("조언과 응원", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (adviceList.isEmpty)
                      const Text("조언 내용이 없습니다.", style: TextStyle(fontSize: 16, color: Colors.black87))
                    else
                      ...adviceList.map((advice) {
                        final author = advice['author'] ?? '익명';
                        final content = advice['content'] ?? '내용 없음';

                        return Container(
                          width: 350,
                          margin: const EdgeInsets.only(bottom: 20),
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
                              Text("👩‍⚕ $author", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(height: 8),
                              Text(content, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                            ],
                          ),
                        );
                      }).toList(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.go(
                          '/homeElderlyList/calendar/report/doctorAdvice/modifyDoctorAdvice?date=$selectedDate&name=$elderlyName&encodedId=$encodedId',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      child: const Text('조언 수정하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
