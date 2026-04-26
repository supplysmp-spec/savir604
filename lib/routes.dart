// ignore_for_file: prefer_const_constructors

import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/view/notification/notification_page.dart';
import 'package:tks/view/screen/about_us.dart';
import 'package:tks/view/screen/address/adddetails.dart';
import 'package:tks/view/screen/address/view.dart';
import 'package:tks/view/screen/auth/forgetpassword/resetpassword.dart';
import 'package:tks/view/screen/auth/forgetpassword/success_resetpassword.dart';
import 'package:tks/view/screen/auth/forgetpassword/verfiyCode.dart';
import 'package:tks/view/screen/auth/login.dart';
import 'package:tks/view/screen/auth/signup.dart';
import 'package:tks/view/screen/auth/success_signup.dart';
import 'package:tks/view/screen/cart.dart';
import 'package:tks/view/screen/checkout.dart';
import 'package:tks/view/screen/comment_page.dart';
import 'package:tks/view/screen/fragrance/fragrance_gift_screen.dart';
import 'package:tks/view/screen/fragrance/fragrance_builder_screen.dart';
import 'package:tks/view/screen/fragrance/fragrance_creation_screen.dart';
import 'package:tks/view/screen/fragrance/fragrance_onboarding_screen.dart';
import 'package:tks/view/screen/fragrance/fragrance_quiz_screen.dart';
import 'package:tks/view/screen/fragrance/fragrance_result_screen.dart';
import 'package:tks/view/screen/fragrance/fragrance_selection_screen.dart';
import 'package:tks/view/screen/fragrance/fragrance_splash_screen.dart';
import 'package:tks/view/screen/homescreen.dart';
import 'package:tks/view/screen/items.dart';
import 'package:tks/view/screen/language.dart';
import 'package:tks/view/screen/orders/details.dart';
import 'package:tks/view/screen/orders/pending.dart';
import 'package:tks/view/screen/orders_archive_view.dart';
import 'package:tks/view/screen/order_success_screen.dart';
import 'package:tks/view/screen/productdetails.dart';
import 'package:tks/view/screen/setting.dart';
import 'package:tks/view/screen/support.dart';
import 'package:tks/view/screen/video_feed_page.dart';
import 'view/screen/auth/forgetpassword/forgetpassword.dart';
import 'view/screen/auth/verfiycodesignup.dart';
import 'view/screen/myfavorite.dart';

List<GetPage<dynamic>>? routes = [
  GetPage(name: "/", page: () => const FragranceSplashScreen()),
  GetPage(name: AppRoutes.fragranceSplash, page: () => const FragranceSplashScreen()),
  GetPage(name: AppRoutes.OnBording, page: () => const FragranceOnboardingScreen()),
  GetPage(name: AppRoutes.fragranceAudience, page: () => const FragranceSelectionScreen()),
  GetPage(name: AppRoutes.fragranceGift, page: () => const FragranceGiftScreen()),
  GetPage(name: AppRoutes.fragranceQuiz, page: () => const FragranceQuizScreen()),
  GetPage(name: AppRoutes.fragranceResult, page: () => const FragranceResultScreen()),
  GetPage(name: AppRoutes.fragranceBuilder, page: () => const FragranceBuilderScreen()),
  GetPage(name: AppRoutes.fragranceCreation, page: () => const FragranceCreationScreen()),

  //GetPage(name: "/", page: () => HomeScreen()),
  GetPage(name: AppRoutes.login, page: () => const Login()),
  GetPage(name: AppRoutes.SignUp, page: () => const signUp()),
  GetPage(name: AppRoutes.forgetPassword, page: () => const Forgetpassword()),
  GetPage(name: AppRoutes.verfiyCode, page: () => const Verfiycode()),
  GetPage(name: AppRoutes.resetPassword, page: () => const resetpassword()),
  GetPage(
      name: AppRoutes.successResetpassword,
      page: () => const SuccessResetPassword()),
  GetPage(name: AppRoutes.successSignUp, page: () => const SuccessSignUp()),
  GetPage(
      name: AppRoutes.verfiyCodeSignUp, page: () => const Verfiycodesignup()),
  GetPage(name: AppRoutes.homepage, page: () => const HomeScreen()),
  GetPage(name: AppRoutes.items, page: () => const Items()),
  GetPage(name: AppRoutes.productdetails, page: () => const ProductDetails()),
  GetPage(name: AppRoutes.myfavroite, page: () => const MyFavorite()),
  GetPage(name: AppRoutes.cart, page: () => Cart()),
  GetPage(name: AppRoutes.addressview, page: () => const AddressView()),
  // GetPage(name: AppRoutes.addressadd, page: () => const AddressAdd()),
  GetPage(name: AppRoutes.checkout, page: () => const Checkout()),
  GetPage(name: AppRoutes.orderSuccess, page: () => const OrderSuccessScreen()),
  GetPage(name: AppRoutes.orderspending, page: () => const OrdersPending()),
  GetPage(name: AppRoutes.ordersdetails, page: () => const OrdersDetails()),
  GetPage(
      name: AppRoutes.addressadddetails, page: () => const AddressAddDetails()),
  GetPage(name: AppRoutes.aboutus, page: () => AboutPage()),
  GetPage(name: AppRoutes.set, page: () => Settings()),
  GetPage(
      name: AppRoutes.ordersarchive_page,
      page: () => const OrdersArchivePagee()),

  GetPage(name: AppRoutes.language, page: () => const Language()),
  GetPage(name: AppRoutes.notificationPage, page: () => const NotificationPage()),
  GetPage(name: AppRoutes.comments, page: () => CommentsPage()),
  GetPage(name: AppRoutes.video, page: () => VideoFeedPage()),
];
