import 'package:tks/controler/productdetails/productdetails_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/constant/color.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';
import 'package:tks/view/widget/productdetails/fullscreen_gallery.dart';

class TopProductPageDetails extends GetView<ProductDetailsControllerImp> {
  const TopProductPageDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailsControllerImp>(
      builder: (controller) {
        // Loading state for images
        if (controller.imagesStatus == StatusRequest.loading) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final imgs = controller.images;
        if (imgs.isEmpty) {
          // fallback to the single item image
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 180,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255)),
              ),
              Positioned(
                top: 30.0,
                right: Get.width / 8,
                left: Get.width / 8,
                child: Hero(
                  tag: "${controller.itemsModel.itemsId}",
                  child: FallbackNetworkImage(
                    imageUrls:
                        AppImageUrls.item(controller.itemsModel.itemsImage),
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          );
        }

        // Show PageView gallery when images are available
        return SizedBox(
          height: 250,
          child: Stack(
            children: [
              PageView.builder(
                controller: Get.find<ProductDetailsControllerImp>()
                    .imagesPageController,
                onPageChanged: (i) {
                  final c = Get.find<ProductDetailsControllerImp>();
                  c.currentImageIndex = i;
                  c.update();
                },
                itemCount: imgs.length,
                itemBuilder: (context, index) {
                  final img = imgs[index];
                  final heroTag = '${controller.itemsModel.itemsId}_$index';
                  return GestureDetector(
                    onTap: () => Get.to(() => FullscreenGallery(
                          images: imgs,
                          initialIndex: index,
                          heroPrefix: '${controller.itemsModel.itemsId}',
                        )),
                    child: Hero(
                      tag: heroTag,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: FallbackNetworkImage(
                              imageUrls: AppImageUrls.item(img.imgPath),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget:
                                  const Center(child: Icon(Icons.broken_image)),
                            ),
                          ),
                          if (img.imgType == '360')
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.black45,
                                child: Icon(Icons.threesixty,
                                    color: Colors.white, size: 18),
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),

              // dots
              if (imgs.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      imgs.length,
                      (i) => GetBuilder<ProductDetailsControllerImp>(
                        builder: (c) {
                          final selected = c.currentImageIndex == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: selected ? 10 : 8,
                            height: selected ? 10 : 8,
                            decoration: BoxDecoration(
                              color: selected
                                  ? ColorApp.praimaryColor
                                  : ColorApp.praimaryColor.withOpacity(0.5),
                              shape: BoxShape.circle,
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                          color: Colors.black26, blurRadius: 4)
                                    ]
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
