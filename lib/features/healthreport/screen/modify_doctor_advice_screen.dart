import 'dart:convert';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';

class ModifyDoctorAdviceScreen extends StatefulWidget {
  const ModifyDoctorAdviceScreen({super.key});

  @override
  _ModifyDoctorAdviceScreenState createState() => _ModifyDoctorAdviceScreenState();
}

class _ModifyDoctorAdviceScreenState extends State<ModifyDoctorAdviceScreen> {
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
    final uri = Uri.parse('$baseUrl/advice/own?encodedId=$encodedId&report_date=$reportDate&kakao_user_id=$kakaoUserId');

    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Basic $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final content = jsonDecode(utf8.decode(response.bodyBytes))['content'] ?? '';
        _adviceController.text = content;
      } else {
        print('기존 조언 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('조언 로드 중 오류: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _submitAdvice() async {
    final serverAccessToken = await KakaoAuthService.getServerAccessToken();
    if (serverAccessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("인증 정보를 불러올 수 없습니다.")),
      );
      return;
    }

    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    if (baseUrl == null || baseUrl.isEmpty || encodedId == null || reportDateRaw == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("필수 정보가 누락되었습니다.")),
      );
      return;
    }

    final reportDate = reportDateRaw!.replaceAll(' ', '').replaceAll('/', '-');
    final uri = Uri.parse('$baseUrl/advice');
    final body = {
      "encodedId": encodedId,
      "report_date": reportDate,
      "role": "doctor",
      "content": _adviceController.text.trim(),
    };

    print('--- PUT 요청 디버깅 ---');
    print('PUT URL: $uri');
    print('PUT Body: ${jsonEncode(body)}');
    print('PUT Header: Authorization: Basic $serverAccessToken');

    setState(() => _isSubmitting = true);
    try {
      final response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic $serverAccessToken",
        },
        body: jsonEncode(body),
      );

    print('응답 상태: ${response.statusCode}');
    print('응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("조언이 저장되었습니다.")),
        );
        context.go(
          '/homeElderlyList/calendar/report/doctorAdvice'
          '?date=$reportDateRaw&name=$elderlyName&encodedId=$encodedId',
        );
      }
      else {
        print("조언 저장 실패: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("저장 실패: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("예외 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("서버 통신 중 오류가 발생했습니다.")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedDate = reportDateRaw ?? '날짜 없음';
    final name = elderlyName ?? '어르신';

    return Scaffold(
      appBar: CustomAppBar(title: "조언 수정하기"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("환자분의 소중한 건강을 위해 조언을 수정하세요!",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 10),
                  Text("$name 어르신", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text("[ $displayedDate ]", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _adviceController,
                    maxLines: 15,
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
