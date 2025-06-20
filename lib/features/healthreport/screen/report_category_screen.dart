import 'dart:convert';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';
import 'package:day_in_bloom_fd_v1/features/healthreport/screen/excel_download_modal.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'pdf_download_modal.dart';

class ReportCategoryScreen extends StatefulWidget {
  const ReportCategoryScreen({super.key});

  @override
  State<ReportCategoryScreen> createState() => _ReportCategoryScreenState();
}

class _ReportCategoryScreenState extends State<ReportCategoryScreen> {
  late Future<Map<String, dynamic>> _reportData;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _reportData = fetchReportData(); 
      _isInitialized = true;
    }
  }

  Future<Map<String, dynamic>> fetchReportData() async {
    final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'];
    final rawDate = GoRouterState.of(context).uri.queryParameters['date'];

    if (encodedId == null || rawDate == null) {
      throw Exception("날짜 또는 ID가 누락되었습니다.");
    }

    final cleaned = rawDate.replaceAll(RegExp(r'\s+'), '').replaceAll('/', '-');
    late String parsedDate;

    try {
      parsedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(cleaned));
    } catch (e) {
      throw FormatException("Invalid date format: $rawDate");
    }

    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception(".env에 ROOT_API_GATEWAY_URL이 설정되지 않았습니다.");
    }

    final url = Uri.parse('$baseUrl/reports?encodedId=$encodedId&report_date=$parsedDate');
    debugPrint("=== API 호출 URL: $url");

    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode != 200) {
      debugPrint("API 응답 실패: ${response.body}");
      throw Exception("데이터 불러오기 실패");
    }

    return json.decode(response.body);
  }

  Future<void> _refresh() async {
    setState(() {
      _reportData = fetchReportData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '';
    final elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';
    final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'] ?? '';

    return Scaffold(
      appBar: CustomAppBar(title: '$elderlyName 어르신 건강 리포트', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.green,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _reportData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.green));
              } else if (snapshot.hasError) {
                return Center(child: Text('오류 발생: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('데이터가 없습니다.'));
              }

              final data = snapshot.data!;
              final int overallHealthScore = (data['overall_health_score'] as num?)?.toInt() ?? 0;
              final int stressScore = (data['stress_score'] as num?)?.toInt() ?? 0;

              final updatedCategories = [
                _categories[0].copyWith(score: overallHealthScore),
                _categories[1].copyWith(score: stressScore),
                ..._categories.sublist(2),
              ];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(selectedDate, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElderlyInfo(encodedId: encodedId),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: updatedCategories.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final category = updatedCategories[index];
                        if (index == 0 || index == 1) {
                          return ScoreReportCategoryTile(
                            category: category.copyWith(
                              score: index == 0 ? ((overallHealthScore as num?)?.toInt() ?? 0) : ((stressScore as num?)?.toInt() ?? 0),
                            ),
                            isHighlighted: index == 0,
                            color: index == 0 ? Colors.yellow.shade100 : Colors.grey.shade200,
                          );
                        }
                        return ReportCategoryTile(category: category, isHighlighted: false);
                      },
                    ),
                    const SizedBox(height: 16),
                    PdfDownloadButtons(encodedId: encodedId),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> fetchElderlyProfile(String encodedId) async {
  final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
  if (baseUrl == null || baseUrl.isEmpty) {
    throw Exception(".env에 ROOT_API_GATEWAY_URL이 설정되지 않았습니다.");
  }

  final url = Uri.parse('$baseUrl/reports/elderlyProfile?encodedId=$encodedId');
  debugPrint("=== 노인 프로필 API 호출 URL: $url");

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    debugPrint("노인 프로필 API 실패: ${response.body}");
    throw Exception("노인 프로필 데이터 불러오기 실패");
  }

  return json.decode(response.body);
}

class ElderlyInfo extends StatelessWidget {
  final String encodedId;

  const ElderlyInfo({super.key, required this.encodedId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchElderlyProfile(encodedId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        } else if (snapshot.hasError) {
          return Center(child: Text('오류 발생: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('프로필 데이터가 없습니다.'));
        }

        final data = snapshot.data!;
        final name = data['username'] ?? '어르신';
        final rawBirthDate = data['birth_date'];
        final birthDate = rawBirthDate != null
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(rawBirthDate))
            : '-';
        final height = data['height'] != null
            ? data['height'].toDouble().toStringAsFixed(0)
            : '-';
        final weight = data['weight'] != null
            ? data['weight'].toDouble().toStringAsFixed(1)
            : '-';
        final gender = data['gender'] ?? '-';
        final address = data['address'] ?? '-';
        final phone = data['phone_number'] ?? '-';
        // final height = data['height']?.toString() ?? '-';
        // final weight = data['weight']?.toString() ?? '-';
        final breakfast = (data['breakfast_time'] as String?)?.substring(0, 5) ?? '-';
        final lunch = (data['lunch_time'] as String?)?.substring(0, 5) ?? '-';
        final dinner = (data['dinner_time'] as String?)?.substring(0, 5) ?? '-';

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/profile_icon/green_profile.png'),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(birthDate),
                      Text(gender),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow('주소', address),
                  const Divider(),
                  _buildInfoRow('전화번호', phone),
                  const Divider(),
                  _buildInfoRow('신장 / 체중', '$height cm / $weight kg'),
                  const Divider(),
                  _buildInfoRow('아침시간', breakfast),
                  const Divider(),
                  _buildInfoRow('점심시간', lunch),
                  const Divider(),
                  _buildInfoRow('저녁시간', dinner),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}


class ReportCategoryTile extends StatelessWidget {
  final ReportCategory category;
  final bool isHighlighted;

  const ReportCategoryTile({
    super.key,
    required this.category,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '';
    final elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';
    final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'] ?? '';

    return GestureDetector(
      onTap: () {
        context.go('${category.route}?date=$selectedDate&name=$elderlyName&encodedId=$encodedId');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.yellow.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                category.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(category.imagePath, width: 60, height: 60),
            ),

            if (category.title.contains('조언'))
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () {
                    String targetRoute;

                    if (category.title.contains('보호자')) {
                      targetRoute = '/homeElderlyList/calendar/report/familyAdvice/modifyFamilyAdvice';
                    } else if (category.title.contains('의사')) {
                      targetRoute = '/homeElderlyList/calendar/report/doctorAdvice/modifyDoctorAdvice';
                    } else {
                      return;
                    }

                    context.go('$targetRoute?date=$selectedDate&name=$elderlyName&encodedId=$encodedId');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '수정',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ScoreReportCategoryTile extends StatelessWidget {
  final ReportCategory category;
  final bool isHighlighted;
  final Color color;

  const ScoreReportCategoryTile({super.key, required this.category, required this.isHighlighted, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '';
        final elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';
        final String encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'] ?? '';
        context.go('${category.route}?date=$selectedDate&name=$elderlyName&encodedId=$encodedId'); 
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                category.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                category.score.toString(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: category.color ?? Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PdfDownloadButtons extends StatelessWidget {
  final String encodedId;
  const PdfDownloadButtons({super.key, required this.encodedId});

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: PdfDownloadButton(
            title: '리포트 PDF\n다운로드\n(모두)',
            color: Colors.green.shade100,
            imagePath: 'assets/report_icon/green_pdf.png',
            onTap: () => PdfDownloadModal.show(context, selectedDate, encodedId),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PdfDownloadButton(
            title: '로우데이터\n엑셀 파일\n다운로드\n(의사)',
            color: Colors.blue.shade100,
            imagePath: 'assets/report_icon/excel.png',
            onTap: () {
              ExcelDownloadModal.show(context, selectedDate, encodedId);
            },
          ),
        ),
      ],
    );
  }
}

class PdfDownloadButton extends StatelessWidget {
  final String title;
  final Color color;
  final String imagePath;
  final VoidCallback onTap;

  const PdfDownloadButton({
    super.key,
    required this.title,
    required this.color,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportCategory {
  final String title;
  final String imagePath;
  final int score;
  final Color? color;
  final String route;

  const ReportCategory({
    required this.title,
    required this.imagePath,
    this.score = 0,
    this.color,
    required this.route,
  });

  ReportCategory copyWith({
    String? title,
    String? imagePath,
    int? score,
    Color? color,
    String? route,
  }) {
    return ReportCategory(
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      score: score ?? this.score,
      color: color ?? this.color,
      route: route ?? this.route,
    );
  }
}

const List<ReportCategory> _categories = [
  ReportCategory(title: '전체 종합 점수', imagePath: '', score: 88, route: '/homeElderlyList/calendar/report/totalScore'),
  ReportCategory(title: '스트레스 점수', imagePath: '', score: 52, color: Colors.red, route: '/homeElderlyList/calendar/report/stressScore'),
  ReportCategory(title: '운동', imagePath: 'assets/report_icon/dumbell.png', route: '/homeElderlyList/calendar/report/exercise'),
  ReportCategory(title: '수면', imagePath: 'assets/report_icon/pillow.png', route: '/homeElderlyList/calendar/report/sleep'),
  ReportCategory(title: '보호자님\n조언', imagePath: 'assets/report_icon/family_talk.png', route: '/homeElderlyList/calendar/report/familyAdvice'),
  ReportCategory(title: '의사\n선생님\n조언', imagePath: 'assets/report_icon/doctor_talk.png', route: '/homeElderlyList/calendar/report/doctorAdvice'),
];
