import 'package:flutter/material.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import '../services/collection_service.dart';
import 'bulk_import_screen.dart';
import 'home_screen.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  Map<String, List<String>> _collections = {};
  bool _isLoading = true;

  void _openCollection(BuildContext context, List<String> names, int index, {bool replace = false}) {
    if (index >= names.length) return;
    final name = names[index];
    final onCompleted = index + 1 < names.length
        ? () => _openCollection(context, names, index + 1, replace: true)
        : null;
    final screen = HomeScreen(mode: 'COLLECTION', topicTitle: name, onCompleted: onCompleted);
    if (replace) {
      Navigator.of(context).pushReplacement(smoothRoute(screen));
    } else {
      Navigator.of(context).push(smoothRoute(screen));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    final data = await CollectionService.getCollections();
    if (mounted) {
      setState(() {
        _collections = data;
        _isLoading = false;
      });
    }
  }

  void _showCreateCollectionDialog() {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.bBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            t.collectionsNewCollection,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: t.collectionsNamePlaceholder,
              hintStyle: TextStyle(color: context.bMuted),
              filled: true,
              fillColor: context.bBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.bSubtle, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.bSubtle, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: BrutalistTheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: context.bMuted,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                t.commonCancel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: BrutalistTheme.primary,
                foregroundColor: BrutalistTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              ),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(ctx).pop();
                  await CollectionService.createCollection(name);
                  _loadCollections();
                }
              },
              child: Text(
                t.collectionsCreate,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Brutalist swipe-to-delete background — soft brick red + rounded corners
  /// matching the surrounding card.
  Widget _dismissBackground(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFD9534F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: BrutalistTheme.white,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              t.commonDelete,
              style: const TextStyle(
                color: BrutalistTheme.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.collectionsTitle),
        actions: [
          IconButton(
            tooltip: t.bulkImportTitle,
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () async {
              final added = await Navigator.of(context)
                  .push<bool>(smoothRoute(const BulkImportScreen()));
              if (added == true) _loadCollections();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.bBorder, strokeWidth: 6),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: BrutalistCard(
                    backgroundColor: context.bBorder,
                    onTap: _showCreateCollectionDialog,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          t.collectionsCreateNew,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: context.bBg,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _collections.isEmpty
                      ? Center(
                          child: Text(
                            t.collectionsEmptyUppercase,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: context.bBorder,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          clipBehavior: Clip.none,
                          itemCount: _collections.keys.length,
                          itemBuilder: (context, index) {
                            final name = _collections.keys.elementAt(index);
                            final wordCount = _collections[name]!.length;
                            final isEven = index % 2 == 0;

                            return Dismissible(
                                key: Key(name),
                                direction: DismissDirection.endToStart,
                                background: _dismissBackground(t),
                                confirmDismiss: (dir) async {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: context.bBg,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Text(
                                        t.collectionsDeleteTitle(name),
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                            ),
                                      ),
                                      content: Text(
                                        t.collectionsDeleteBody,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: context.bMuted,
                                              height: 1.4,
                                            ),
                                      ),
                                      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(false),
                                          style: TextButton.styleFrom(
                                            foregroundColor: context.bMuted,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          ),
                                          child: Text(
                                            t.commonCancel,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: const Color(0xFFD9534F),
                                            foregroundColor: BrutalistTheme.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                          ),
                                          child: Text(
                                            t.commonDelete,
                                            style: const TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (dir) async {
                                  await CollectionService.deleteCollection(name);
                                  _loadCollections();
                                },
                                child: BrutalistCard(
                                  backgroundColor: isEven ? BrutalistTheme.primaryLight : BrutalistTheme.accentLight,
                                  onTap: () {
                                    final names = _collections.keys.toList();
                                    _openCollection(context, names, names.indexOf(name));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                      color: BrutalistTheme.black,
                                                      fontSize: 18,
                                                    ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                t.collectionsWordsCount(wordCount),
                                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                      color: BrutalistTheme.black.withValues(alpha: 0.55),
                                                      fontSize: 13,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: BrutalistTheme.black.withValues(alpha: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
