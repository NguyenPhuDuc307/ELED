import 'package:flutter/material.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import '../services/collection_service.dart';
import 'home_screen.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  Map<String, List<String>> _collections = {};
  bool _isLoading = true;

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
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: BrutalistTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'New Collection',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'e.g. TOEFL Words...',
              hintStyle: TextStyle(color: BrutalistTheme.textMuted),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: BrutalistTheme.border, width: 1.5),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: BrutalistTheme.border, width: 1.5),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: BrutalistTheme.primary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: BrutalistTheme.textMuted, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: BrutalistTheme.primary,
                foregroundColor: BrutalistTheme.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(ctx).pop();
                  await CollectionService.createCollection(name);
                  _loadCollections();
                }
              },
              child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
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
                          '+ CREATE NEW',
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
                            'NO COLLECTIONS YET.',
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
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 40),
                                ),
                                confirmDismiss: (dir) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: context.bBg,
                                      title: Text('DELETE $name?', style: TextStyle(color: context.bBorder, fontWeight: FontWeight.w900)),
                                      content: Text('Are you sure you want to delete this collection?', style: TextStyle(color: context.bBorder)),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(false),
                                          child: Text('CANCEL', style: TextStyle(color: context.bBorder, fontWeight: FontWeight.w900)),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(backgroundColor: BrutalistTheme.secondary),
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          child: const Text('DELETE', style: TextStyle(color: BrutalistTheme.black, fontWeight: FontWeight.w900)),
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
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => HomeScreen(
                                          mode: 'COLLECTION',
                                          topicTitle: name,
                                        ),
                                      ),
                                    );
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
                                                '$wordCount words',
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
