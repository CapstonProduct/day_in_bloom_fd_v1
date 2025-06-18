import 'dart:convert';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class HomeElderlyListScreen extends StatefulWidget {
  const HomeElderlyListScreen({super.key});

  @override
  _HomeElderlyListScreenState createState() => _HomeElderlyListScreenState();
}

class _HomeElderlyListScreenState extends State<HomeElderlyListScreen> {
  List<Map<String, String>> elderlyList = [];
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
        final List<String> profileImagePaths = [
          "assets/profile_icon/orange_profile.png",
          "assets/profile_icon/green_profile.png",
          "assets/profile_icon/red_profile.png",
        ];

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

  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "어르신 목록"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
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
                            return GestureDetector(
                              onTap: () {
                                final name = elderly["name"];
                                final encodedId = elderly["encodedId"];
                                context.go('/homeElderlyList/calendar?name=$name&encodedId=$encodedId');
                              },
                              child: ElderlyListItem(
                                name: elderly["name"]!,
                                age: elderly["age"]!,
                                location: elderly["location"]!,
                                imagePath: elderly["imagePath"]!,
                              ),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(10),
                  borderWidth: 1.5,
                  borderColor: Colors.teal,
                  selectedBorderColor: Colors.teal,
                  fillColor: Colors.teal.shade100,
                  selectedColor: Colors.teal.shade900,
                  color: Colors.teal,
                  constraints: const BoxConstraints(minHeight: 40, minWidth: 100),
                  isSelected: isSelected,
                  onPressed: (index) {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = (i == index);
                      }
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "보호자",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "의사",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  const ElderlyListItem({
    required this.name,
    required this.age,
    required this.location,
    required this.imagePath,
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
          trailing: const Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }
}
