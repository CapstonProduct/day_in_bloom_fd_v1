import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';

class InputUserInfoScreen extends StatefulWidget {
  const InputUserInfoScreen({super.key});

  @override
  State<InputUserInfoScreen> createState() => _InputUserInfoScreenState();
}

class _InputUserInfoScreenState extends State<InputUserInfoScreen> {
  final Map<String, TextEditingController> _controllers = {
    "이름": TextEditingController(),
    "생년월일": TextEditingController(),
    "주소": TextEditingController(),
    "전화번호": TextEditingController(),
  };

  String? _selectedGender;
  final List<String> _genders = ["남성", "여성"];
  static const primaryColor = Colors.teal;

  Future<void> _onComplete() async {
    if (_controllers.values.any((c) => c.text.trim().isEmpty) || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 정보를 입력해주세요.")),
      );
      return;
    }

    final kakaoUserId = await KakaoAuthService.getUserId();
    final serverAccessToken = await KakaoAuthService.getServerAccessToken();

    if (kakaoUserId == null || serverAccessToken == null) {
      print("user_id 또는 access_token을 불러올 수 없습니다.");
      return;
    }

    final body = {
      "username": _controllers["이름"]!.text.trim(),
      "birth_date": _controllers["생년월일"]!.text.trim(),
      "gender": _selectedGender,
      "address": _controllers["주소"]!.text.trim(),
      "phone_number": _controllers["전화번호"]!.text.trim(),
    };

    final prettyJson = const JsonEncoder.withIndent('  ').convert(body);
    print("전송할 사용자 정보 JSON:\n$prettyJson");

    try {
      final baseUrl = dotenv.env['USER_INFO_API_GATEWAY_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception(".env에서 USER_INFO_API_GATEWAY_URL 설정을 찾을 수 없습니다.");
      }

      final fullUrl = Uri.parse('$baseUrl/$kakaoUserId');
      final response = await http.put(
        fullUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic $serverAccessToken", 
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        await KakaoAuthService.setUserInfoEntered();
        if (context.mounted) context.go('/homeElderlyList');
      } else {
        print("사용자 정보 업데이트 실패: ${response.statusCode}");
        print("응답 본문: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버 오류: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("API 호출 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("서버와의 통신 중 오류가 발생했습니다.")),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Text(
                "보호자 또는 의사의\n사용자 정보를 입력해주세요",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              for (final entry in _controllers.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: entry.key,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: _genders
                    .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                decoration: InputDecoration(
                  labelText: "성별",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "입력하신 정보는 사용자 식별 및 의료 정보 연동에 사용됩니다.\n정확한 정보를 입력해주세요.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "입력 완료",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
