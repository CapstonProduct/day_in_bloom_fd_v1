import 'dart:convert';
import 'package:day_in_bloom_fd_v1/features/elderlycode/screen/code_explanation_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';
import 'package:day_in_bloom_fd_v1/features/elderlycode/screen/newcode_register_modal.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';

class HomeCodeScreen extends StatefulWidget {
  const HomeCodeScreen({super.key});

  @override
  State<HomeCodeScreen> createState() => _HomeCodeScreenState();
}

class _HomeCodeScreenState extends State<HomeCodeScreen> {
  List<Map<String, String>> elderlyList = [];

  final List<String> profileImagePaths = [
    "assets/profile_icon/orange_profile.png",
    "assets/profile_icon/green_profile.png",
    "assets/profile_icon/red_profile.png",
    "assets/profile_icon/blue_profile.png",
    "assets/profile_icon/purple_profile.png",
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchElderlyList();
  }

  Future<void> fetchElderlyList() async {
    setState(() => _isLoading = true);

    final kakaoUserId = await KakaoAuthService.getUserId();
    final serverAccessToken = await KakaoAuthService.getServerAccessToken();

    if (kakaoUserId == null || serverAccessToken == null) {
      print("사용자 ID 또는 서버 액세스 토큰을 불러올 수 없습니다.");
      setState(() => _isLoading = false);
      return;
    }

    final baseUrl = dotenv.env['HOME_ELDERLY_LIST_API_GATEWAY_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      print(".env에서 HOME_ELDERLY_LIST_API_GATEWAY_URL 설정을 찾을 수 없습니다.");
      setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse('$baseUrl/$kakaoUserId/seniors');
    print("요청 URL: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic $serverAccessToken",
        },
      );

      final responseBody = utf8.decode(response.bodyBytes);
      print("응답 상태 코드: ${response.statusCode}");
      print("받은 데이터:\n${const JsonEncoder.withIndent('  ').convert(jsonDecode(responseBody))}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
        final seniors = decoded["seniors"] as List<dynamic>;
        final List<Map<String, String>> loadedList = [];

        int colorIndex = 0;
        for (final senior in seniors) {
          final data = senior as Map<String, dynamic>;

          final imagePath = profileImagePaths[colorIndex % profileImagePaths.length];
          colorIndex++;

          loadedList.add({
            "name": data["username"] ?? "",
            "age": _calculateAge(data["birth_date"]),
            "location": data["address"] ?? "",
            "imagePath": imagePath,
            "encodedId": data["encodedId"],
          });
        }

        setState(() {
          elderlyList = loadedList;
          _isLoading = false;
        });
      } else {
        print("서버 오류: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("네트워크 오류: $e");
      setState(() => _isLoading = false);
    }
  }

  String _calculateAge(String birthDateStr) {
    try {
      final birthDate = DateTime.parse(birthDateStr);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return "$age세";
    } catch (_) {
      return "나이 정보 없음";
    }
  }

  Future<void> _removeElderly(String encodedId) async {
    print("🔽 삭제 요청 시작 - encodedId (senior_id): $encodedId");

    final kakaoUserId = await KakaoAuthService.getUserId();
    final serverAccessToken = await KakaoAuthService.getServerAccessToken();

    if (kakaoUserId == null || serverAccessToken == null) {
      print("❌ 사용자 ID 또는 서버 액세스 토큰을 불러올 수 없습니다.");
      return;
    }

    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      print("❌ .env에서 ROOT_API_GATEWAY_URL 설정을 찾을 수 없습니다.");
      return;
    }

    final deleteUrl = Uri.parse('$baseUrl/$kakaoUserId/seniors/$encodedId');

    print("📤 DELETE 요청 URL: $deleteUrl");
    print("📤 Authorization 헤더: Basic $serverAccessToken");

    try {
      final response = await http.delete(
        deleteUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic $serverAccessToken",
        },
      );

      print("📥 응답 상태 코드: ${response.statusCode}");
      if (response.body.isNotEmpty) {
        print("📥 응답 본문:\n${utf8.decode(response.bodyBytes)}");
      } else {
        print("📥 응답 본문 없음 (204 등)");
      }

      if (response.statusCode == 204) {
        print("✅ 삭제 성공 - 리스트에서 제거");
        setState(() {
          elderlyList.removeWhere((elderly) => elderly["encodedId"] == encodedId);
        });
      } else {
        print("❌ 삭제 실패 - 상태 코드: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("삭제 실패: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("❗ 삭제 API 호출 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("삭제 중 오류가 발생했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "어르신 코드 등록"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const NewCodeRegisterModal(),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  side: const BorderSide(color: Colors.teal, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("코드 등록", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : RefreshIndicator(
                      onRefresh: fetchElderlyList,
                      color: Colors.teal,
                      backgroundColor: Colors.white,
                      child: ListView.builder(
                        itemCount: elderlyList.length,
                        itemBuilder: (context, index) {
                          final elderly = elderlyList[index];
                          return ElderlyListItem(
                            name: elderly["name"]!,
                            age: elderly["age"]!,
                            location: elderly["location"]!,
                            imagePath: elderly["imagePath"]!,
                            onRemove: () => _removeElderly(elderly["encodedId"]!),
                          );
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 128, 128, 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "어르신 등록 코드란?",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CodeExplanationModal(),
                        );
                      },
                      child: const Icon(Icons.help_outline, color: Colors.black54, size: 30),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ElderlyListItem extends StatelessWidget {
  final String name;
  final String age;
  final String location;
  final String imagePath;
  final VoidCallback onRemove;

  const ElderlyListItem({
    required this.name,
    required this.age,
    required this.location,
    required this.imagePath,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        color: Colors.grey[200],
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(imagePath),
            backgroundColor: Colors.transparent,
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("$age | $location"),
          trailing: IconButton(
            icon: const Icon(Icons.indeterminate_check_box_outlined, color: Colors.grey),
            onPressed: onRemove,
          ),
        ),
      ),
    );
  }
}