import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
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

  final List<bool> _isLunarSelected = [true, false];
  final List<bool> _isGenderSelected = [true, false];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final kakaoUserId = await KakaoAuthService.getUserId();
    final serverAccessToken = await KakaoAuthService.getServerAccessToken();

    if (kakaoUserId == null || serverAccessToken == null) return;

    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    if (baseUrl == null || baseUrl.isEmpty) return;

    final url = Uri.parse('$baseUrl/$kakaoUserId');

    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Basic $serverAccessToken",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _nameController.text = data['username'] ?? '';
          _birthController.text = data['birth_date'] ?? '';
          _addressController.text = data['address'] ?? '';
          final phone = (data['phone_number'] ?? '').split('-');
          if (phone.length == 3) {
            _phone1Controller.text = phone[0];
            _phone2Controller.text = phone[1];
            _phone3Controller.text = phone[2];
          }
          final gender = data['gender'] ?? '';
          _isGenderSelected[0] = gender == '남성';
          _isGenderSelected[1] = gender == '여성';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("프로필 불러오기 실패: $e");
    }
  }

  Future<void> _submitProfile() async {
    final kakaoUserId = await KakaoAuthService.getUserId();
    final serverAccessToken = await KakaoAuthService.getServerAccessToken();

    if (kakaoUserId == null || serverAccessToken == null) return;

    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    if (baseUrl == null || baseUrl.isEmpty) return;

    final phoneNumber =
        "${_phone1Controller.text.trim()}-${_phone2Controller.text.trim()}-${_phone3Controller.text.trim()}";

    final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
    final birthRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    if (_nameController.text.trim().isEmpty ||
        _birthController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        !_isGenderSelected.contains(true) ||
        !phoneRegex.hasMatch(phoneNumber) ||
        !birthRegex.hasMatch(_birthController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("입력값을 다시 확인해주세요. 형식이 맞지 않습니다.")),
      );
      return;
    }

    final body = {
      "kakao_user_id": kakaoUserId,
      "username": _nameController.text.trim(),
      "birth_date": _birthController.text.trim(),
      "gender": _isGenderSelected[0] ? "남성" : "여성",
      "address": _addressController.text.trim(),
      "phone_number": phoneNumber,
    };

    final url = Uri.parse('$baseUrl/$kakaoUserId');
    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic $serverAccessToken",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 && context.mounted) {
        context.go('/homeSetting/viewProfile');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint("네트워크 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: '내 정보 수정', showBackButton: true),
      backgroundColor: Colors.grey[200],
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        color: Colors.green,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              _buildSection('기본 정보', [
                _buildTextField('이름         ', _nameController),
                _buildTextField('생년월일  ', _birthController),
                _buildGenderSelection(),
                _buildTextField('주소         ', _addressController),
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
                child: const Text('수정 완료', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
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
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/profile_icon/green_profile.png'),
                ),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
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

  Widget _buildGenderSelection() {
    return Row(
      children: [
        const Text("성별         ", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        ToggleButtons(
          borderRadius: BorderRadius.circular(8),
          constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
          isSelected: _isGenderSelected,
          onPressed: (index) => setState(() {
            for (int i = 0; i < _isGenderSelected.length; i++) {
              _isGenderSelected[i] = (i == index);
            }
          }),
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
        Expanded(child: _buildTextField('', _phone1Controller)),
        const SizedBox(width: 10),
        const Text("-"),
        Expanded(child: _buildTextField('', _phone2Controller)),
        const SizedBox(width: 10),
        const Text("-"),
        Expanded(child: _buildTextField('', _phone3Controller)),
      ],
    );
  }
}
