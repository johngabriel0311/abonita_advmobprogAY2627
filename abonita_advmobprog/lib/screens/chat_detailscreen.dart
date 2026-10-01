import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/chat_service.dart';

final ChatService chatService = ChatService();

class ChatDetailScreen extends StatefulWidget {
  final String currentUserEmail;
  final Map<String, dynamic> tappedUser;

  const ChatDetailScreen({
    Key? key,
    required this.currentUserEmail,
    required this.tappedUser,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgCtrl = TextEditingController();

  final FocusNode _msgFocus = FocusNode();

  final ScrollController _scrollCtrl = ScrollController();

  late Future<String> _currentUserIdFuture;

  // Message currently being replied to.
  Map<String, dynamic>? _replyingTo;

  // Message currently hovered or selected.
  String? _hoveredMessageId;

  // Stores messages that are currently being sent.
  //
  // Each message has its own sending state.
  // This means one slow message will NOT disable
  // the entire chat screen.
  final Map<String, Map<String, dynamic>> _pendingMessages = {};

  static const Color _primaryColor = Color(0xFF354591);

  static const Color _backgroundColor = Color(0xFFFFF7FF);

  static const Color _accentColor = Color(0xFFFFC325);

  @override
  void initState() {
    super.initState();

    _currentUserIdFuture = _getCurrentUserId();

    // Mark received messages as seen
    // when the conversation is opened.
    _currentUserIdFuture
        .then((currentUserId) {
          final receiverId = (widget.tappedUser['uid'] ?? '').toString();

          if (receiverId.isNotEmpty) {
            chatService.markMessagesAsSeen(currentUserId, receiverId);
          }
        })
        .catchError((error) {
          debugPrint('Unable to mark messages as seen: $error');
        });
  }

  Future<String> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No authenticated Firebase user found.');
    }

    return user.uid;
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _msgFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // TIME FORMAT
  // ============================================================

  String _formatTime(dynamic timestamp) {
    if (timestamp is! Timestamp) {
      return '';
    }

    final dateTime = timestamp.toDate();

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // REPLY
  // ============================================================

  void _startReply(Map<String, dynamic> data) {
    setState(() {
      _replyingTo = {'message': data['message'], 'senderId': data['senderId']};

      _hoveredMessageId = null;
    });

    _msgFocus.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });

    _msgFocus.requestFocus();
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _send(String currentUserId, String receiverId) async {
    final text = _msgCtrl.text.trim();

    if (text.isEmpty) {
      return;
    }

    // Save the reply information before clearing it.
    final replyTo = _replyingTo;

    // Create a unique temporary ID for this message.
    final temporaryMessageId =
        'pending_${DateTime.now().microsecondsSinceEpoch}';

    // Create a temporary local message.
    //
    // This allows us to immediately show:
    // "Sending..."
    //
    // while Firebase is processing the message.
    final pendingMessage = {
      '_messageId': temporaryMessageId,
      'senderId': currentUserId,
      'senderEmail': widget.currentUserEmail,
      'receiverId': receiverId,
      'message': text,
      'timestamp': Timestamp.now(),
      'status': 'sending',
      'replyTo': replyTo,
      '_isPending': true,
    };

    // Add the pending message to the local list.
    setState(() {
      _pendingMessages[temporaryMessageId] = pendingMessage;

      // Clear the reply preview.
      _replyingTo = null;
    });

    // Clear the input immediately.
    _msgCtrl.clear();

    // Keep the keyboard open.
    _msgFocus.requestFocus();

    try {
      // Send to Firestore.
      //
      // The Send button remains enabled while
      // this is happening.
      await chatService.sendMessage(receiverId, text, replyTo: replyTo);

      // Firebase successfully accepted the message.
      //
      // Remove the temporary "Sending..." message.
      // The Firestore StreamBuilder will now show
      // the real message with its timestamp/status.
      if (mounted) {
        setState(() {
          _pendingMessages.remove(temporaryMessageId);
        });
      }
    } catch (e) {
      if (!mounted) return;

      // If sending fails, remove the temporary
      // message from the chat.
      setState(() {
        _pendingMessages.remove(temporaryMessageId);
      });

      // Put the message back into the input.
      _msgCtrl.text = text;

      // Restore the reply preview if there was one.
      if (replyTo != null) {
        setState(() {
          _replyingTo = replyTo;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      _msgFocus.requestFocus();
    }
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _buildAvatar(String name, {double radius = 21}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _accentColor,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: radius * 0.9,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  // ============================================================
  // REPLY PREVIEW INSIDE MESSAGE
  // ============================================================

  Widget _buildReplyMessagePreview(
    Map<String, dynamic> reply,
    bool isMe,
    Color textColor,
  ) {
    final repliedMessage = (reply['message'] ?? '').toString();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 7.h),
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withOpacity(0.12)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        repliedMessage,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10.sp,
          color: textColor.withOpacity(0.75),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  // ============================================================
  // REPLY BUTTON
  // ============================================================

  Widget _buildReplyButton({
    required Map<String, dynamic> data,
    required String messageId,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final isHovered = _hoveredMessageId == messageId;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isHovered ? 1.0 : 0.0,
      child: Material(
        color: isDarkMode ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            _startReply(data);
          },
          child: Padding(
            padding: EdgeInsets.all(7.w),
            child: Icon(
              Icons.reply_rounded,
              size: 17.sp,
              color: isDarkMode ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessageBubble(Map<String, dynamic> data, String currentUserId) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final message = (data['message'] ?? '').toString();

    final senderId = (data['senderId'] ?? '').toString();

    final isMe = senderId == currentUserId;

    final timestamp = data['timestamp'];

    final messageId = (data['_messageId'] ?? '').toString();

    final replyTo = data['replyTo'];

    final isPending = data['_isPending'] == true;

    final Color receivedBubbleColor = isDarkMode
        ? const Color(0xFF2C2C2C)
        : Colors.white;

    final Color receivedTextColor = isDarkMode ? Colors.white : Colors.black87;

    final Color receivedTimeColor = isDarkMode
        ? Colors.white54
        : Colors.grey.shade500;

    final messageStatus = (data['status'] ?? 'sent').toString();

    // ============================================================
    // MESSAGE BUBBLE
    // ============================================================

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * (isMe ? 0.78 : 0.68),
      ),
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isMe ? _primaryColor : receivedBubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
          bottomLeft: Radius.circular(isMe ? 18.r : 4.r),
          bottomRight: Radius.circular(isMe ? 4.r : 18.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Show the message being replied to.
          if (replyTo is Map)
            _buildReplyMessagePreview(
              Map<String, dynamic>.from(replyTo),
              isMe,
              isMe ? Colors.white : receivedTextColor,
            ),

          // Message text.
          Text(
            message.isNotEmpty ? message : '[empty]',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              color: isMe ? Colors.white : receivedTextColor,
              height: 1.4,
            ),
          ),

          SizedBox(height: 4.h),

          // Timestamp + sending state/checkmarks.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isPending ? 'Sending...' : _formatTime(timestamp),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9.sp,
                  color: isMe ? Colors.white70 : receivedTimeColor,
                ),
              ),

              // Only show checkmarks after
              // Firebase has successfully
              // saved the message.
              if (isMe && !isPending) ...[
                SizedBox(width: 4.w),
                Icon(
                  messageStatus == 'seen'
                      ? Icons.done_all_rounded
                      : Icons.check_rounded,
                  size: 13.sp,
                  color: messageStatus == 'seen'
                      ? const Color(0xFF64B5F6)
                      : Colors.white70,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    // ============================================================
    // SENT MESSAGE
    // ============================================================

    if (isMe) {
      return MouseRegion(
        onEnter: (_) {
          setState(() {
            _hoveredMessageId = messageId;
          });
        },
        onExit: (_) {
          setState(() {
            _hoveredMessageId = null;
          });
        },
        child: GestureDetector(
          onLongPress: () {
            setState(() {
              _hoveredMessageId = messageId;
            });
          },
          child: TweenAnimationBuilder<double>(
            key: ValueKey(messageId),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(12 * (1 - value), 0),
                  child: child,
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Reply button.
                _buildReplyButton(data: data, messageId: messageId),

                SizedBox(width: 2.w),

                // Your message.
                Flexible(child: bubble),
              ],
            ),
          ),
        ),
      );
    }

    // ============================================================
    // RECEIVED MESSAGE
    // ============================================================

    final firstName = (widget.tappedUser['firstName'] ?? '').toString();

    final username = (widget.tappedUser['username'] ?? '').toString();

    final avatarName = firstName.isNotEmpty ? firstName : username;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredMessageId = messageId;
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredMessageId = null;
        });
      },
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            _hoveredMessageId = messageId;
          });
        },
        child: TweenAnimationBuilder<double>(
          key: ValueKey(messageId),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(-12 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Recipient profile.
              Padding(
                padding: EdgeInsets.only(left: 10.w, bottom: 5.h),
                child: _buildAvatar(avatarName, radius: 20),
              ),

              // Message + Reply button.
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Message bubble.
                    bubble,

                    SizedBox(width: 2.w),

                    // Reply button.
                    _buildReplyButton(data: data, messageId: messageId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color pageBackground = isDarkMode
        ? Theme.of(context).scaffoldBackgroundColor
        : _backgroundColor;

    final Color composerBackground = isDarkMode
        ? Theme.of(context).colorScheme.surface
        : Colors.white;

    final Color inputBackground = isDarkMode
        ? const Color(0xFF242424)
        : _backgroundColor;

    final Color primaryTextColor = Theme.of(context).colorScheme.onSurface;

    final tappedUserId = (widget.tappedUser['uid'] ?? '').toString();

    final firstName = (widget.tappedUser['firstName'] ?? '').toString();

    final lastName = (widget.tappedUser['lastName'] ?? '').toString();

    final tappedUserName = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : (widget.tappedUser['username'] ?? 'User').toString();

    return FutureBuilder<String>(
      future: _currentUserIdFuture,
      builder: (context, snap) {
        // ========================================================
        // LOADING
        // ========================================================

        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: pageBackground,
            body: const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            ),
          );
        }

        // ========================================================
        // ERROR
        // ========================================================

        if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
          return Scaffold(
            backgroundColor: pageBackground,
            appBar: AppBar(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              title: const Text(
                'Chat',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
            body: Center(
              child: Text(
                'Unable to load your user data.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: primaryTextColor,
                ),
              ),
            ),
          );
        }

        final currentUserId = snap.data!;

        // ========================================================
        // INVALID RECIPIENT
        // ========================================================

        if (tappedUserId.isEmpty) {
          return Scaffold(
            backgroundColor: pageBackground,
            appBar: AppBar(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              title: const Text(
                'Chat',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'This user does not have a Firebase UID.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: primaryTextColor,
                  ),
                ),
              ),
            ),
          );
        }

        // ========================================================
        // CHAT SCREEN
        // ========================================================

        return Scaffold(
          backgroundColor: pageBackground,

          // ======================================================
          // APP BAR
          // ======================================================
          appBar: AppBar(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: false,
            titleSpacing: 0,
            title: Row(
              children: [
                _buildAvatar(tappedUserName, radius: 20),

                SizedBox(width: 12.w),

                Expanded(
                  child: Text(
                    tappedUserName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // BODY
          // ======================================================
          body: Column(
            children: [
              // ==================================================
              // MESSAGE LIST
              // ==================================================
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatService.getMessage(currentUserId, tappedUserId),
                  builder: (context, snapshot) {
                    // Loading messages.
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: _primaryColor),
                      );
                    }

                    // Error loading messages.
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Text(
                            'Error loading messages:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.sp,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    // ==================================================
                    // CREATE FIRESTORE MESSAGE DATA
                    // ==================================================

                    final firestoreMessages = docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      return {
                        ...data,
                        '_messageId': doc.id,
                        '_isPending': false,
                      };
                    }).toList();

                    // ==================================================
                    // ADD PENDING MESSAGES
                    // ==================================================

                    final allMessages = [
                      ...firestoreMessages,
                      ..._pendingMessages.values,
                    ];

                    // Sort newest first because
                    // the ListView is reversed.
                    allMessages.sort((a, b) {
                      final aTime = a['timestamp'];

                      final bTime = b['timestamp'];

                      if (aTime is Timestamp && bTime is Timestamp) {
                        return bTime.compareTo(aTime);
                      }

                      return 0;
                    });

                    // ==================================================
                    // EMPTY CHAT
                    // ==================================================

                    if (allMessages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: composerBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                size: 42.sp,
                                color: _primaryColor,
                              ),
                            ),

                            SizedBox(height: 16.h),

                            Text(
                              'Start a conversation',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? _accentColor
                                    : _primaryColor,
                              ),
                            ),

                            SizedBox(height: 6.h),

                            Text(
                              'Send a message to $tappedUserName',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.sp,
                                color: primaryTextColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // ==================================================
                    // MESSAGE LIST
                    // ==================================================

                    return ListView.builder(
                      controller: _scrollCtrl,
                      reverse: true,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      itemCount: allMessages.length,
                      itemBuilder: (context, index) {
                        final data = allMessages[index];

                        return _buildMessageBubble(data, currentUserId);
                      },
                    );
                  },
                ),
              ),

              // ==================================================
              // REPLY PREVIEW
              // ==================================================
              if (_replyingTo != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 8.w, 8.h),
                  decoration: BoxDecoration(
                    color: composerBackground,
                    border: Border(
                      top: BorderSide(color: Colors.black.withOpacity(0.06)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3.w,
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Replying to message',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: _primaryColor,
                              ),
                            ),

                            SizedBox(height: 2.h),

                            Text(
                              (_replyingTo!['message'] ?? '').toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.sp,
                                color: primaryTextColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: _cancelReply,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

              // ==================================================
              // MESSAGE INPUT
              // ==================================================
              SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                  decoration: BoxDecoration(
                    color: composerBackground,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          isDarkMode ? 0.15 : 0.05,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // ==================================================
                      // TEXT FIELD
                      // ==================================================
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          focusNode: _msgFocus,
                          textInputAction: TextInputAction.send,
                          minLines: 1,
                          maxLines: 4,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.sp,
                            color: primaryTextColor,
                          ),
                          onSubmitted: (_) {
                            _send(currentUserId, tappedUserId);
                          },
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.sp,
                              color: primaryTextColor.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: inputBackground,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 13.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.r),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.r),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? Colors.white12
                                    : Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.r),
                              borderSide: const BorderSide(
                                color: _primaryColor,
                                width: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 9.w),

                      // ==================================================
                      // SEND BUTTON
                      // ==================================================
                      SizedBox(
                        height: 46.h,
                        width: 46.w,
                        child: Material(
                          color: _primaryColor,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              _send(currentUserId, tappedUserId);
                            },
                            child: Icon(
                              Icons.send_rounded,
                              size: 21.sp,
                              color: _accentColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
