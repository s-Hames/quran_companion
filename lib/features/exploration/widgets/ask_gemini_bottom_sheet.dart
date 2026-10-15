import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/qa_message.dart';
import '../../../data/models/quran_explanation.dart';
import '../../../providers/app_providers.dart';

class AskGeminiBottomSheet extends ConsumerStatefulWidget {
  final QuranExplanation explanation;

  const AskGeminiBottomSheet({super.key, required this.explanation});

  @override
  ConsumerState<AskGeminiBottomSheet> createState() => _AskGeminiBottomSheetState();
}

class _AskGeminiBottomSheetState extends ConsumerState<AskGeminiBottomSheet> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<QAMessage> _messages = [];
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    'Explain this in simpler words.',
    'What practical lesson can I apply today?',
    'What are different scholarly interpretations?',
    'What is the spiritual meaning of this verse?',
    'How does this relate to other Quranic themes?',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _askQuestion(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _questionController.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final previousHistory = _messages.map((m) {
      return {'user': m.question, 'model': m.answer};
    }).toList();

    try {
      final gemini = ref.read(geminiServiceProvider);
      final answer = await gemini.askQuestionAboutPassage(
        explanation: widget.explanation,
        userQuestion: trimmed,
        previousHistory: previousHistory,
      );

      if (!mounted) return;

      setState(() {
        _messages.add(
          QAMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            question: trimmed,
            answer: answer,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBg : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: isDark ? AppColors.darkPrimary : AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ask Gemini About This Passage',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                            ),
                          ),
                          Text(
                            widget.explanation.passageReference,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.darkSecondary : AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Message history
              Expanded(
                child: _messages.isEmpty
                    ? SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                                border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.question_answer_rounded, size: 36, color: isDark ? AppColors.darkSecondary : AppColors.secondary),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Explore Deeper Questions',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Ask questions specifically related to ${widget.explanation.passageReference}. Gemini will reflect strictly on this passage without inventing rulings.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Suggested Questions:',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _quickPrompts.map((prompt) {
                                return ActionChip(
                                  label: Text(
                                    prompt,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                    ),
                                  ),
                                  onPressed: () => _askQuestion(prompt),
                                  backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.background,
                                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) {
                          final msg = _messages[i];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // User Question
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10, left: 40),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    msg.question,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ),

                              // Gemini Answer
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16, right: 30),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.auto_awesome_rounded, size: 14, color: isDark ? AppColors.darkPrimary : AppColors.primary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Gemini Companion',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SelectableText(
                                        msg.answer,
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          height: 1.55,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),

              if (_isLoading) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? AppColors.darkPrimary : AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Gemini is preparing an answer...',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Input field
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBg : Colors.white,
                  border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _questionController,
                        style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Ask a question about this passage...',
                          hintStyle: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (val) => _askQuestion(val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.send_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                      ),
                      onPressed: _isLoading ? null : () => _askQuestion(_questionController.text),
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
