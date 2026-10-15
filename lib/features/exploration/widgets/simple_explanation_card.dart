import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../../services/tts_service.dart';

class SimpleExplanationCard extends ConsumerStatefulWidget {
  final String explanation;
  final String explanationUrdu;
  final bool isUrdu;
  final bool isLoading;
  final ValueChanged<bool>? onLanguageToggle;
  final double textScale;

  const SimpleExplanationCard({
    super.key,
    required this.explanation,
    this.explanationUrdu = '',
    this.isUrdu = false,
    this.isLoading = false,
    this.onLanguageToggle,
    this.textScale = 1.0,
  });

  @override
  ConsumerState<SimpleExplanationCard> createState() =>
      _SimpleExplanationCardState();
}

class _SimpleExplanationCardState extends ConsumerState<SimpleExplanationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late final TtsService _ttsService;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ttsService = ref.read(ttsServiceProvider);
    _ttsService.errorNotifier.addListener(_onErrorChanged);
  }

  void _onErrorChanged() {
    if (!mounted) return;
    final err = _ttsService.errorNotifier.value;
    if (err == null) return;

    if (err == 'urdu_voice_not_installed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Urdu voice download needed: Open phone Settings > Text-to-speech > Install voice data > Urdu (Pakistan).',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.secondary,
          duration: Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant SimpleExplanationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isUrdu != widget.isUrdu) {
      _ttsService.stop();
    }
  }

  @override
  void dispose() {
    _ttsService.errorNotifier.removeListener(_onErrorChanged);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ttsService = ref.watch(ttsServiceProvider);

    final hasUrdu = widget.explanationUrdu.trim().isNotEmpty;
    final activeText = widget.isUrdu
        ? (hasUrdu
            ? widget.explanationUrdu
            : 'اس سورت کی یہ مبارک آیات اللہ تعالیٰ کی بے پایاں رحمت، رہنمائی اور حکمت پر مبنی ہیں۔')
        : (widget.explanation.trim().isNotEmpty
            ? widget.explanation
            : 'Contemplating the overarching wisdom, moral guidance, and spiritual clarity of this passage.');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.accentGold,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isUrdu ? 'آسان تشریح (اردو)' : 'Simple Explanation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primaryDark,
                        ),
                  ),
                ),
                // Speaker TTS Audio Button
                ValueListenableBuilder<TtsPlaybackState>(
                  valueListenable: ttsService.stateNotifier,
                  builder: (context, playbackState, _) {
                    final isPlaying =
                        playbackState == TtsPlaybackState.playing;
                    if (isPlaying) {
                      if (!_pulseController.isAnimating) {
                        _pulseController.repeat(reverse: true);
                      }
                    } else {
                      if (_pulseController.isAnimating) {
                        _pulseController.stop();
                        _pulseController.reset();
                      }
                    }
                    return Tooltip(
                      message: isPlaying
                          ? (widget.isUrdu
                              ? 'آواز بند کریں'
                              : 'Stop Reading')
                          : (widget.isUrdu
                              ? 'آواز میں سنیں'
                              : 'Listen with Audio'),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (isPlaying) {
                            ttsService.stop();
                          } else {
                            ttsService.speak(activeText,
                                isUrdu: widget.isUrdu);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isPlaying
                                ? AppColors.accentGold.withAlpha(
                                    isDark ? 55 : 35)
                                : (isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.surfaceVariant),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPlaying
                                  ? AppColors.accentGold
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border),
                              width: isPlaying ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPlaying)
                                FadeTransition(
                                  opacity: _pulseController,
                                  child: const Icon(
                                    Icons.stop_circle_rounded,
                                    size: 16,
                                    color: AppColors.accentGold,
                                  ),
                                )
                              else
                                Icon(
                                  Icons.volume_up_rounded,
                                  size: 16,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              const SizedBox(width: 4),
                              Text(
                                isPlaying
                                    ? (widget.isUrdu ? 'رکیں' : 'Stop')
                                    : (widget.isUrdu ? 'سنیں' : 'Listen'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isPlaying
                                      ? AppColors.accentGold
                                      : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.primaryDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Language Switcher Toggle Pill
                if (widget.onLanguageToggle != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.border,
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLangChip(
                          context: context,
                          label: 'EN',
                          selected: !widget.isUrdu,
                          onTap: () => widget.onLanguageToggle!(false),
                          isDark: isDark,
                        ),
                        _buildLangChip(
                          context: context,
                          label: 'اردو',
                          selected: widget.isUrdu,
                          onTap: () => widget.onLanguageToggle!(true),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            if (widget.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accentGold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'اردو تشریح تیار کی جا رہی ہے...',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Directionality(
                textDirection:
                    widget.isUrdu ? TextDirection.rtl : TextDirection.ltr,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    activeText,
                    textAlign:
                        widget.isUrdu ? TextAlign.right : TextAlign.left,
                    style: widget.isUrdu
                        ? GoogleFonts.amiri(
                            fontSize: 18 * widget.textScale,
                            height: 1.85,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          )
                        : Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16 * widget.textScale,
                              height: 1.65,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? AppColors.darkPrimary : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: selected
                ? Colors.white
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
