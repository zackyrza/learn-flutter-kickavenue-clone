import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PromoProductBottomSheet extends ConsumerStatefulWidget {
  const PromoProductBottomSheet({super.key});

  @override
  ConsumerState<PromoProductBottomSheet> createState() =>
      _PromoProductBottomSheetState();
}

class _PromoProductBottomSheetState
    extends ConsumerState<PromoProductBottomSheet> {
  final List<Map<String, dynamic>> promoProduct = [
    {
      "categoryVisible": "all",
      "description": "<p>1 unit of Display n Co</p>",
      "img_url":
          "https://kickavenue-assets.s3.amazonaws.com/product-addons/undefined/24cc01e8fdbaf53fcde5e3f029156a94.jpeg",
      "isActive": true,
      "isSelected": true,
      "price": "230000.00",
      "title": "BLACK BOKS 2.0 by Display n Co",
      "value": "DISPLAYNCOBLACK"
    },
    {
      "categoryVisible": "all",
      "description": "",
      "img_url":
          "https://kickavenue-assets.s3.amazonaws.com/product-addons/11/46be877837f0529d44a7f040781c0205.jpeg",
      "isActive": true,
      "isSelected": true,
      "price": "250000.00",
      "title": "CLEAR BOKS 2.0 by Display n Co",
      "value": "DISPLAYNCOCLEAR-AD20"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(promoProduct[index]['title']),
            subtitle: Text(promoProduct[index]['value']),
            onTap: () {
              Navigator.pop(context, promoProduct[index]);
            },
          );
        },
        itemCount: promoProduct.length,
      ),
    );
  }
}
