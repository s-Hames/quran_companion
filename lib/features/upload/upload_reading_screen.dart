import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/responsive_layout.dart';
import '../confirmation/passage_confirmation_screen.dart';
import '../passage_selection/manual_passage_screen.dart';

class UploadReadingScreen extends ConsumerStatefulWidget {
  const UploadReadingScreen({super.key});

  @override
  ConsumerState<UploadReadingScreen> createState() => _UploadReadingScreenState();
}

class _UploadReadingScreenState extends ConsumerState<UploadReadingScreen> {
  XFile? _selectedImage;
  bool _isAnalyzing = false;
  String _analysisStatus = '';

  Future<void> _pickImage(ImageSource source) async {
    final imageService = ref.read(imageServiceProvider);
    final picked = await imageService.pickImage(source);
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisStatus = 'Scanning Mushaf page layout...';
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();

      if (mounted) {
        setState(() {
          _analysisStatus = 'Identifying Surah and verse numbers with Gemini...';
        });
      }

      final gemini = ref.read(geminiServiceProvider);
      final mimeType = _selectedImage!.mimeType ?? 'image/jpeg';
      final result = await gemini.identifyPassageFromImage(bytes, mimeType: mimeType);

      // Save image locally for reading session
      final imageService = ref.read(imageServiceProvider);
      final savedPath = await imageService.saveImagePermanently(_selectedImage!);

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });

      // Navigate to confirmation screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PassageConfirmationScreen(
            identification: result,
            imagePath: savedPath,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Identification failed: $e'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Enter Manually',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ManualPassageScreen()),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyConfigured = ref.watch(geminiServiceProvider).isConfigured;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Today's Reading"),
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          maxWidth: 680,
          padding: ResponsiveLayout.defaultPadding(context, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            if (!isKeyConfigured)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E2211) : const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF5E4522) : const Color(0xFFFFD591)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFD46B08), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Demo / Sample Mode',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD46B08)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'No Gemini API key is configured. You can test uploading and explore sample passages, or add your key in Settings.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? const Color(0xFFFFD591) : const Color(0xFF873800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Instructional banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.primaryContainer.withAlpha(120),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.secondaryContainer),
              ),
              child: Row(
                children: [
                  Icon(Icons.camera_alt_rounded, color: isDark ? AppColors.darkPrimary : AppColors.primaryDark, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photograph your Mushaf Page',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ensure the Surah header and verse numbers are visible in good lighting for best recognition.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Image Preview Area
            if (_selectedImage == null) ...[
              Container(
                height: (MediaQuery.sizeOf(context).height * 0.32).clamp(180.0, 280.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBg : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 48,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No photo selected yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Take a picture of the page you read today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: (MediaQuery.sizeOf(context).height * 0.38).clamp(220.0, 360.0),
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: kIsWeb
                        ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                        : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton.filled(
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(backgroundColor: Colors.black54),
                      onPressed: _isAnalyzing
                          ? null
                          : () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Actions
            if (_selectedImage == null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Take Photo'),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('From Gallery'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ] else ...[
              if (_isAnalyzing) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardBg : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: isDark ? AppColors.darkPrimary : AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        _analysisStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'This usually takes just a few seconds.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Identify Passage with Gemini'),
                    onPressed: _analyzeImage,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retake Photo'),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.photo_library_rounded),
                        label: const Text('Choose Another'),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ],
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Alternative Manual Entry Action
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Or Select Passage Manually Without Photo'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManualPassageScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
