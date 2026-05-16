import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() =>
      _AiChatPageState();
}

class _AiChatPageState
    extends State<AiChatPage> {
  final TextEditingController controller =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  final List<Map<String, dynamic>>
      messages = [];

  bool isLoading = false;

  // PASTE YOUR GEMINI API KEY HERE
  final String apiKey =
      'AIzaSyCYQA7D3tQZ0miJl0ZXspVwGHGnxwMAmAc';

  late final GenerativeModel model;

  @override
  void initState() {
    super.initState();

    model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    messages.add({
      'isUser': false,
      'message':
          '👋 Hi! I am FresherArena AI Assistant.\n\nAsk me anything about jobs, resume, interviews, coding, careers, AI, Flutter, placements and more.',
    });
  }

  Color pageBg(bool isDark) {
    return isDark
        ? const Color(0xFF050505)
        : const Color(0xFFF5F5F5);
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();

    if (text.isEmpty || isLoading) return;

    setState(() {
      messages.add({
        'isUser': true,
        'message': text,
      });

      isLoading = true;
    });

    controller.clear();

    scrollToBottom();

    try {
      final prompt =
                    'You are FresherArena AI Assistant helping students with jobs, resumes, coding and interviews.';


      final content = [
        Content.text('$prompt\n\nUser: $text'),
      ];

     final response = await model.generateContent(
  [
    Content.text(
      '$prompt\n\nUser Question: $text',
    ),
  ],
);

final reply =
    response.text?.trim() ??
    'No response generated.';

      setState(() {
        messages.add({
          'isUser': false,
          'message': reply,
        });
      });
    } catch (e) {
      setState(() {
        messages.add({
          'isUser': false,
          'message': 'AI Error: $e',
        });
      });
    }

    setState(() {
      isLoading = false;
    });

    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController
                .position.maxScrollExtent,
            duration:
                const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor: pageBg(isDark),
      appBar: AppBar(
        backgroundColor: pageBg(isDark),
        elevation: 0,
        iconTheme: IconThemeData(
          color:
              isDark ? Colors.white : Colors.black,
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  Colors.greenAccent,
              child: const Icon(
                Icons.smart_toy,
                color: Colors.black,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Text(
              'FresherArena AI',
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding:
                  const EdgeInsets.all(18),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                final isUser =
                    message['isUser'];

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 340,
                    ),
                    margin:
                        const EdgeInsets.only(
                      bottom: 14,
                    ),
                    padding:
                        const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.greenAccent
                          : isDark
                              ? Colors.white
                                  .withOpacity(
                                  0.08,
                                )
                              : Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        24,
                      ),
                      border: Border.all(
                        color: isUser
                            ? Colors.greenAccent
                            : isDark
                                ? Colors.white10
                                : Colors.black12,
                      ),
                    ),
                    child: Text(
                      message['message'],
                      style: TextStyle(
                        color: isUser
                            ? Colors.black
                            : isDark
                                ? Colors.white
                                : Colors.black,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (isLoading)
            Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    'AI is typing...',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 16,
                sigmaY: 16,
              ),
              child: Container(
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white
                          .withOpacity(0.05)
                      : Colors.white
                          .withOpacity(0.9),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white12
                          : Colors.black12,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        decoration:
                            InputDecoration(
                          hintText:
                              'Ask anything...',
                          hintStyle:
                              const TextStyle(
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white
                                  .withOpacity(
                                  0.05,
                                )
                              : Colors.black
                                  .withOpacity(
                                  0.04,
                                ),
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                            borderSide:
                                BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) {
                          sendMessage();
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          Colors.greenAccent,
                      child: IconButton(
                        onPressed:
                            sendMessage,
                        icon: const Icon(
                          Icons.send,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}