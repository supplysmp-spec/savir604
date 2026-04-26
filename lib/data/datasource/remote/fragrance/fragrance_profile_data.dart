import 'dart:convert';

import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';

class FragranceProfileData {
  FragranceProfileData(this.crud);

  final Crud crud;

  Future<dynamic> getProfile(String userId) async {
    final response = await crud.postData(
      AppLink.fragranceProfileGet,
      <String, dynamic>{
        'usersid': userId,
      },
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> upsertProfile({
    required String userId,
    String? audience,
    String? giftType,
    Map<String, String>? quizAnswers,
    String? personalityType,
    List<String>? recommendedNotes,
    List<String>? recommendedFamilies,
    String? signatureStyle,
    String? resultKey,
    String? creationName,
    int? compatibilityScore,
    int? creativityScore,
    int? balanceScore,
    String? resultPayloadJson,
    bool profileCompleted = false,
  }) async {
    final Map<String, String> encodedQuizAnswers = quizAnswers == null
        ? <String, String>{}
        : <String, String>{
            for (final MapEntry<String, String> entry in quizAnswers.entries)
              entry.key: entry.value,
          };

    final response = await crud.postData(
      AppLink.fragranceProfileUpsert,
      <String, dynamic>{
        'usersid': userId,
        'audience': audience ?? '',
        'gift_type': giftType ?? '',
        'quiz_answers_json': encodedQuizAnswers.isEmpty ? '' : jsonEncode(encodedQuizAnswers),
        'personality_type': personalityType ?? '',
        'recommended_notes': recommendedNotes == null ? '' : recommendedNotes.join(','),
        'recommended_families': recommendedFamilies == null ? '' : recommendedFamilies.join(','),
        'signature_style': signatureStyle ?? '',
        'result_key': resultKey ?? '',
        'creation_name': creationName ?? '',
        'compatibility_score': compatibilityScore?.toString() ?? '',
        'creativity_score': creativityScore?.toString() ?? '',
        'balance_score': balanceScore?.toString() ?? '',
        'result_payload_json': resultPayloadJson ?? '',
        'profile_completed': profileCompleted ? '1' : '0',
      },
    );
    return response.fold((l) => l, (r) => r);
  }
}
