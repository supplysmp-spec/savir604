import 'dart:convert';

import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';

class FragranceBuilderData {
  FragranceBuilderData(this.crud);

  final Crud crud;

  Future<dynamic> saveCreation({
    required String userId,
    required String creationName,
    required String bottleSizeId,
    required List<String> topNotes,
    required List<String> middleNotes,
    required List<String> baseNotes,
    required int compatibility,
    required int creativity,
    required int balance,
    required double estimatedPrice,
  }) async {
    final response = await crud.postData(
      AppLink.fragranceBuilderSave,
      <String, dynamic>{
        'usersid': userId,
        'creation_name': creationName,
        'bottle_size_id': bottleSizeId,
        'top_notes_json': jsonEncode(topNotes),
        'middle_notes_json': jsonEncode(middleNotes),
        'base_notes_json': jsonEncode(baseNotes),
        'compatibility': compatibility.toString(),
        'creativity': creativity.toString(),
        'balance': balance.toString(),
        'estimated_price': estimatedPrice.toStringAsFixed(2),
      },
    );
    return response.fold((l) => l, (r) => r);
  }
}
