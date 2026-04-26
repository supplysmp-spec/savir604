class SupportModel {
  final int userId;
  final String complaint;

  SupportModel({required this.userId, required this.complaint});

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'complaint': complaint,
    };
  }
}
