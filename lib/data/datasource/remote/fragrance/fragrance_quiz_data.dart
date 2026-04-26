import 'dart:convert';

import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';

class FragranceQuizData {
  FragranceQuizData(this.crud);

  final Crud crud;

  Future<dynamic> getQuestions({
    required String lang,
    String? audience,
    String? giftType,
  }) async {
    final response = await crud.postData(
      AppLink.fragranceQuizList,
      <String, dynamic>{
        'lang': lang,
        'audience': audience ?? 'all',
        'gift_type': giftType ?? '',
      },
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> submitQuiz({
    required String userId,
    required String lang,
    required Map<String, String> answers,
    String? audience,
    String? giftType,
  }) async {
    final response = await crud.postData(
      AppLink.fragranceQuizSubmit,
      <String, dynamic>{
        'usersid': userId,
        'lang': lang,
        'audience': audience ?? 'all',
        'gift_type': giftType ?? '',
        'answers_json': jsonEncode(answers),
      },
    );
    return response.fold((l) => l, (r) => r);
  }
}
