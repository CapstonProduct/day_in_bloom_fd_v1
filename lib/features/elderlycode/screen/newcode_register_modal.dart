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

  void _showLoadingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '어르신을 목록에\n추가하고 있습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '잠시만 기다려주세요...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

            _showLoadingModal();

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

              Navigator.pop(context);

              if (response.statusCode == 201) {
                print("어르신 등록 성공");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('어르신이 성공적으로 등록되었습니다.'),
                    backgroundColor: Colors.teal,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              } else {
                final decodedError = utf8.decode(response.bodyBytes);
                print("등록 실패: ${response.statusCode}");
                print("응답 본문: $decodedError");
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('등록에 실패했습니다. 다시 시도해주세요.'),
                    backgroundColor: Colors.red[400],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            } catch (e) {
              Navigator.pop(context);
              print("API 호출 오류: $e");
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('네트워크 오류가 발생했습니다.'),
                  backgroundColor: Colors.red[400],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
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