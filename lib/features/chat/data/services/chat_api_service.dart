import 'package:dio/dio.dart';
import '../../../../core/network/api_services.dart';

class ChatApiService {
  // Gửi tin nhắn và nhận phản hồi từ AI
  // Theo Swagger: POST /api/chat/api/Chat
  // Body: {"message": "...", "userId": "..."}
  // Response: {"answer": "...", "sources": []}
  static Future<Response> sendMessageToAI({
    required String message,
    required String userId,
  }) async {
    final data = {
      'message': message,
      'userId': userId,
    };

    // Endpoint chính từ Swagger: /api/Chat
    // ApiServices.chatPost() sẽ thêm /api/chat prefix
    // Kết quả: /api/chat/api/Chat (đúng như Swagger)
    return await Api.chat.post('/api/Chat', data: data);
  }
}
