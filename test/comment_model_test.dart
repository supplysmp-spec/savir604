import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tks/data/datasource/model/comment_model.dart';

void main() {
  test('parse example comments response without throwing', () {
    const jsonStr = r'''
{"status":"success","data":[{"comment_id":59,"video_id":4,"user_id":104,"comment_text":"kk","comment_likes":0,"comment_date":"2025-11-27 14:07:07","users_name":"islam ashraf","user_role":"user","replies":[]},{"comment_id":58,"video_id":4,"user_id":104,"comment_text":"حلو","comment_likes":0,"comment_date":"2025-11-27 13:29:22","users_name":"islam ashraf","user_role":"user","replies":[]},{"comment_id":19,"video_id":4,"user_id":104,"comment_text":"wow","comment_likes":1,"comment_date":"2025-11-23 18:14:44","users_name":"islam ashraf","user_role":"user","replies":[]},{"comment_id":17,"video_id":4,"user_id":104,"comment_text":"wow","comment_likes":1,"comment_date":"2025-11-22 19:45:23","users_name":"islam ashraf","user_role":"user","replies":[]},{"comment_id":14,"video_id":4,"user_id":88,"comment_text":"cool","comment_likes":2,"comment_date":"2025-11-07 16:39:38","users_name":"Ahmed","user_role":"user","replies":[{"comment_id":18,"user_id":104,"comment_text":"cool","comment_likes":1,"comment_date":"2025-11-22 19:45:33","users_name":"islam ashraf","user_role":"user"}]}]}
''';

    final parsed = json.decode(jsonStr) as Map<String, dynamic>;
    expect(parsed['status'], 'success');

    final list = parsed['data'] as List<dynamic>;

    final models = list
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(models.length, 5);
    // last item has replies
    expect(models.last.replies.length, 1);
    expect(models.last.replies.first.commentId, 18);
    // replies may lack video_id -> ensure the parsing gives a safe default (0)
    expect(models.last.replies.first.videoId, isA<int>());
  });
}
