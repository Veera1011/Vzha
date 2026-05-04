import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AskAiDialog extends StatefulWidget {
  final String contextData;
  final String title;

  const AskAiDialog({super.key, required this.contextData, required this.title});

  static void show(BuildContext context, {required String title, required String contextData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AskAiDialog(title: title, contextData: contextData),
      ),
    );
  }

  @override
  State<AskAiDialog> createState() => _AskAiDialogState();
}

class _AskAiDialogState extends State<AskAiDialog> {
  final _aiService = AiService();
  final _textController = TextEditingController();
  
  String? _response;
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    'Summarize this',
    'Explain this simply',
    'Key takeaways',
  ];

  Future<void> _ask(String question) async {
    if (question.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isLoading = true;
      _response = null;
    });
    
    try {
      final res = await _aiService.askAI(widget.contextData, question);
      if (mounted) setState(() => _response = res);
    } catch (e) {
      if (mounted) setState(() => _response = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ask AI about: ${widget.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          // Content Area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_response == null && !_isLoading) ...[
                  const Text('Ask a question or select a prompt below:', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickPrompts.map((prompt) {
                      return ActionChip(
                        label: Text(prompt),
                        onPressed: () {
                          _textController.text = prompt;
                          _ask(prompt);
                        },
                      );
                    }).toList(),
                  ),
                ],
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (_response != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Text(
                      _response!,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ask anything...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: _ask,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _ask(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
