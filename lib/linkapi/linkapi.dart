class AppLink {
  static const String baseUrl = "https://savir-technology.online/Precious";
  static const String server = baseUrl;
  static const String legacyServer = "https://savir-technology.online/Precious";
  static const String legacyServerWithoutAppPath =
      "https://savir-technology.online/Precious";
  static const String legacyServerWithAppPath =
      "https://savir-technology.online/Precious";
  static const String legacyUploadsServer = "https://savir-technology.online/Precious";
  static const String legacyUploadsServerWithAppPath =
      "https://savir-technology.online/Precious";
  static const String legacyTal9inUploadsServer = "https://savir-technology.online/Precious";
  static const String legacyTal9inUploadsServerWithAppPath =
      "https://savir-technology.online/Precious";

  static const String paymobPayment = "$baseUrl/paymob_payment.php";

//==============================={image}============================================//
  static const String imageststatic = "$baseUrl/uploud";
  static const String imagestCategories = "$baseUrl/uploud/categories";
  static const String imagestItems = "$baseUrl/uploud/items";
  static const String imagestItemsAlt = "$baseUrl/uploads/items";

//==============================={auth}============================================//
  static const String signUp = "$baseUrl/auth/signup.php";
  static const String verifycodessignup = "$baseUrl/auth/verfiycode.php";
  static const String login = "$baseUrl/auth/login.php";
  static const String socialLogin = "$baseUrl/auth/social_login.php";
  static const String resend = "$baseUrl/auth/resend.php";

//============================={forgetpassword}====================================//
  static const String checkEmail = "$baseUrl/forgetpassword/checkemail.php";
  static const String resetPassword = "$baseUrl/forgetpassword/resetpassword.php";
  static const String verifycodeforgetpassword =
      "$baseUrl/forgetpassword/verfiycode.php";

//==================================={home}========================================//
  static const String homepage = "$baseUrl/home-ecommerse/home.php";

//===================================={items}======================================//
  static const String items = "$baseUrl/items/items.php";
  static const String itemImages = "$baseUrl/items/images.php";
  static const String getProductVariants = "$baseUrl/items/getProductVariants.php";
  static const String fragranceProfileGet = "$baseUrl/fragrance/profile/get.php";
  static const String fragranceProfileUpsert =
      "$baseUrl/fragrance/profile/upsert.php";
  static const String fragranceQuizList = "$baseUrl/fragrance/quiz/list.php";
  static const String fragranceQuizSubmit = "$baseUrl/fragrance/quiz/submit.php";
  static const String fragranceBuilderSave =
      "$baseUrl/fragrance/builder/save.php";
  static const String fragrancePricingConfig =
      "$baseUrl/fragrance/pricing/config.php";
  static const String userProfileGet = "$baseUrl/users/profile/get.php";
  static const String userProfileDiscover = "$baseUrl/users/profile/discover.php";
  static const String userProfileUpdate = "$baseUrl/users/profile/update.php";
  static const String userProfileUploadImage =
      "$baseUrl/dash/users/profile/upload_image.php";
  static const String followsToggle = "$baseUrl/social/follows/toggle.php";
  static const String followsList = "$baseUrl/social/follows/list.php";
  static const String communityPostsFeed = "$baseUrl/community/posts/feed.php";
  static const String communityPostsCreate =
      "$baseUrl/community/posts/create_v2.php";
  static const String communityPostsComments =
      "$baseUrl/community/posts/comments.php";
  static const String communityPostsAddComment =
      "$baseUrl/community/posts/add_comment.php";
  static const String communityPostsDelete =
      "$baseUrl/community/posts/delete.php";
  static const String communityPostsDeleteComment =
      "$baseUrl/community/posts/delete_comment.php";
  static const String communityPostsInteractions =
      "$baseUrl/community/posts/interactions.php";
  static const String communityPostsToggleLike =
      "$baseUrl/community/posts/toggle_like.php";
  static const String storiesFeed = "$baseUrl/stories/feed.php";
  static const String storiesCreate = "$baseUrl/stories/create_v2.php";
  static const String storiesView = "$baseUrl/stories/view.php";
  static const String storiesViewers = "$baseUrl/stories/viewers.php";
  static const String storiesReact = "$baseUrl/stories/react.php";
  static const String storiesComment = "$baseUrl/stories/comment.php";
  static const String savedPerfumesList = "$baseUrl/saved_perfumes/list.php";
  static const String customPerfumesList = "$baseUrl/custom_perfumes/list.php";
  static const String chatConversationsCreate =
      "$baseUrl/chat/conversations/create.php";
  static const String chatConversationsList =
      "$baseUrl/chat/conversations/list.php";
  static const String chatConversationsMessages =
      "$baseUrl/chat/conversations/messages.php";
  static const String chatConversationsSend =
      "$baseUrl/chat/conversations/send.php";
  static const String reelsFeed = "$baseUrl/reels/feed.php";
  static const String reelsCreate = "$baseUrl/reels/create.php";
  static const String reelsDelete = "$baseUrl/reels/delete.php";

//========================================{favorite}=======================================//
  static const String favoriteAdd = "$baseUrl/favorite/add.php";
  static const String favoriteRemove = "$baseUrl/favorite/remove.php";
  static const String favoriteView = "$baseUrl/favorite/view.php";
  static const String deletefromfavroite =
      "$baseUrl/favorite/deletefromfavroite.php";

//=========================================={cart}===============================================//
  static const String cartadd = "$baseUrl/cart/add.php";
  static const String cartdelete = "$baseUrl/cart/delete.php";
  static const String cartview = "$baseUrl/cart/view.php";
  static const String cartgetcountitems = "$baseUrl/cart/getcountitems.php";
  static const String checkcoupon = "$baseUrl/coupon/checkcoupon.php";

//=========================================={search}==================================//
  static const String searchitems = "$baseUrl/items/search.php";

//====================================================================================//
  static const String checkout = "$baseUrl/orders/checkout.php";
  static const String deliveryMethods = "$baseUrl/delivery_methods/list.php";

//====================================================================================//
  static const String addressView = "$baseUrl/address/view.php";
  static const String addressAdd = "$baseUrl/address/add.php";
  static const String addressDelete = "$baseUrl/address/delete.php";

//===================================================================================//
  static const String ordersarchive = "$baseUrl/orders/archive.php";
  static const String ordersdetails = "$baseUrl/orders/details.php";
  static const String ordersdelete = "$baseUrl/orders/delete.php";
  static const String pendingorders = "$baseUrl/orders/pending.php";
  static const String notification = "$baseUrl/notification.php";
  static const String notificationMarkRead =
      "$baseUrl/notifications/mark_read.php";
  static const String notificationMarkAllRead =
      "$baseUrl/notifications/mark_all_read.php";
  static const String ads = "$baseUrl/ads/ads.php";

//===================================================================================//
  static const String addRating = "$baseUrl/ratings/add_rating.php";
  static const String updateRating = "$baseUrl/ratings/update_rating.php";
  static const String getRatings = "$baseUrl/ratings/get_ratings.php";
  static const String topRated = "$baseUrl/ratings/top_rated_items.php";
  static const String deleteRating = "$baseUrl/ratings/delete_rating.php";

//===================================================================================//
  static const String initPayment = "$baseUrl/payments/init_payment.php";

//===================================================================================//
  static const String getVideos = "$baseUrl/videos/get_videos.php";
  static const String addLike = "$baseUrl/videos/add_like.php";
  static const String increaseView = "$baseUrl/videos/increase_view.php";
  static const String getComments = "$baseUrl/videos/get_comments.php";
  static const String addComment = "$baseUrl/videos/add_comment.php";
  static const String likeComment = "$baseUrl/videos/like_comment.php";
  static const String deleteVideoComment = "$baseUrl/videos/delete_comment.php";
  static const String videoInteractions = "$baseUrl/videos/interactions.php";

  static String normalizeUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    var normalized = url.trim();

    normalized = normalized.replaceFirst(
      '$legacyUploadsServerWithAppPath/uploads/',
      '$server/uploads/',
    );
    normalized = normalized.replaceFirst(
      '$legacyUploadsServer/uploads/',
      '$server/uploads/',
    );
    normalized = normalized.replaceFirst(
      '$legacyTal9inUploadsServerWithAppPath/uploads/',
      '$server/uploads/',
    );
    normalized = normalized.replaceFirst(
      '$legacyTal9inUploadsServer/uploads/',
      '$server/uploads/',
    );
    normalized = normalized.replaceFirst(
      '$legacyServerWithAppPath/uploads/',
      '$server/uploads/',
    );
    normalized = normalized.replaceFirst(
      '$legacyServerWithAppPath/uploud/',
      '$server/uploud/',
    );
    normalized =
        normalized.replaceFirst('$legacyServer/uploads/', '$server/uploads/');
    normalized = normalized.replaceFirst(
      '$legacyServerWithoutAppPath/uploads/',
      '$server/uploads/',
    );
    normalized = normalized.replaceFirst(
      '$legacyServerWithoutAppPath/uploud/',
      '$server/uploud/',
    );

    if (normalized.startsWith(legacyServerWithAppPath)) {
      normalized =
          normalized.replaceFirst(legacyServerWithAppPath, server);
    } else if (normalized.startsWith(legacyServer) &&
        !normalized.startsWith('$legacyServer/savir604/')) {
      normalized = normalized.replaceFirst(legacyServer, server);
    } else if (normalized.startsWith(legacyServerWithoutAppPath) &&
        !normalized.startsWith('$legacyServerWithoutAppPath/savir604/')) {
      normalized = normalized.replaceFirst(legacyServerWithoutAppPath, server);
    }

    return normalized.replaceAll(' ', '%20');
  }
}
