import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SessionNotesSheet extends StatefulWidget {
  final String initialNotes;
  final Function(String newNotes) onSave;

  const SessionNotesSheet({
    super.key,
    required this.initialNotes,
    required this.onSave,
  });

  @override
  State<SessionNotesSheet> createState() => _SessionNotesSheetState();
}

class _SessionNotesSheetState extends State<SessionNotesSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBg : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Personal Reading Notes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Your personal reflections are kept private and saved locally on this device.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 5,
                autofocus: true,
                style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Record thoughts, questions, or personal reflections on this passage...',
                  hintStyle: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save Note'),
                  onPressed: () {
                    widget.onSave(_controller.text.trim());
                    Navigator.pop(context);
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
