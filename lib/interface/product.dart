// ignore_for_file: non_constant_identifier_names

class Product {
  final List<Availables> availables;
  final Map<String, dynamic> product;
  final List<dynamic> product_variant_images;
  final List<Availables> useds;
  final List<dynamic> variant_payment_methods;
  final String SKU;
  final int accept_po;
  final bool active;
  final bool auto_sync;
  final bool biddable;
  final String colour;
  final String created_at;
  final String currency;
  final dynamic details;
  final dynamic dimension;
  final String display_name;
  final bool editors_choice;
  final int editors_position;
  final String? expiry_date;
  final bool hide_box_info;
  final int id;
  final String? nickname;
  final String price_source;
  final int product_id;
  final bool receive_sell;
  final String? release_date;
  final String? retail_price;
  final dynamic ribbon_tag;
  final dynamic seller_commission;
  final String sex;
  final String slug;
  final String? type;
  final String updated_at;
  final bool vintage;
  final bool voucher_applicable;
  final int wants_count;
  final int weight;

  Product({
    required this.SKU,
    required this.accept_po,
    required this.active,
    required this.auto_sync,
    required this.availables,
    required this.biddable,
    required this.colour,
    required this.created_at,
    required this.currency,
    required this.details,
    required this.dimension,
    required this.display_name,
    required this.editors_choice,
    required this.editors_position,
    required this.expiry_date,
    required this.hide_box_info,
    required this.id,
    required this.nickname,
    required this.price_source,
    required this.product,
    required this.product_id,
    required this.product_variant_images,
    required this.receive_sell,
    required this.release_date,
    required this.retail_price,
    required this.ribbon_tag,
    required this.seller_commission,
    required this.sex,
    required this.slug,
    required this.type,
    required this.updated_at,
    required this.useds,
    required this.variant_payment_methods,
    required this.vintage,
    required this.voucher_applicable,
    required this.wants_count,
    required this.weight,
  });
}

class Availables {
  final String? approved_at;
  final String asking_price;
  final String box_condition;
  final String? bulk_id;
  final String? consignment_id;
  final String created_at;
  final String? created_source;
  final String currency;
  final int day_lefts;
  final List<dynamic> defects;
  final bool display_item;
  final dynamic expiry;
  final HighestBid highest_bid;
  final int id;
  final bool is_expired;
  final int? minus_conditions;
  final bool missing_accessories;
  final String? note;
  final dynamic origin_country;
  final bool pre_order;
  final bool pre_verified;
  final Map<String, dynamic> product_variant;
  final int product_variant_id;
  final String? purchase_price;
  final int quantity;
  final String? rack;
  final Size size;
  final int size_id;
  final String sneakers_condition;
  final bool sneakers_defect;
  final int sold;
  final String status;
  final String? subsidy_price;
  final dynamic total_subsidy;
  final String updated_at;
  final dynamic updated_source;
  final List<dynamic> user_sell_images;
  final int user_id;
  final bool yellowing;

  Availables({
    required this.approved_at,
    required this.asking_price,
    required this.box_condition,
    required this.bulk_id,
    required this.consignment_id,
    required this.created_at,
    required this.created_source,
    required this.currency,
    required this.day_lefts,
    required this.defects,
    required this.display_item,
    required this.expiry,
    required this.highest_bid,
    required this.id,
    required this.is_expired,
    required this.minus_conditions,
    required this.missing_accessories,
    required this.note,
    required this.origin_country,
    required this.pre_order,
    required this.pre_verified,
    required this.product_variant,
    required this.product_variant_id,
    required this.purchase_price,
    required this.quantity,
    required this.rack,
    required this.size,
    required this.size_id,
    required this.sneakers_condition,
    required this.sneakers_defect,
    required this.sold,
    required this.status,
    required this.subsidy_price,
    required this.total_subsidy,
    required this.updated_at,
    required this.updated_source,
    required this.user_sell_images,
    required this.user_id,
    required this.yellowing,
  });

  factory Availables.fromJson(Map<String, dynamic> json) => Availables(
        approved_at: json['approved_at'],
        asking_price: json['asking_price'],
        box_condition: json['box_condition'],
        bulk_id: json['bulk_id'],
        consignment_id: json['consignment_id'],
        created_at: json['created_at'],
        created_source: json['created_source'],
        currency: json['currency'],
        day_lefts: json['day_lefts'],
        defects: List<dynamic>.from(json['defects'].map((x) => x)),
        display_item: json['display_item'],
        expiry: json['expiry'],
        highest_bid: HighestBid.fromJson(json['highest_bid']),
        id: json['id'],
        is_expired: json['is_expired'],
        minus_conditions: json['minus_conditions'],
        missing_accessories: json['missing_accessories'],
        note: json['note'],
        origin_country: json['origin_country'],
        pre_order: json['pre_order'],
        pre_verified: json['pre_verified'],
        product_variant: Map<String, dynamic>.from(json['product_variant']),
        product_variant_id: json['product_variant_id'],
        purchase_price: json['purchase_price'],
        quantity: json['quantity'],
        rack: json['rack'],
        size: Size.fromJson(json['size']),
        size_id: json['size_id'],
        sneakers_condition: json['sneakers_condition'],
        sneakers_defect: json['sneakers_defect'],
        sold: json['sold'],
        status: json['status'],
        subsidy_price: json['subsidy_price'],
        total_subsidy: json['total_subsidy'],
        updated_at: json['updated_at'],
        updated_source: json['updated_source'],
        user_sell_images:
            List<dynamic>.from(json['user_sell_images'].map((x) => x)),
        user_id: json['user_id'],
        yellowing: json['yellowing'],
      );

  Map<String, dynamic> toJson() => {
        'approved_at': approved_at,
        'asking_price': asking_price,
        'box_condition': box_condition,
        'bulk_id': bulk_id,
        'consignment_id': consignment_id,
        'created_at': created_at,
        'created_source': created_source,
        'currency': currency,
        'day_lefts': day_lefts,
        'defects': defects,
        'display_item': display_item,
        'expiry': expiry,
        'highest_bid': highest_bid.toJson(),
        'id': id,
        'is_expired': is_expired,
        'minus_conditions': minus_conditions,
        'missing_accessories': missing_accessories,
        'note': note,
        'origin_country': origin_country,
        'pre_order': pre_order,
        'pre_verified': pre_verified,
        'product_variant': product_variant,
        'product_variant_id': product_variant_id,
        'purchase_price': purchase_price,
        'quantity': quantity,
        'rack': rack,
        'size': size.toJson(),
        'size_id': size_id,
        'sneakers_condition': sneakers_condition,
        'sneakers_defect': sneakers_defect,
        'sold': sold,
        'status': status,
        'subsidy_price': subsidy_price,
        'total_subsidy': total_subsidy,
        'updated_at': updated_at,
        'updated_source': updated_source,
        'user_sell_images': user_sell_images,
        'user_id': user_id,
        'yellowing': yellowing,
      };
}

class Size {
  final String? EUR;
  final String? UK;
  final String? US;
  final int? brand_id;
  final String? cm;
  final String created_at;
  final int id;
  final String? inch;
  final String sex;
  final String updated_at;

  Size({
    required this.EUR,
    required this.UK,
    required this.US,
    required this.brand_id,
    required this.cm,
    required this.created_at,
    required this.id,
    required this.inch,
    required this.sex,
    required this.updated_at,
  });

  factory Size.fromJson(Map<dynamic, dynamic> json) {
    return Size(
      EUR: json['EUR'] as String?,
      UK: json['UK'] as String?,
      US: json['US'] as String?,
      brand_id: json['brand_id'] as int?,
      id: json['id'] as int,
      cm: json['cm'] as String?,
      created_at: json['created_at'] as String,
      inch: json['inch'] as String?,
      sex: json['sex'] as String,
      updated_at: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'EUR': EUR,
        'UK': UK,
        'US': US,
        'brand_id': brand_id,
        'cm': cm,
        'created_at': created_at,
        'id': id,
        'inch': inch,
        'sex': sex,
        'updated_at': updated_at,
      };
}

class HighestBid {
  final int amount;
  final int id;
  final int product_variant_id;
  final int size_id;
  final dynamic ref_number;

  HighestBid({
    required this.amount,
    required this.id,
    required this.product_variant_id,
    required this.ref_number,
    required this.size_id,
  });

  factory HighestBid.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) {
      return HighestBid(
          amount: 0, id: 0, product_variant_id: 0, ref_number: 0, size_id: 0);
    }

    return HighestBid(
        amount: json['amount'] as int,
        id: json['id'] as int,
        product_variant_id: json['product_variant_id'] as int,
        ref_number: json['ref_number'] as dynamic,
        size_id: json['size_id'] as int);
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'id': id,
        'product_variant_id': product_variant_id,
        'ref_number': ref_number,
        'size_id': size_id,
      };
}
