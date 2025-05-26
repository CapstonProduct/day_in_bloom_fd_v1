import 'package:flutter/material.dart';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewCodeRegisterModal extends StatefulWidget {
  const NewCodeRegisterModal({super.key});

  @override
  State<NewCodeRegisterModal> createState() => _NewCodeRegisterModalState();
}

class _NewCodeRegisterModalState extends State<NewCodeRegisterModal> {
  final TextEditingController validationCodeController = TextEditingController();
  String _selectedRole = 'guardian';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "보호자 및 의사 인증",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "어르신과 연결된\n보호자 및 의사용\n인증 코드를 입력하고\n역할을 선택하세요.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: validationCodeController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              hintText: '인증 코드 입력',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio<String>(
                value: 'guardian',
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const Text('보호자'),
              const SizedBox(width: 16),
              Radio<String>(
                value: 'doctor',
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const Text('의사'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final validationCode = validationCodeController.text.trim();
            final kakaoUserId = await KakaoAuthService.getUserId();
            final serverAccessToken = await KakaoAuthService.getServerAccessToken();

            if (validationCode.isEmpty || kakaoUserId == null || serverAccessToken == null) {
              print("❌ 입력값 누락 또는 인증 정보 없음");
              Navigator.pop(context);
              return;
            }

            final rootUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
            if (rootUrl == null || rootUrl.isEmpty) {
              print("❌ ROOT_API_GATEWAY_URL 누락");
              Navigator.pop(context);
              return;
            }

            final apiUrl = Uri.parse('$rootUrl/$kakaoUserId/seniors');
            final requestBody = {
              "associate_as": _selectedRole,
              "validation_code": validationCode,
            };

            try {
              final response = await http.put(
                apiUrl,
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Basic $serverAccessToken",
                },
                body: jsonEncode(requestBody),
              );

              if (response.statusCode == 201) {
                print("✅ 어르신 등록 성공");
              } else {
                final decodedError = utf8.decode(response.bodyBytes);
                print("❌ 등록 실패: ${response.statusCode}");
                print("응답 본문: $decodedError");
              }
            } catch (e) {
              print("❌ API 호출 오류: $e");
            }

            Navigator.pop(context, validationCode);
          },
          child: const Text(
            "확인",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
      ],
    );
  }
}