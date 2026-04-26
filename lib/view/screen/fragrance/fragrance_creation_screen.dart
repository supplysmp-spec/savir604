import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tks/core/functions/currency_formatter.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/controler/fragrance/fragrance_flow_controller.dart';

class FragranceCreationScreen extends StatelessWidget {
  const FragranceCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FragranceFlowController controller = ensureFragranceFlowController();

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: GetBuilder<FragranceFlowController>(
          init: controller,
          builder: (FragranceFlowController logic) {
            final FragranceProfileResult result = logic.profileResult;
            final FragranceBottleSize? bottleSize = logic.selectedBottleSize;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _CircleIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: Get.back,
                      ),
                      const Expanded(
                        child: Text(
                          'Your Creation',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'myfont',
                            fontSize: 25,
                          ),
                        ),
                      ),
                      _CircleIconButton(
                        icon: Icons.refresh_rounded,
                        onTap: logic.resetBuilder,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFFE9CF94), Color(0xFFD0A95E)],
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xFFD6B878).withValues(alpha: 0.32),
                            blurRadius: 26,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events_outlined,
                        size: 40,
                        color: Color(0xFF1A160F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171614),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF433627), width: 1.4),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xFFD6B878).withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: logic.creationNameController,
                        onChanged: logic.updateCreationName,
                        textAlign: TextAlign.center,
                        maxLength: 24,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'myfont',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: result.creationName,
                          hintStyle: TextStyle(
                            color: const Color(0xFFE8D7B1).withValues(alpha: 0.28),
                            fontFamily: 'myfont',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Your Signature Creation',
                      style: TextStyle(
                        color: const Color(0xFFD2AE69).withValues(alpha: 0.92),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(child: _BottlePreview()),
                  const SizedBox(height: 24),
                  if (logic.bottleSizes.isNotEmpty) ...<Widget>[
                    const Text(
                      'Bottle Size',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: logic.bottleSizes
                          .map(
                            (FragranceBottleSize size) => _SizeChip(
                              label: size.label,
                              selected: logic.selectedBottleSizeId == size.id,
                              onTap: () => logic.selectBottleSize(size.id),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171614),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF3B3125)),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _InfoMetric(
                              label: 'Volume',
                              value: bottleSize?.label ?? '--',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoMetric(
                              label: 'Total Grams',
                              value: logic.totalGrams.toStringAsFixed(1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoMetric(
                              label: 'Price',
                              value: CurrencyFormatter.egp(logic.estimatedPrice),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    children: <Widget>[
                      _ScoreCard(label: 'Compatibility', value: '${result.compatibility}%'),
                      const SizedBox(width: 12),
                      _ScoreCard(label: 'Creativity', value: '${result.creativity}%'),
                      const SizedBox(width: 12),
                      _ScoreCard(label: 'Balance', value: '${result.balance}%'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _NotesSection(title: 'Top Notes', notes: logic.topNotes),
                  const SizedBox(height: 16),
                  _NotesSection(title: 'Middle Notes', notes: logic.middleNotes),
                  const SizedBox(height: 16),
                  _NotesSection(title: 'Base Notes', notes: logic.baseNotes),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final bool added = await logic.addCreationToCart();
                        if (added) {
                          Get.offAllNamed(AppRoutes.cart);
                          return;
                        }

                        Get.snackbar(
                          'Unable to add creation',
                          'Please try saving your custom perfume again.',
                          backgroundColor: const Color(0xFF2A1616),
                          colorText: Colors.white,
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: Text(
                        'Add to Cart - ${CurrencyFormatter.egp(logic.estimatedPrice)}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6B878),
                        foregroundColor: const Color(0xFF1A160F),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: logic.shareActionInProgress
                              ? null
                              : () => _openCreationShareSheet(
                                    context: context,
                                    logic: logic,
                                    mode: _CreationShareMode.post,
                                  ),
                          icon: const Icon(Icons.bookmark_border_rounded),
                          label: const Text('Share as Post'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE8D7B1),
                            backgroundColor: const Color(0xFF242321),
                            side: const BorderSide(color: Color(0xFF433627)),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: logic.shareActionInProgress
                              ? null
                              : () => _openCreationShareSheet(
                                    context: context,
                                    logic: logic,
                                    mode: _CreationShareMode.story,
                                  ),
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Add to Story'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE8D7B1),
                            backgroundColor: const Color(0xFF242321),
                            side: const BorderSide(color: Color(0xFF433627)),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _CreationShareMode { post, story }

Future<void> _openCreationShareSheet({
  required BuildContext context,
  required FragranceFlowController logic,
  required _CreationShareMode mode,
}) async {
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  XFile? selectedImage;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF12110F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (BuildContext modalContext) {
      return StatefulBuilder(
        builder: (BuildContext modalContext, void Function(void Function()) setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.of(modalContext).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  mode == _CreationShareMode.post ? 'Share Creation as Post' : 'Add Creation to Story',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Attach a bottle image and write a short description with your fragrance details.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.64),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setModalState(() => selectedImage = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1A17),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF433627)),
                    ),
                    child: Column(
                      children: <Widget>[
                        const Icon(Icons.add_a_photo_outlined, color: Color(0xFFD6B878), size: 28),
                        const SizedBox(height: 10),
                        Text(
                          selectedImage == null ? 'Upload bottle image' : selectedImage!.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFE8D7B1),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Write a caption or story about this bottle...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.34)),
                    filled: true,
                    fillColor: const Color(0xFF1B1A17),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFF433627)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFF433627)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFD6B878)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(modalContext).pop();
                      final Map<String, dynamic>? response = mode == _CreationShareMode.post
                          ? await logic.shareCreationAsPost(
                              description: descriptionController.text,
                              imageFile: selectedImage,
                            )
                          : await logic.shareCreationAsStory(
                              description: descriptionController.text,
                              imageFile: selectedImage,
                            );

                      final bool success = response != null && response['status'] == 'success';
                      Get.snackbar(
                        success ? 'Shared successfully' : 'Unable to share creation',
                        success
                            ? (mode == _CreationShareMode.post
                                ? 'Your bottle is now live in the community.'
                                : 'Your bottle was added to stories.')
                            : (response?['message']?.toString() ??
                                'Please check the image and try again.'),
                        backgroundColor: success
                            ? const Color(0xFF1D2A1D)
                            : const Color(0xFF2A1616),
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6B878),
                      foregroundColor: const Color(0xFF16120D),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(mode == _CreationShareMode.post ? 'Publish Post' : 'Publish Story'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? const Color(0xFFD6B878) : const Color(0xFF171614),
          border: Border.all(
            color: selected ? const Color(0xFFD6B878) : const Color(0xFF433627),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF16120D) : const Color(0xFFE8D7B1),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoMetric extends StatelessWidget {
  const _InfoMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.52),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFD6B878),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF433727)),
        ),
        child: Icon(icon, color: const Color(0xFFD2B06D), size: 18),
      ),
    );
  }
}

class _BottlePreview extends StatelessWidget {
  const _BottlePreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 140,
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFF85734F),
                  Color(0xFF776846),
                  Color(0xFF6B5D3E),
                ],
              ),
              border: Border.all(color: const Color(0xFFE0C48A).withValues(alpha: 0.32)),
            ),
          ),
          Positioned(
            top: 18,
            child: Container(
              width: 62,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFFD9BE83),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            top: 70,
            child: Container(
              width: 120,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFF85734F),
                    Color(0xFF726343),
                    Color(0xFF68593B),
                  ],
                ),
                border: Border.all(color: const Color(0xFFE0C48A).withValues(alpha: 0.45)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF242321),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFD5B06B),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({
    required this.title,
    required this.notes,
  });

  final String title;
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: notes
              .map(
                (String note) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: const Color(0xFF2E2A24),
                    border: Border.all(color: const Color(0xFF4D3E28)),
                  ),
                  child: Text(
                    note,
                    style: const TextStyle(
                      color: Color(0xFFE8D7B1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
