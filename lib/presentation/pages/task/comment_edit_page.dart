import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/domain/entities/task_comment.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/task_comments_controller.dart';
import 'package:vikunja_app/presentation/pages/task/edit_description.dart';

/// Kommentar schreiben/bearbeiten im Stil von Microsoft To Do: weiße Seite,
/// randloses Textfeld mit Fokus, „Fertig" statt Speichern-Icon. Gespeichert
/// wird Vikunjas Kommentar-HTML (einfache Absätze), damit Vikunja-Web den
/// Kommentar unverändert anzeigt.
class CommentEditPage extends ConsumerStatefulWidget {
  final int taskId;
  final TaskComment? comment;

  const CommentEditPage({super.key, required this.taskId, this.comment});

  @override
  ConsumerState<CommentEditPage> createState() => _CommentEditPageState();
}

class _CommentEditPageState extends ConsumerState<CommentEditPage> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  bool get _isEditMode => widget.comment != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: htmlToPlainText(widget.comment?.comment),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final plain = _controller.text.trim();
    if (plain.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).commentCannotBeEmpty),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final text = plainTextToHtml(plain);

    final controller = ref.read(
      taskCommentsControllerProvider(widget.taskId).notifier,
    );

    final bool success;
    if (_isEditMode) {
      success = await controller.updateComment(widget.comment!, text);
    } else {
      success = await controller.addComment(text);
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, text);
    } else {
      setState(() => _isSaving = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? l10n.commentUpdateError : l10n.commentAddError,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: theme.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        title: Text(
          _isEditMode ? l10n.editCommentTitle : l10n.addCommentTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(onPressed: _save, child: Text(l10n.done)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          keyboardType: TextInputType.multiline,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: l10n.commentInputHint,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
