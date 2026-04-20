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
          backgroundColor: context.bBg,
          shape: Border.all(color: context.bBorder, width: 4),
          title: Text(
            'NEW COLLECTION',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.bBorder,
                ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: context.bBorder,
                ),
            decoration: InputDecoration(
              hintText: 'e.g. TOEFL Words...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.bBorder, width: 2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: BrutalistTheme.secondary, width: 4),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('CANCEL', style: TextStyle(color: context.bBorder, fontWeight: FontWeight.w900)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: BrutalistTheme.secondary,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                side: BorderSide(color: context.bBorder, width: 2),
              ),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(ctx).pop();
                  await CollectionService.createCollection(name);
                  _loadCollections();
                }
              },
              child: const Text('CREATE', style: TextStyle(color: BrutalistTheme.black, fontWeight: FontWeight.w900)),
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
        title: Text(
          'COLLECTIONS',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.bBorder, strokeWidth: 6),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BrutalistCard(
                    backgroundColor: context.bBorder,
                    onTap: _showCreateCollectionDialog,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: _collections.keys.length,
                          itemBuilder: (context, index) {
                            final name = _collections.keys.elementAt(index);
                            final wordCount = _collections[name]!.length;
                            final isEven = index % 2 == 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Dismissible(
                                key: Key(name),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: const Icon(Icons.delete_forever, color: Colors.white, size: 40),
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
                                  backgroundColor: isEven ? BrutalistTheme.primary : BrutalistTheme.accent,
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
                                    padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name.toUpperCase(),
                                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                                      fontSize: 32,
                                                      color: BrutalistTheme.black,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: BrutalistTheme.white,
                                                  border: Border.all(color: BrutalistTheme.black, width: 2),
                                                ),
                                                child: Text(
                                                  '$wordCount WORDS',
                                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        color: BrutalistTheme.black,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward,
                                          size: 40,
                                          color: BrutalistTheme.black,
                                        ),
                                      ],
                                    ),
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
