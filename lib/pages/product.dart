import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kickavenue_clone/api/dio.dart';
import 'package:kickavenue_clone/components/product/brand_new_bottom_sheet.dart';
import 'package:kickavenue_clone/components/product/used_bottom_sheet.dart';
import 'package:kickavenue_clone/helper/currency.dart';
import 'package:kickavenue_clone/helper/general.dart';
import 'package:kickavenue_clone/interface/product.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductPage extends StatefulWidget {
  final String name;
  final String slug;
  const ProductPage({super.key, required this.slug, required this.name});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Product productData = Product(
    SKU: '',
    accept_po: 0,
    active: false,
    auto_sync: false,
    availables: [],
    biddable: false,
    colour: '',
    created_at: '',
    currency: '',
    details: '',
    dimension: '',
    display_name: '',
    editors_choice: false,
    editors_position: 0,
    expiry_date: '',
    hide_box_info: false,
    id: 0,
    nickname: '',
    price_source: '',
    product: {},
    product_id: 0,
    product_variant_images: [],
    receive_sell: false,
    release_date: '',
    retail_price: '',
    ribbon_tag: '',
    seller_commission: '',
    sex: '',
    slug: '',
    type: '',
    updated_at: '',
    useds: [],
    variant_payment_methods: [],
    vintage: false,
    voucher_applicable: false,
    wants_count: 0,
    weight: 0,
  );
  bool loading = false;
  int lowestAsk = 0;

  @override
  void initState() {
    super.initState();

    fetchProductDetail();
  }

  void fetchProductDetail() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await Api().request('products/${widget.slug}');
      final List<Availables> availableData = [];
      final List<Availables> usedsData = [];

      await response['data']['availables'].forEach((element) {
        final newData = Availables(
            approved_at: element['approved_at'],
            asking_price: element['asking_price'],
            box_condition: element['box_condition'],
            bulk_id: element['bulk_id'],
            consignment_id: element['consignment_id'],
            created_at: element['created_at'],
            created_source: element['created_source'],
            currency: element['currency'],
            day_lefts: element['day_lefts'],
            defects: element['defects'],
            display_item: element['display_item'],
            expiry: element['expiry'],
            highest_bid: HighestBid.fromJson(element['highest_bid']),
            id: element['id'],
            is_expired: element['is_expired'],
            minus_conditions: element['minus_conditions'],
            missing_accessories: element['missing_accessories'],
            note: element['note'],
            origin_country: element['origin_country'],
            pre_order: element['pre_order'],
            pre_verified: element['pre_verified'],
            product_variant: element['product_variant'],
            product_variant_id: element['product_variant_id'],
            purchase_price: element['purchase_price'],
            quantity: element['quantity'],
            rack: element['rack'],
            size: Size.fromJson(element['size']),
            size_id: element['size_id'],
            sneakers_condition: element['sneakers_condition'],
            sneakers_defect: element['sneakers_defect'],
            sold: element['sold'],
            status: element['status'],
            subsidy_price: element['subsidy_price'],
            total_subsidy: element['total_subsidy'],
            updated_at: element['updated_at'],
            updated_source: element['updated_source'],
            user_sell_images: element['user_sell_images'],
            user_id: element['user_id'],
            yellowing: element['yellowing']);
        availableData.add(newData);
        final int currPrice = int.parse(
            newData.asking_price.substring(0, newData.asking_price.length - 3));
        if (lowestAsk == 0 || lowestAsk > currPrice) {
          setState(() {
            lowestAsk = currPrice;
          });
        }
      });

      if (response['data']['useds'].toList().isNotEmpty) {
        await response['data']['useds'].forEach((element) {
          final newData = Availables(
              approved_at: element['approved_at'],
              asking_price: element['asking_price'],
              box_condition: element['box_condition'],
              bulk_id: element['bulk_id'],
              consignment_id: element['consignment_id'],
              created_at: element['created_at'],
              created_source: element['created_source'],
              currency: element['currency'],
              day_lefts: element['day_lefts'],
              defects: element['defects'],
              display_item: element['display_item'],
              expiry: element['expiry'],
              highest_bid: HighestBid.fromJson(element['highest_bid']),
              id: element['id'],
              is_expired: element['is_expired'],
              minus_conditions: element['minus_conditions'],
              missing_accessories: element['missing_accessories'],
              note: element['note'],
              origin_country: element['origin_country'],
              pre_order: element['pre_order'],
              pre_verified: element['pre_verified'],
              product_variant: element['product_variant'],
              product_variant_id: element['product_variant_id'],
              purchase_price: element['purchase_price'],
              quantity: element['quantity'],
              rack: element['rack'],
              size: Size.fromJson(element['size']),
              size_id: element['size_id'],
              sneakers_condition: element['sneakers_condition'],
              sneakers_defect: element['sneakers_defect'],
              sold: element['sold'],
              status: element['status'],
              subsidy_price: element['subsidy_price'],
              total_subsidy: element['total_subsidy'],
              updated_at: element['updated_at'],
              updated_source: element['updated_source'],
              user_sell_images: element['user_sell_images'],
              user_id: element['user_id'],
              yellowing: element['yellowing']);
          usedsData.add(newData);
        });
      }

      final Product data = Product(
        SKU: response['data']['SKU'],
        accept_po: response['data']['accept_po'],
        active: response['data']['active'],
        auto_sync: response['data']['auto_sync'],
        availables: availableData,
        biddable: response['data']['biddable'],
        colour: response['data']['colour'],
        created_at: response['data']['created_at'],
        currency: response['data']['currency'],
        details: response['data']['details'],
        dimension: response['data']['dimension'],
        display_name: response['data']['display_name'],
        editors_choice: response['data']['editors_choice'],
        editors_position: response['data']['editors_position'],
        expiry_date: response['data']['expiry_date'],
        hide_box_info: response['data']['hide_box_info'],
        id: response['data']['id'],
        nickname: response['data']['nickname'],
        price_source: response['data']['price_source'],
        product: response['data']['product'],
        product_id: response['data']['product_id'],
        product_variant_images: response['data']['product_variant_images'],
        receive_sell: response['data']['receive_sell'],
        release_date: response['data']['release_date'],
        retail_price: response['data']['retail_price'],
        ribbon_tag: response['data']['ribbon_tag'],
        seller_commission: response['data']['seller_commission'],
        sex: response['data']['sex'],
        slug: response['data']['slug'],
        type: response['data']['type'],
        updated_at: response['data']['updated_at'],
        useds: usedsData,
        variant_payment_methods: response['data']['variant_payment_methods'],
        vintage: response['data']['vintage'],
        voucher_applicable: response['data']['voucher_applicable'],
        wants_count: response['data']['wants_count'],
        weight: response['data']['weight'],
      );
      setState(() {
        productData = data;
        loading = false;
      });
    } catch (e) {
      const snackBar = SnackBar(
        duration: Duration(milliseconds: 1500),
        content: Text("Product not found"),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      context.pop();
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
      ),
      bottomSheet: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.only(
          left: 25,
          bottom: 25,
          right: 25,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: ElevatedButton(
                  onPressed: productData.availables.isNotEmpty
                      ? () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return BrandNewBottomSheet(
                                list: productData.availables,
                              );
                            },
                          );
                        }
                      : null,
                  child: const Text('Brand New'),
                ),
              ),
            ),
            Expanded(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: ElevatedButton(
                  onPressed: productData.useds.isNotEmpty
                      ? () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return UsedBottomSheet(
                                list: productData.useds,
                              );
                            },
                          );
                        }
                      : null,
                  child: const Text('Used'),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(height: 400.0),
                            items: productData.product_variant_images.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 50),
                                      child: FadeInImage.memoryNetwork(
                                        placeholder: kTransparentImage,
                                        image: imageExtractor(i['signed_url']),
                                      ));
                                },
                              );
                            }).toList(),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                            ),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productData.display_name,
                                  maxLines: 3,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 10,
                                  ),
                                  child: const Text('Starts from'),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 10,
                                  ),
                                  child: Text(
                                    'Rp ${formatCurrency.format(lowestAsk)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                // Text(productData)
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: Colors.black12,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                              left: 25,
                              right: 25,
                              bottom: 100,
                            ),
                            width: double.infinity,
                            child: Column(
                              children: [
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  width: double.infinity,
                                  child: Text(
                                      productData.details ?? 'Lorem ipsum'),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
