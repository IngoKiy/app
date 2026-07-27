import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

/// Notiz-Editor im Stil von Microsoft To Do: weiße Seite mit einem randlosen,
/// sofort fokussierten Textbereich — kein Rich-Text-Werkzeugkasten, kein
/// Speichern-Icon, sondern „Fertig" rechts.
///
/// Gespeichert wird Vikunjas `description`. Bestehende Beschreibungen können
/// (aus Vikunja-Web) HTML enthalten; damit nichts verloren geht, wird
/// vorhandenes Markup beim Öffnen in Text zurückgeführt und beim Speichern
/// als einfache Absätze wieder ausgegeben — Web rendert die Notiz unverändert.
class EditDescription extends StatefulWidget {
  final String? initialText;

  const EditDescription({super.key, required this.initialText});

  @override
  EditDescriptionState createState() => EditDescriptionState();
}

class EditDescriptionState extends State<EditDescription> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: htmlToPlainText(widget.initialText),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.pop(context, plainTextToHtml(_controller.text));

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
          l10n.noteAdd,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [TextButton(onPressed: _save, child: Text(l10n.done))],
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
            hintText: l10n.noteAdd,
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

/// HTML (z. B. aus Vikunja-Web) für die Bearbeitung in Klartext überführen.
String htmlToPlainText(String? html) {
  if (html == null || html.isEmpty) return '';
  var text = html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '');
  text = text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
  return text.trimRight();
}

/// Klartext als einfache Absätze zurückschreiben, damit Vikunja-Web die
/// Notiz unverändert rendert.
String plainTextToHtml(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return '';
  final escaped = trimmed
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
  return escaped
      .split(RegExp(r'\n{2,}'))
      .map((p) => '<p>${p.replaceAll('\n', '<br>')}</p>')
      .join();
}
