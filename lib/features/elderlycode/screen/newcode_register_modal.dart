import 'package:flutter/material.dart';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewCodeRegisterModal extends StatelessWidget {
  const NewCodeRegisterModal({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController codeController = TextEditingController();

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text(
        "어르신 코드 등록",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "어르신 고유 코드를 입력하세요.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: codeController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final inputCode = codeController.text.trim();
            final kakaoUserId = await KakaoAuthService.getUserId();
            final serverAccessToken = await KakaoAuthService.getServerAccessToken();

            if (inputCode.isEmpty || kakaoUserId == null || serverAccessToken == null) {
              print("입력값 누락 또는 인증 정보 없음");
              Navigator.pop(context);
              return;
            }

            final rootUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
            if (rootUrl == null || rootUrl.isEmpty) {
              print("ROOT_API_GATEWAY_URL 누락");
              Navigator.pop(context);
              return;
            }

            final apiUrl = Uri.parse('$rootUrl/$kakaoUserId/seniors');
            final body = {
              "seniors": [inputCode],
            };

            try {
              final prettyJson = const JsonEncoder.withIndent('  ').convert(body);
              print("전송할 JSON:\n$prettyJson");

              final response = await http.put(
                apiUrl,
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Basic $serverAccessToken",
                },
                body: jsonEncode(body),
              );

              if (response.statusCode == 201) {
                print("어르신 등록 성공");
              } else {
                print("등록 실패: ${response.statusCode}");
                print("응답 본문: ${response.body}");
              }
            } catch (e) {
              print("API 호출 오류: $e");
            }

            Navigator.pop(context, inputCode);
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
