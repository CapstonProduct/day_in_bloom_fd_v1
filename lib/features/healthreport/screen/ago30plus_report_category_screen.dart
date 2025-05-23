import 'package:day_in_bloom_fd_v1/features/healthreport/screen/pdf_download_modal.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Ago30plusReportCategoryScreen extends StatelessWidget {
  const Ago30plusReportCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜가 선택되지 않았습니다.';

    return Scaffold(
      appBar: const CustomAppBar(title: '건강 리포트', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              selectedDate,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
            const SizedBox(height: 20),
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.blue],
                ),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '';
                context.go('/homeElderlyList/calendar/ago30plusReport/pdfReportViewer?date=$selectedDate'); 
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 50),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PDF 뷰어로\n리포트 확인하기',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Image.asset('assets/home_icon/flower_icon.png', width: 40, height: 40),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const DownloadReportButton(),
            const SizedBox(height: 16),
          ],
        ),
      )
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
        final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'] ?? '';
        print("encodedId: $encodedId");
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
              child: Image.asset(category.imagePath, width: 60, height: 60),
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

  const ScoreReportCategoryTile({
    super.key,
    required this.category,
    required this.isHighlighted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '';
        final elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';
        final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'] ?? '';

        context.go(
          '${category.route}?date=$selectedDate&name=$elderlyName&encodedId=$encodedId',
        );
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
              child: Image.asset(category.imagePath, width: 60, height: 60),
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
        final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜가 선택되지 않았습니다.';
        final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'] ?? '';
        PdfDownloadModal.show(context, selectedDate, encodedId);
        // PDF 다운로드
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
              '리포트 PDF\n다운로드 (본인용)',
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
  ReportCategory(title: '보호자님\n조언', imagePath: 'assets/report_icon/family_talk.png', route: '/homeElderlyList/calendar/ago30plusReport/familyAdvice'),
  ReportCategory(title: '의사 선생님\n조언', imagePath: 'assets/report_icon/doctor_talk.png', route: '/homeElderlyList/calendar/ago30plusReport/doctorAdvice'),
];
