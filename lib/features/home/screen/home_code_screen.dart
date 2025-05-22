import 'dart:convert';
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
    if (kakaoUserId == null) {
      print("사용자 ID를 불러올 수 없습니다.");
      setState(() => _isLoading = false);
      return;
    }

    final body = {"kakao_user_id": kakaoUserId};
    final url = dotenv.env['HOME_CODE_API_GATEWAY_URL'];

    if (url == null || url.isEmpty) {
      print(".env에서 HOME_CODE_API_GATEWAY_URL 설정을 찾을 수 없습니다.");
      setState(() => _isLoading = false);
      return;
    }

    print("전송할 데이터:\n${const JsonEncoder.withIndent('  ').convert(body)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final List<Map<String, String>> loadedList = [];

        int colorIndex = 0;

        for (final entry in decoded.entries) {
          final data = entry.value as Map<String, dynamic>;

          final imagePath = profileImagePaths[colorIndex % profileImagePaths.length];
          colorIndex++;

          loadedList.add({
            "name": data["username"] ?? "",
            "age": _calculateAge(data["birth_date"]),
            "location": data["address"] ?? "",
            "imagePath": imagePath,
            "encodedId": data["encodedId"] ?? "",
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
    print("삭제 요청 ID: $encodedId");
    
    // 실제 삭제 로직은 여기에 구현해야 함.

    setState(() {
      elderlyList.removeWhere((elderly) => elderly["encodedId"] == encodedId);
    });
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
