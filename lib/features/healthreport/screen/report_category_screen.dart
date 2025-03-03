import 'package:day_in_bloom_fd_v1/features/healthreport/screen/pdf_download_modal.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportCategoryScreen extends StatelessWidget {
  const ReportCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜가 선택되지 않았습니다.';
    final elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';

    return Scaffold(
      appBar: CustomAppBar(title: '$elderlyName 어르신 건강 리포트', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              selectedDate,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  if (index == 0 || index == 1) {
                    return ScoreReportCategoryTile(
                      category: _categories[index],
                      isHighlighted: index == 0,
                      color: index == 0 ? Colors.yellow.shade100 : Colors.grey.shade200,
                    );
                  }
                  return ReportCategoryTile(category: _categories[index], isHighlighted: false);
                },
              ),
            ),
            const SizedBox(height: 16),
            const DownloadReportButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class ReportCategoryTile extends StatelessWidget {
  final ReportCategory category;
  final bool isHighlighted;

  const ReportCategoryTile({super.key, required this.category, required this.isHighlighted});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '';
        final elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';
        context.go('${category.route}?date=$selectedDate&name=$elderlyName'); 
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
        context.go('${category.route}?date=$selectedDate&name=$elderlyName'); 
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

class DownloadReportButton extends StatelessWidget {
  const DownloadReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        PdfDownloadModal.show(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '리포트 PDF 다운로드 (본인용)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 14),
            Image.asset('assets/report_icon/green_pdf.png', width: 40, height: 40),
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
}

const List<ReportCategory> _categories = [
  ReportCategory(title: '전체 종합 점수', imagePath: '', score: 88, route: '/homeElderlyList/calendar/report/totalScore'),
  ReportCategory(title: '스트레스 점수', imagePath: '', score: 52, color: Colors.red, route: '/homeElderlyList/calendar/report/stressScore'),
  ReportCategory(title: '운동', imagePath: 'assets/report_icon/dumbell.png', route: '/homeElderlyList/calendar/report/exercise'),
  ReportCategory(title: '수면', imagePath: 'assets/report_icon/pillow.png', route: '/homeElderlyList/calendar/report/sleep'),
  ReportCategory(title: '보호자님\n조언', imagePath: 'assets/report_icon/family_talk.png', route: '/homeElderlyList/calendar/report/familyAdvice'),
  ReportCategory(title: '의사 선생님\n조언', imagePath: 'assets/report_icon/doctor_talk.png', route: '/homeElderlyList/calendar/report/doctorAdvice'),
];
