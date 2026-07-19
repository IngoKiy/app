import 'dart:io';

import 'package:background_downloader/background_downloader.dart'
    show FileDownloader, TaskStatus;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/network/cached_image_provider.dart';
import 'package:vikunja_app/core/offline/attachment_writer.dart';
import 'package:vikunja_app/data/models/task_attachment_dto.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_attachment.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/ui/confirmation_dialog.dart';

/// Zeigt die Anhänge einer Aufgabe (Bild-Thumbnails + Dateiliste) und
/// erlaubt Hochladen (Kamera/Fotomediathek/Dateien), Herunterladen und Löschen.
/// Wird sowohl in der Aufgaben-Ansicht (BottomSheet) als auch auf der
/// Bearbeiten-Seite verwendet und verwaltet seine Anhangsliste selbst.
class TaskAttachmentsSection extends ConsumerStatefulWidget {
  final Task task;
  final bool editable;

  const TaskAttachmentsSection({
    super.key,
    required this.task,
    this.editable = true,
  });

  @override
  ConsumerState<TaskAttachmentsSection> createState() =>
      _TaskAttachmentsSectionState();
}

class _TaskAttachmentsSectionState
    extends ConsumerState<TaskAttachmentsSection> {
  late List<TaskAttachment> _attachments;
  Map<String, String>? _headers;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _attachments = List.of(widget.task.attachments);
    ref.read(taskRepositoryProvider).attachmentHeaders().then((headers) {
      if (mounted) setState(() => _headers = headers);
    });
  }

  bool _isImage(TaskAttachment attachment) =>
      attachment.file.mime.startsWith('image/');

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = _attachments.where(_isImage).toList();
    final files = _attachments.where((a) => !_isImage(a)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context).attachments,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (_uploading)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (widget.editable)
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: AppLocalizations.of(context).addAttachment,
                onPressed: _uploading ? null : _showUploadOptions,
              ),
          ],
        ),
        if (images.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) => _buildThumbnail(images[index]),
          ),
        ...files.map(_buildFileTile),
      ],
    );
  }

  /// Lokaler Platzhalter (offline, negative ID) → FileImage; sonst der
  /// authentifizierte Platten-Cache. `previewSize` gilt nur für Server-Bilder.
  bool _isLocalPlaceholder(TaskAttachment a) =>
      a.id < 0 && a.localFilePath != null;

  ImageProvider? _imageProvider(TaskAttachment attachment, {String? previewSize}) {
    if (_isLocalPlaceholder(attachment)) {
      return FileImage(File(attachment.localFilePath!));
    }
    if (_headers == null) return null; // warten bis Auth-Header geladen sind
    final url = ref
        .read(taskRepositoryProvider)
        .attachmentUrl(widget.task.id, attachment.id, previewSize: previewSize);
    return AuthCachedImageProvider(
      url,
      headers: _headers!,
      cache: ref.read(imageDiskCacheProvider),
    );
  }

  Widget _buildThumbnail(TaskAttachment attachment) {
    final provider = _imageProvider(attachment, previewSize: 'md');

    return GestureDetector(
      onTap: () => _openImageViewer(attachment),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: provider == null
            ? Container(color: Theme.of(context).hoverColor)
            : Image(
                image: provider,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Container(
                        color: Theme.of(context).hoverColor,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                errorBuilder: (context, error, stack) => Container(
                  color: Theme.of(context).hoverColor,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
      ),
    );
  }

  Widget _buildFileTile(TaskAttachment attachment) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.insert_drive_file_outlined),
      title: Text(
        attachment.file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_formatSize(attachment.file.size)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadAndOpen(attachment),
          ),
          if (widget.editable)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(attachment),
            ),
        ],
      ),
    );
  }

  void _openImageViewer(TaskAttachment attachment) {
    final provider = _imageProvider(attachment);
    if (provider == null) return; // Auth-Header noch nicht geladen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AttachmentImageViewer(
          attachment: attachment,
          image: provider,
          onDownload: () => _downloadAndOpen(attachment),
          onDelete: widget.editable
              ? () async {
                  final deleted = await _confirmDelete(attachment);
                  if (deleted && context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              : null,
        ),
      ),
    );
  }

  Future<void> _showUploadOptions() async {
    final localizations = AppLocalizations.of(context);
    final picker = ImagePicker();

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(localizations.attachmentCamera),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final photo = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 90,
                );
                if (photo != null) await _upload([photo.path]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(localizations.attachmentGallery),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final photos = await picker.pickMultiImage(imageQuality: 90);
                if (photos.isNotEmpty) {
                  await _upload(photos.map((e) => e.path).toList());
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(localizations.attachmentFile),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                );
                final paths =
                    result?.files
                        .map((f) => f.path)
                        .whereType<String>()
                        .toList() ??
                    [];
                if (paths.isNotEmpty) await _upload(paths);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _upload(List<String> paths) async {
    setState(() => _uploading = true);
    final result = await ref
        .read(attachmentWriterProvider)
        .uploadAttachments(
          widget.task.id,
          paths,
          uploadedBy: ref.read(currentUserProvider),
        );
    if (!mounted) return;

    setState(() {
      _uploading = false;
      switch (result) {
        case AttachmentUploaded(:final attachments):
          _attachments.addAll(attachments);
        case AttachmentQueued(:final placeholders):
          // Offline: Platzhalter (localFilePath) sofort als Thumbnail zeigen.
          _attachments.addAll(placeholders);
        case AttachmentFailed():
        case AttachmentDeleted():
          break;
      }
    });
    if (result is AttachmentFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).attachmentUploadFailed),
        ),
      );
    }
  }

  Future<bool> _confirmDelete(TaskAttachment attachment) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showConfirmationDialog(
      context,
      title: localizations.attachmentDeleteTitle,
      message: localizations.attachmentDeleteMessage,
      confirmLabel: localizations.delete,
      cancelLabel: localizations.cancel,
      isDestructive: true,
    );
    if (!confirmed) return false;

    final result = await ref
        .read(attachmentWriterProvider)
        .deleteAttachment(
          widget.task.id,
          attachment.id,
          localFilePath: attachment.localFilePath,
        );
    if (!mounted) return false;

    if (result is AttachmentDeleted) {
      setState(() => _attachments.removeWhere((a) => a.id == attachment.id));
      return true;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).attachmentUploadFailed),
      ),
    );
    return false;
  }

  Future<void> _downloadAndOpen(TaskAttachment attachment) async {
    final writer = ref.read(attachmentWriterProvider);

    // Offline (oder bereits heruntergeladen): lokale Datei direkt öffnen.
    final localPath =
        attachment.localFilePath ?? await writer.localFilePathFor(attachment.id);
    if (localPath != null && await File(localPath).exists()) {
      await FileDownloader().openFile(filePath: localPath);
      return;
    }

    final update = await ref
        .read(taskRepositoryProvider)
        .downloadAttachment(widget.task.id, attachment);
    if (!mounted) return;

    if (update.status == TaskStatus.complete) {
      // Pfad merken, damit „Öffnen" später auch offline funktioniert.
      final path = await update.task.filePath();
      await writer.registerDownloadedFile(
        widget.task.id,
        TaskAttachmentDto.fromDomain(attachment),
        path,
      );
      FileDownloader().openFile(task: update.task);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).attachmentDownloadFailed),
        ),
      );
    }
  }
}

class _AttachmentImageViewer extends StatelessWidget {
  final TaskAttachment attachment;
  final ImageProvider image;
  final VoidCallback onDownload;
  final Future<void> Function()? onDelete;

  const _AttachmentImageViewer({
    required this.attachment,
    required this.image,
    required this.onDownload,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(attachment.file.name, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: onDownload),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => onDelete!(),
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 6,
          child: Image(
            image: image,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
            errorBuilder: (context, error, stack) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
