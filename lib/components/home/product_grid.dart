import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kickavenue_clone/components/home/product_card.dart';
import 'package:kickavenue_clone/helper/general.dart';

class ProductGrid extends StatefulWidget {
  final List<dynamic> products;
  final VoidCallback fetchInitialData;
  final VoidCallback fetchNextData;
  const ProductGrid(
      {super.key,
      required this.products,
      required this.fetchInitialData,
      required this.fetchNextData});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  @override
  void initState() {
    super.initState();
    widget.fetchInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.pixels ==
            scrollNotification.metrics.maxScrollExtent) {
          widget.fetchNextData();
        }
        return false;
      },
      child: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final title = widget.products[index]['display_name'];
          final image = imageExtractor(widget.products[index]['signed_url']);
          final price = widget.products[index]['latest_price'];

          return InkWell(
            onTap: () {
              context.pushNamed("product", params: {
                'slug': widget.products[index]['slug'],
                'name': widget.products[index]['display_name'],
              });
            },
            child: ProductCard(
              title: title,
              image: image,
              price: price,
            ),
          );
        },
      ),
    );
  }
}
