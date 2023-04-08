import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickavenue_clone/components/global/drawer.dart';
import 'package:kickavenue_clone/components/home/product_grid.dart';
import 'package:kickavenue_clone/provider/products.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var isLoading = false;

  void showLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List products = ref.watch(productProvider);
    final notifier = ref.read(productProvider.notifier);
    fetchInitialData() => notifier.fetch(true, showLoading, hideLoading);
    fetchNextData() => notifier.fetch(false, showLoading, hideLoading);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kick Avenue"),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search Product',
                  hintMaxLines: 1,
                  errorMaxLines: 1,
                  helperMaxLines: 1,
                ),
                onSubmitted: (value) {
                  notifier.changeKeyword = value;
                  fetchInitialData();
                },
              ),
            ),
            Expanded(
              child: ProductGrid(
                products: products,
                fetchInitialData: fetchInitialData,
                fetchNextData: fetchNextData,
              ),
            ),
            isLoading ? const CircularProgressIndicator() : const SizedBox(),
          ],
        ),
      ),
      drawer: const DrawerWidget(),
    );
  }
}
