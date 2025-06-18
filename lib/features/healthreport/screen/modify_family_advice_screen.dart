import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';

class ModifyFamilyAdviceScreen extends StatefulWidget {
  const ModifyFamilyAdviceScreen({super.key});

  @override
  _ModifyFamilyAdviceScreenState createState() => _ModifyFamilyAdviceScreenState();
}

class _ModifyFamilyAdviceScreenState extends State<ModifyFamilyAdviceScreen> {
  late TextEditingController _adviceController;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isInitialized = false;

  String? encodedId;
  String? reportDateRaw;
  String? elderlyName;

  @override
  void initState() {
    super.initState();
    _adviceController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final params = GoRouterState.of(context).uri.queryParameters;
      encodedId = params['encodedId'];
      reportDateRaw = params['date'];
      elderlyName = params['name'] ?? '어르신';
      _fetchExistingAdvice();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _adviceController.dispose();
    super.dispose();
  }

  Future<void> _fetchExistingAdvice() async {
    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    final token = await KakaoAuthService.getServerAccessToken();

    if (encodedId == null || reportDateRaw == null || baseUrl == null || token == null) {
      print("필수 파라미터 또는 인증 토큰 누락");
      setState(() => _isLoading = false);
      return;
    }

    final reportDate = reportDateRaw!.replaceAll(' ', '').replaceAll('/', '-');
    final kakaoUserId = await KakaoAuthService.getUserId();
    final uri = Uri.parse('$baseUrl/advice/own?encodedId=$encodedId&report_date=$reportDate&kakao_user_id=$kakaoUserId&role=guardian');

    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Basic $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final content = jsonDecode(utf8.decode(response.bodyBytes))['content'] ?? '';
        _adviceController.text = content;
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAdvice() async {
    final token = await KakaoAuthService.getServerAccessToken();
    if (token == null) return;

    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    final reportDate = reportDateRaw!.replaceAll(' ', '').replaceAll('/', '-');
    final uri = Uri.parse('$baseUrl/advice');

    final body = {
      "encodedId": encodedId,
      "report_date": reportDate,
      "role": "guardian",
      "content": _adviceController.text.trim(),
    };

    setState(() => _isSubmitting = true);
    try {
      final response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("조언이 저장되었습니다.")),
        );
        context.go(
          '/homeElderlyList/calendar/report/familyAdvice?date=$reportDateRaw&name=$elderlyName&encodedId=$encodedId',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("저장 실패: ${response.statusCode}")),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedDate = reportDateRaw ?? '날짜 없음';
    final name = elderlyName ?? '어르신';

    return Scaffold(
      appBar: CustomAppBar(title: "가족 조언 수정"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "가족으로서 어르신을 위한\n조언을 남겨주세요",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  Text("$name 어르신", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text("[ $displayedDate ]", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _adviceController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2.0)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2.5)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.green)
                      : ElevatedButton(
                          onPressed: _submitAdvice,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                          ),
                          child: const Text('수정 완료', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                ],
              ),
            ),
    );
  }
}
