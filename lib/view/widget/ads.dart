// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdBanner extends StatefulWidget {
  const AdBanner({Key? key}) : super(key: key);

  @override
  _AdBannerState createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  List<dynamic> _adsList = [];
  String? _currentAdImageUrl;
  String? _currentAdLinkUrl;
  int _currentAdIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAds();
    _scheduleAdSwitch();
  }

  Future<void> _fetchAds() async {
    try {
      final response = await http
          .get(Uri.parse("https://savir.site/Zahra_store/zahra/ads/ads.php"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _adsList = data;
            _currentAdImageUrl = _adsList[0]['image_url'];
            _currentAdLinkUrl = _adsList[0]['link_url'];
          });
        }
      } else {
        setState(() {
          _adsList = [];
          _currentAdImageUrl = null;
          _currentAdLinkUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        _adsList = [];
        _currentAdImageUrl = null;
        _currentAdLinkUrl = null;
      });
    }
  }

  void _scheduleAdSwitch() {
    if (_adsList.isNotEmpty) {
      Future.delayed(Duration(seconds: 10), () {
        setState(() {
          _currentAdIndex = (_currentAdIndex + 1) % _adsList.length;
          _currentAdImageUrl = _adsList[_currentAdIndex]['image_url'];
          _currentAdLinkUrl = _adsList[_currentAdIndex]['link_url'];
        });

        _scheduleAdSwitch(); // إعادة جدولة تغيير الإعلان بعد 10 ثوانٍ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width; // الحصول على عرض الشاشة

    return (_adsList.isNotEmpty &&
            _currentAdImageUrl != null &&
            _currentAdLinkUrl != null)
        ? GestureDetector(
            onTap: () {},
            child: Container(
              width: screenWidth, // ضبط العرض ليكون عرض الشاشة
              height: 100, // يمكنك تعديل الارتفاع حسب الحجم المطلوب للبنر
              color: Colors.grey[200],
              child: Center(
                child: Image.network(
                  _currentAdImageUrl!,
                  width: screenWidth, // ضبط عرض الصورة ليكون عرض الشاشة
                  height: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Center(
                        child: Text(
                            'Place your ad here and join T.K.s Advertising and Publicity Company'));
                  },
                ),
              ),
            ),
          )
        : Container(
            width: screenWidth,
            height: 100,
            color: Colors.grey[200],
            child: Center(
              child: Text(
                'لا يوجد إعلان حالياً',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          );
  }
}
