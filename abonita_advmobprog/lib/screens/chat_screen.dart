import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchChatController = TextEditingController();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  String? _currentUserEmail;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserEmail();
  }

  Future<void> _loadCurrentUserEmail() async {
    final userData = await _userService.getUserData();

    if (!mounted) return;

    setState(() {
      _currentUserEmail = userData['email']?.toString();
    });
  }

  @override
  void dispose() {
    _searchChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20.h),

          // Enhancement 2: Chat List – Search Functionality
          // Displays a search bar at the top of the chat list.
          // Allows users to search for other users by name or email.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 23.w),
            child: TextField(
              controller: _searchChatController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search chat...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: (_searchChatController.text.isNotEmpty)
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            _searchChatController.clear();
                            _searchText = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Updates the search text whenever the user types.
              // setState rebuilds the list to display matching users.
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),

          SizedBox(height: 10.h),

          // Users Stream
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _chatService.getUsersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: Center(
                    child: CustomText(
                      text: 'Error loading users',
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: Center(
                    child: CustomText(text: 'No users found', fontSize: 16.sp),
                  ),
                );
              }

              // Enhancement 2: Filters users based on the search input.
              // Matches the entered text against each user's name or email.
              // Converts the text to lowercase for case-insensitive searching.
              final users = snapshot.data!.where((user) {
                final name = (user['firstName'] ?? '').toString();
                final email = (user['email'] ?? '').toString();
                final query = _searchText.toLowerCase();

                return name.toLowerCase().contains(query) ||
                    email.toLowerCase().contains(query);
              }).toList();

              // Displays a message when no users match the search.
              if (users.isEmpty) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: Center(
                    child: CustomText(
                      text: 'No messages found...',
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            currentUserEmail: _currentUserEmail!,
                            tappedUser: user,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: const Color(0xFFFFF7FF),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFFC325),
                          foregroundColor: const Color(0xFF354591),
                          child: CustomText(
                            text:
                                user['firstName'] != null &&
                                    user['firstName'].toString().isNotEmpty
                                ? user['firstName'][0].toUpperCase()
                                : '?',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: CustomText(
                          text: user['firstName'] ?? 'Unknown',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        subtitle: CustomText(
                          text: user['email'] ?? 'No email',
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
