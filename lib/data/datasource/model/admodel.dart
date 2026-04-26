class AdModel {
  final String imageUrl; // رابط الصورة
  final String title; // عنوان الإعلان

  AdModel({required this.imageUrl, required this.title});

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      imageUrl: json['image_url'], // تأكد من استخدام المفتاح الصحيح من JSON
      title: json['title'], // تأكد من استخدام المفتاح الصحيح من JSON
    );
  }
}
