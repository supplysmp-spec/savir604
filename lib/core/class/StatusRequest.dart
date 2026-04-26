// ignore_for_file: file_names

enum StatusRequest {
  none,
  loading,
  success,
  failure,
  serverfailure,
  serverException,
  offlinefailure,
}

String getArabicStatus(StatusRequest status) {
  switch (status) {
    case StatusRequest.success:
      return 'عاش يا وحش';
    case StatusRequest.serverException:
      return 'اطلع عند مدام حنان الدور التاني';
    default:
      return 'غير معروف';
  }
}
