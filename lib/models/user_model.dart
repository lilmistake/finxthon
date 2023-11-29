import "./models.dart";

class User {
  final String name;
  List<Product> products;
  final String pfp;
  String cid;

  User({
    required this.name,
    this.products = const [],
    this.pfp =
        "https://i.imgur.com/WHvNu6S.png",
    required this.cid,
  });

  toJson() {
    return {
      "name": name,
      "products": products.map((e) => e.toJson()).toList(),
      "pfp": pfp
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        cid: json["cid"],
        name: json["name"] ?? "No Name",
        products: ((json["products"] ?? []) as List<dynamic>)
            .map((e) => Product.fromJson(e))
            .toList(),
        pfp: json["pfp"] ??
            "https://i.imgur.com/WHvNu6S.png");
  }
}
