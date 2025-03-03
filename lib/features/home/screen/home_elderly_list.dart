import 'package:flutter/material.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:go_router/go_router.dart';

class HomeElderlyListScreen extends StatefulWidget {
  const HomeElderlyListScreen({super.key});

  @override
  _HomeElderlyListScreenState createState() => _HomeElderlyListScreenState();
}

class _HomeElderlyListScreenState extends State<HomeElderlyListScreen> {
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
  ];

  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "어르신 목록"),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: elderlyList.length,
                    itemBuilder: (context, index) {
                      final elderly = elderlyList[index];
                      return GestureDetector(
                        onTap: () {
                          context.go(
                            '/homeElderlyList/calendar?name=${elderly["name"]}'
                          );
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
                SizedBox(height: 16),
                ToggleButtons(
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
              ],
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
          trailing: const Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }
}
