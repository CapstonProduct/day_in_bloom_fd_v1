import 'dart:convert';
import 'dart:io';

import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

class PdfReportViewerScreen extends StatefulWidget {
  const PdfReportViewerScreen({super.key});

  @override
  State<PdfReportViewerScreen> createState() => _PdfReportViewerScreenState();
}

class _PdfReportViewerScreenState extends State<PdfReportViewerScreen> {
  PDFDocument? _pdfDocument;
  bool _loading = true;
  String? _error;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _fetchAndLoadPdf();
    }
  }

  Future<void> _fetchAndLoadPdf() async {
    try {
      final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'] ?? '';
      final dateParam = GoRouterState.of(context).uri.queryParameters['date'] ?? '';

      if (encodedId.isEmpty) throw Exception('사용자 정보가 없습니다.');
      final reportDate = _formatDate(dateParam);

      final baseUrl = 'https://dayinbloom.shop/parents';
      final uri = Uri.parse('$baseUrl/reports/pdf').replace(queryParameters: {
        'encodedId': encodedId,
        'report_date': reportDate,
      });

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('PDF 링크 요청 실패: ${response.body}');
      }

      final presignedUrl = jsonDecode(response.body)['presignedUrl'];
      if (presignedUrl == null) {
        throw Exception('presignedUrl이 응답에 없습니다.');
      }

      final pdfResponse = await http.get(Uri.parse(presignedUrl));
      if (pdfResponse.statusCode != 200) {
        throw Exception('PDF 다운로드 실패 (상태코드: ${pdfResponse.statusCode})');
      }

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/temp_report.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfResponse.bodyBytes);

      final document = await PDFDocument.fromFile(file);

      setState(() {
        _pdfDocument = document;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _formatDate(String input) {
    try {
      final cleaned = input.trim().replaceAll(RegExp(r'\s*/\s*'), '-');
      final parsed = DateTime.parse(cleaned);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      throw Exception('날짜 형식 오류: $input');
    }
  }

  Widget _buildErrorMessage() {
    return const Center(
      child: Text(
        '해당 날짜에 리포트가 존재하지 않거나,\n네트워크 연결이 불안정합니다.',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '건강 리포트 뷰어', showBackButton: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _error != null
              ? _buildErrorMessage()
              : _pdfDocument != null
                  ? PDFViewer(
                      document: _pdfDocument!,
                      zoomSteps: 1,
                      lazyLoad: false,
                      scrollDirection: Axis.vertical,
                    )
                  : const Center(child: Text('PDF 파일을 불러올 수 없습니다.')),
    );
  }
}
