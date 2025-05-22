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
            final userId = await KakaoAuthService.getUserId();

            if (userId == null || inputCode.isEmpty) {
              print("입력값 누락: userId 또는 code");
              Navigator.pop(context);
              return;
            }

            final body = {
              "kakao_user_id": userId,
              "encodedId": inputCode,
            };

            final url = dotenv.env['NEWCODE_REGISTER_API_GATEWAY_URL'];
            if (url == null || url.isEmpty) {
              print("API URL 누락됨");
              Navigator.pop(context);
              return;
            }

            try {
              final prettyJson = const JsonEncoder.withIndent('  ').convert(body);
              print("전송할 JSON:\n$prettyJson");

              final response = await http.post(
                Uri.parse(url),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(body),
              );

              if (response.statusCode == 200) {
                print("등록 성공");
              } else {
                print("등록 실패: ${response.statusCode}");
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
