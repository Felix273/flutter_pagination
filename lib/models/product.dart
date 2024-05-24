class Product {
  int? id;
  String? title;
  double? price; // Change this from int? to double?
  String? thumbnail;

  Product({this.id, this.title, this.price, this.thumbnail});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = (json['price'] as num).toDouble(); // Ensure correct type conversion
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['price'] = price;
    data['thumbnail'] = thumbnail;
    return data;
  }
}
