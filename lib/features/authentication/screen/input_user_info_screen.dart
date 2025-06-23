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
    "주소": TextEditingController(),
  };

  final _phonePart1Controller = TextEditingController();
  final _phonePart2Controller = TextEditingController();
  final _phonePart3Controller = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedBirthDate;
  final List<String> _genders = ["남성", "여성"];
  static const primaryColor = Colors.teal;
  bool _isLoading = false;

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _showLoadingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
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
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '사용자 정보를 저장 중입니다.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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

  void _hideLoadingModal() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _onComplete() async {
    if (_controllers.values.any((c) => c.text.trim().isEmpty) ||
        _selectedGender == null ||
        _selectedBirthDate == null ||
        _phonePart1Controller.text.trim().isEmpty ||
        _phonePart2Controller.text.trim().isEmpty ||
        _phonePart3Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 정보를 입력해주세요.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _showLoadingModal();

    try {
      final kakaoUserId = await KakaoAuthService.getUserId();
      final serverAccessToken = await KakaoAuthService.getServerAccessToken();

      if (kakaoUserId == null || serverAccessToken == null) {
        print("user_id 또는 access_token을 불러올 수 없습니다.");
        _hideLoadingModal();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final phoneNumber =
          "${_phonePart1Controller.text.trim()}-${_phonePart2Controller.text.trim()}-${_phonePart3Controller.text.trim()}";

      final body = {
        "username": _controllers["이름"]!.text.trim(),
        "birth_date": _formatDate(_selectedBirthDate!),
        "gender": _selectedGender,
        "address": _controllers["주소"]!.text.trim(),
        "phone_number": phoneNumber,
      };

      final prettyJson = const JsonEncoder.withIndent('  ').convert(body);
      print("전송할 사용자 정보 JSON:\n$prettyJson");

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

      _hideLoadingModal();

      if (response.statusCode == 200) {
        if (context.mounted) context.go('/homeElderlyList');
      } else {
        print("사용자 정보 업데이트 실패: ${response.statusCode}");
        print("응답 본문: ${response.body}");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("서버 오류: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      print("API 호출 실패: $e");
      _hideLoadingModal();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("서버와의 통신 중 오류가 발생했습니다.")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _phonePart1Controller.dispose();
    _phonePart2Controller.dispose();
    _phonePart3Controller.dispose();
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0, right: 12),
                      child: Text(
                        "전화번호",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: _phonePart1Controller,
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: "010",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text("-", style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: TextField(
                              controller: _phonePart2Controller,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: "1234",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text("-", style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: TextField(
                              controller: _phonePart3Controller,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: "5678",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: () => _selectBirthDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedBirthDate == null
                              ? "생년월일"
                              : _formatDate(_selectedBirthDate!),
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedBirthDate == null ? Colors.grey[600] : Colors.black,
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: primaryColor),
                      ],
                    ),
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
                  onPressed: _isLoading ? null : _onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading ? Colors.grey[400] : primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _isLoading ? "저장 중..." : "입력 완료",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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