import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData? iconData; // Change the type to IconData
  final Color? iconColor;
  final double? widthMultiplier;
  final double? heightMultiplier;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    this.iconData, // Change the parameter name
    this.iconColor,
    this.widthMultiplier,
    this.heightMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * (widthMultiplier ?? 0.15),
      height: MediaQuery.of(context).size.height * (heightMultiplier ?? 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          iconData ??
              Icons
                  .ios_share, // Use the passed IconData or default to ios_share
          color: iconColor,
        ),
      ),
    );
  }
}
