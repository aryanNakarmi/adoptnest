import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool showDateDivider;
  final String? dateDividerLabel;

  const MessageBubble({
    super.key,
    required this.message,
    this.showDateDivider = false,
    this.dateDividerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromUser;

    return Column(
      children: [
        if (showDateDivider && dateDividerLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    dateDividerLabel!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 14),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFDC2626),
                  child: const Icon(Icons.support_agent,
                      size: 15, color: Colors.white),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.68,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFFDC2626)
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: isUser
                            ? null
                            : Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUser
                              ? Colors.white
                              : Colors.grey.shade800,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('hh:mm a').format(message.createdAt),
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade400),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 3),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 13,
                            color: message.isRead
                                ? const Color(0xFFDC2626)
                                : Colors.grey.shade400,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isUser) const SizedBox(width: 6),
            ],
          ),
        ),
      ],
    );
  }
}
