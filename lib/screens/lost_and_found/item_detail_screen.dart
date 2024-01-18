// ignore_for_file: unused_field

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_icon_button.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String? title;
  final String? image;
  final String? address;
  const ItemDetailsScreen(
      {super.key,
      required this.title,
      required this.image,
      required this.address});

  @override
  ItemDetailsScreenState createState() => ItemDetailsScreenState();
}

class ItemDetailsScreenState extends State<ItemDetailsScreen> {
  bool _isOverlayVisible = true; // Set to true to start with the overlay up
  double _overlayHeight = 0.35;
  double _imageHeight = 0.65;

  void toggleOverlayVisibility() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
      if (_isOverlayVisible) {
        _overlayHeight = 0.35;
        _imageHeight = 0.65;
      } else {
        _overlayHeight = 0.5; // Adjust these values as needed
        _imageHeight = 0.5;
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: MediaQuery.of(context).size.height * .55,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: '${widget.image}',
                    fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Positioned(
                    top: 35,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomIconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          iconData: Icons.arrow_back,
                          iconColor: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Text(
                      '${widget.title}',
                      style: const TextStyle(
                        color: Color(0xFF2A3F4B),
                        fontSize: 20,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w700,
                        height: 1.09,
                        letterSpacing: 0.40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: MediaQuery.of(context).size.height * _overlayHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on),
                            Text(" ${widget.address}"),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
                    const Padding(
                      padding: EdgeInsets.only(left: 25, right: 10),
                      child: Align(
                        child: Text(
                          "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).",
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 14,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w400,
                            height: 1.57,
                            letterSpacing: 0.17,
                          ),
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
