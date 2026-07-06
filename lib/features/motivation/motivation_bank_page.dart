import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'motivation_provider.dart';
import '../../database/collections/motivation.dart';

class MotivationBankPage extends ConsumerStatefulWidget {
  const MotivationBankPage({super.key});

  @override
  ConsumerState<MotivationBankPage> createState() => _MotivationBankPageState();
}

class _MotivationBankPageState extends ConsumerState<MotivationBankPage> {
  final _quoteController = TextEditingController();

  @override
  void dispose() {
    _quoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotesState = ref.watch(motivationNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Motivation Bank", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Add custom quote row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quoteController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Add custom daily inspiration...",
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: const Color(0xFF161616),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final text = _quoteController.text.trim();
                    if (text.isEmpty) return;
                    ref.read(motivationNotifierProvider.notifier).addQuote(text);
                    _quoteController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child: const Icon(Icons.add, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quotes list
            Expanded(
              child: quotesState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
                data: (quotes) {
                  if (quotes.isEmpty) {
                    return const Center(
                      child: Text(
                        "No quotes in bank. Seed default quotes or add your own.",
                        style: TextStyle(color: Colors.white30, fontSize: 14),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: quotes.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final quote = quotes[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "\"${quote.quote}\"",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            ref.read(motivationNotifierProvider.notifier).deleteQuote(quote.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
