import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// A versatile document viewer that handles images and PDFs.
///
/// Pass `url`, `name`, and `type` via route arguments.
class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  String? _url;
  String? _name;
  String? _type;

  bool _isLoading = true;
  String? _localPdfPath;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _url = args['url'] as String?;
      _name = args['name'] as String? ?? 'Document';
      _type = (args['type'] as String?)?.toLowerCase() ?? '';

      if (_isPdf && _localPdfPath == null) {
        _downloadPdf();
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid document data';
      });
    }
  }

  bool get _isPdf => _type == 'pdf';
  bool get _isImage =>
      ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(_type);

  Future<void> _downloadPdf() async {
    if (_url == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No URL provided';
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(_url!));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File(
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _localPdfPath = file.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to download PDF (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error downloading PDF: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final contentColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColorPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: contentColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColorPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _name ?? 'Document',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColorPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
      ),
      body: _buildBody(isDark, textColorPrimary),
    );
  }

  Widget _buildBody(bool isDark, Color textColorPrimary) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: textColorPrimary),
              ),
            ],
          ),
        ),
      );
    }

    if (_url == null) {
      return Center(
        child: Text(
          'No document to display',
          style: GoogleFonts.inter(fontSize: 14, color: textColorPrimary),
        ),
      );
    }

    if (_isPdf) {
      return _buildPdfViewer();
    } else if (_isImage) {
      return _buildImageViewer();
    } else {
      // Fallback for unknown types - show a message with option to open externally
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_drive_file,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Preview not available for this file type',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: textColorPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${_type ?? 'Unknown'}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildPdfViewer() {
    if (_localPdfPath == null) {
      return const Center(child: Text('PDF not loaded'));
    }

    return PDFView(
      filePath: _localPdfPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      onError: (error) {
        setState(() => _errorMessage = 'PDF Error: $error');
      },
      onPageError: (page, error) {
        debugPrint('Page $page error: $error');
      },
    );
  }

  Widget _buildImageViewer() {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: _url!,
          fit: BoxFit.contain,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
