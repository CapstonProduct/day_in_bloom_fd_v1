import 'dart:convert';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:intl/intl.dart';

class ReportDoctorAdviceScreen extends StatefulWidget {
  const ReportDoctorAdviceScreen({super.key});

  @override
  State<ReportDoctorAdviceScreen> createState() => _ReportDoctorAdviceScreenState();
}

class _ReportDoctorAdviceScreenState extends State<ReportDoctorAdviceScreen> {
  late Future<String> _advice;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _advice = _fetchAdvice();
      _isInitialized = true;
    }
  }

  Future<String> _fetchAdvice() async {
    final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'];
    debugPrint("encodedId: $encodedId");
    final rawDate = GoRouterState.of(context).uri.queryParameters['date'];
    final token = await KakaoAuthService.getServerAccessToken();

    if (encodedId == null || rawDate == null) {
      debugPrint("필수 쿼리 파라미터 누락: encodedId=$encodedId, rawDate=$rawDate");
      throw Exception('사용자 ID 또는 날짜가 누락되었습니다.');
    }

    final formattedDate = _formatDate(rawDate);
    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      debugPrint(".env에서 ROOT_API_GATEWAY_URL이 비어 있음");
      throw Exception(".env에 ROOT_API_GATEWAY_URL이 설정되지 않았습니다.");
    }

    final url = Uri.parse('$baseUrl/advice?encodedId=$encodedId&report_date=$formattedDate&role=doctor');
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Basic $token",
    };

    debugPrint("API 호출 URL: $url");
    debugPrint("요청 헤더: $headers");

    try {
      final response = await http.get(url, headers: headers);

      debugPrint("응답 상태 코드: ${response.statusCode}");
      debugPrint("응답 원본 바디: ${response.body}");

      final decodedBody = utf8.decode(response.bodyBytes);
      debugPrint("디코딩된 응답 바디: $decodedBody");

      if (response.statusCode != 200) {
        throw Exception("API 호출 실패: $decodedBody");
      }

      final data = jsonDecode(decodedBody);
      return data['content'] ?? '조언 내용이 없습니다.';
    } catch (e, stack) {
      debugPrint("예외 발생 during fetchAdvice: $e");
      debugPrint("스택트레이스: $stack");
      throw Exception("조언 데이터를 불러오는 중 오류 발생: $e");
    }
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

  Future<void> _refreshAdvice() async {
    setState(() {
      _advice = _fetchAdvice();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜 없음';
    final elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';

    return Scaffold(
      appBar: CustomAppBar(title: "$elderlyName 어르신 건강 리포트"),
      body: RefreshIndicator(
        onRefresh: _refreshAdvice,
        color: Colors.green,
        child: FutureBuilder<String>(
          future: _advice,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            } else if (snapshot.hasError) {
              return Center(child: Text("오류 발생: ${snapshot.error}"));
            }

            final content = snapshot.data ?? '조언 내용이 없습니다.';
            final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'];

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      "의사선생님 조언",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    _AdviceCard(date: selectedDate, content: content),
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
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
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

class _AdviceCard extends StatelessWidget {
  final String date;
  final String content;

  const _AdviceCard({required this.date, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
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
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45)),
                const SizedBox(height: 8),
                Text(content, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
