import 'dart:convert';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    final kakaoUserId = await KakaoAuthService.getUserId();

    if (kakaoUserId == null) {
      throw Exception("사용자 ID를 불러올 수 없습니다.");
    }

    final url = dotenv.env['VIEW_PROFILE_API_GATEWAY_URL'];
    if (url == null || url.isEmpty) {
      throw Exception("VIEW_PROFILE_API_GATEWAY_URL이 .env에 설정되지 않았습니다.");
    }

    final body = {"kakao_user_id": kakaoUserId};
    debugPrint("전송할 데이터:\n${const JsonEncoder.withIndent('  ').convert(body)}");

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final responseBody = utf8.decode(response.bodyBytes); 
    debugPrint("응답 상태: ${response.statusCode}");
    debugPrint("응답 본문: $responseBody");

    if (response.statusCode != 200) {
      throw Exception('프로필 불러오기 실패: $responseBody');
    }

    return jsonDecode(responseBody);
  }

  Future<void> _refresh() async {
    setState(() {
      _profileFuture = _fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '내 정보 보기', showBackButton: true),
      backgroundColor: Colors.grey[200],
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.green,
        backgroundColor: Colors.white,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            } else if (snapshot.hasError) {
              return Center(child: Text('오류 발생: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('데이터가 없습니다.'));
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/profile_icon/green_profile.png'),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoContainer('기본 정보', [
                    _buildInfoItem('이름', data['username'] ?? '-'),
                    _buildInfoItem('생년월일', data['birth_date'] ?? '-'),
                    _buildInfoItem('성별', data['gender'] ?? '-'),
                    _buildInfoItem('주소', data['address'] ?? '-'),
                    _buildInfoItem('전화번호', data['phone_number'] ?? '-'),
                  ]),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/homeSetting/viewProfile/modifyProfile');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                    ),
                    child: const Text(
                      '내 정보 수정',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String title, List<Widget> children, {VoidCallback? onHelpPressed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (onHelpPressed != null)
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.grey),
                onPressed: onHelpPressed,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ListTile.divideTiles(
              context: context,
              color: Colors.grey.shade300,
              tiles: children,
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}
