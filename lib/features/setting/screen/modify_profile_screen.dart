import 'dart:convert';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';

class ModifyProfileScreen extends StatefulWidget {
  const ModifyProfileScreen({super.key});

  @override
  _ModifyProfileScreenState createState() => _ModifyProfileScreenState();
}

class _ModifyProfileScreenState extends State<ModifyProfileScreen> {
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _addressController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _phone3Controller = TextEditingController();

  final _nameFocus = FocusNode();
  final _birthFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _phone1Focus = FocusNode();
  final _phone2Focus = FocusNode();
  final _phone3Focus = FocusNode();

  final List<bool> _isLunarSelected = [true, false];
  final List<bool> _isGenderSelected = [true, false];

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _addressController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _phone3Controller.dispose();

    _nameFocus.dispose();
    _birthFocus.dispose();
    _addressFocus.dispose();
    _phone1Focus.dispose();
    _phone2Focus.dispose();
    _phone3Focus.dispose();
    super.dispose();
  }

  void _toggleLunarSelection(int index) {
    setState(() {
      for (int i = 0; i < _isLunarSelected.length; i++) {
        _isLunarSelected[i] = (i == index);
      }
    });
  }

  void _toggleGenderSelection(int index) {
    setState(() {
      for (int i = 0; i < _isGenderSelected.length; i++) {
        _isGenderSelected[i] = (i == index);
      }
    });
  }

  Future<void> _submitProfile() async {
    final kakaoUserId = await KakaoAuthService.getUserId();
    if (kakaoUserId == null) {
      debugPrint('사용자 ID 불러오기 실패');
      return;
    }

    final url = dotenv.env['MODIFY_PROFILE_API_GATEWAY_URL'];
    if (url == null || url.isEmpty) {
      debugPrint('.env에 MODIFY_PROFILE_API_GATEWAY_URL이 누락됨');
      return;
    }

    final body = {
      "kakao_user_id": kakaoUserId,
      "username": _nameController.text,
      "birth_date": _birthController.text,
      "gender": _isGenderSelected[0] ? "남성" : "여성",
      "address": _addressController.text,
      "phone_number":
          "${_phone1Controller.text}-${_phone2Controller.text}-${_phone3Controller.text}"
    };

    debugPrint("전송할 데이터:\n${const JsonEncoder.withIndent('  ').convert(body)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final responseBody = utf8.decode(response.bodyBytes);
      debugPrint("응답 상태: ${response.statusCode}");
      debugPrint("응답 본문: $responseBody");

      if (response.statusCode == 200) {
        if (context.mounted) context.go('/homeSetting/viewProfile');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint("네트워크 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '내 정보 수정', showBackButton: true),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildSection('기본 정보', [
              _buildTextField('이름         ', _nameController, _nameFocus, _birthFocus),
              _buildDateSelection(),
              _buildGenderSelection(),
              _buildTextField('주소         ', _addressController, _addressFocus, _phone1Focus),
              _buildPhoneNumberField(),
            ]),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _submitProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
              ),
              child: const Text(
                '수정 완료',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/profile_icon/green_profile.png'),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 15, color: Colors.grey),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text('이미지 삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, FocusNode focusNode,
      FocusNode? nextFocusNode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction:
                  nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
              onSubmitted: (_) {
                if (nextFocusNode != null) {
                  FocusScope.of(context).requestFocus(nextFocusNode);
                }
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField('생년월일  ', _birthController, _birthFocus, _addressFocus),
        ),
        const SizedBox(width: 10),
        ToggleButtons(
          borderRadius: BorderRadius.circular(8),
          constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
          isSelected: _isLunarSelected,
          onPressed: _toggleLunarSelection,
          children: const [Text('양력'), Text('음력')],
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      children: [
        const Text("성별         ", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        ToggleButtons(
          borderRadius: BorderRadius.circular(8),
          constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
          isSelected: _isGenderSelected,
          onPressed: _toggleGenderSelection,
          children: const [Text('남성'), Text('여성')],
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Row(
      children: [
        const Text("전화번호", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: _buildTextField('', _phone1Controller, _phone1Focus, _phone2Focus)),
        const SizedBox(width: 10),
        const Text("-"),
        Expanded(child: _buildTextField('', _phone2Controller, _phone2Focus, _phone3Focus)),
        const SizedBox(width: 10),
        const Text("-"),
        Expanded(child: _buildTextField('', _phone3Controller, _phone3Focus, null)),
      ],
    );
  }
}
