import 'package:day_in_bloom_fd_v1/features/elderlycode/screen/newcode_register_modal.dart';
import 'package:flutter/material.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_fd_v1/features/elderlycode/screen/code_explanation_modal.dart';

class HomeCodeScreen extends StatelessWidget {
  const HomeCodeScreen({super.key});

  // 어르신 Mock 데이터
  static final List<Map<String, String>> elderlyList = [
    {
      "name": "최범식",
      "age": "70세",
      "location": "서울시 동대문구",
      "imagePath": "assets/profile_icon/orange_profile.png",
    },
    {
      "name": "유순자",
      "age": "60세",
      "location": "경기도 시흥시",
      "imagePath": "assets/profile_icon/green_profile.png",
    },
    {
      "name": "김미영",
      "age": "67세",
      "location": "서울시 은평구",
      "imagePath": "assets/profile_icon/red_profile.png",
    },
    {
      "name": "박영수",
      "age": "75세",
      "location": "부산광역시 해운대구",
      "imagePath": "assets/profile_icon/green_profile.png",
    },
    {
      "name": "이정희",
      "age": "72세",
      "location": "인천광역시 남동구",
      "imagePath": "assets/profile_icon/red_profile.png",
    },
    {
      "name": "한철민",
      "age": "68세",
      "location": "대전광역시 유성구",
      "imagePath": "assets/profile_icon/green_profile.png",
    },
    {
      "name": "오은주",
      "age": "74세",
      "location": "광주광역시 서구",
      "imagePath": "assets/profile_icon/orange_profile.png",
    },
    {
      "name": "정상우",
      "age": "63세",
      "location": "대구광역시 달서구",
      "imagePath": "assets/profile_icon/green_profile.png",
    },
    {
      "name": "백승진",
      "age": "77세",
      "location": "전라북도 전주시",
      "imagePath": "assets/profile_icon/red_profile.png",
    },
    {
      "name": "윤서영",
      "age": "69세",
      "location": "강원도 춘천시",
      "imagePath": "assets/profile_icon/red_profile.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "어르신 코드 등록"),
      body: Stack(
        children: [
          Padding(
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "코드 등록",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: elderlyList.length,
                    itemBuilder: (context, index) {
                      final elderly = elderlyList[index];
                      return ElderlyListItem(
                        name: elderly["name"]!,
                        age: elderly["age"]!,
                        location: elderly["location"]!,
                        imagePath: elderly["imagePath"]!,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 128, 128, 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "어르신 등록 코드란?",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
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
          trailing: IconButton(
            icon: const Icon(Icons.indeterminate_check_box_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
