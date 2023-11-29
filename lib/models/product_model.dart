class Product {
  final String batchId;
  final String name;
  final String desc;
  final double weight; // in kg
  final int createdTs;
  final List<double> location;
  final List<String> rawMaterials;
  final String? chainCid; // only set if it has raw materials
  // todo: add chainCid when creating a product and it has raw materials

  Product(
      {required this.batchId,
      required this.name,
      required this.desc,
      required this.weight,
      required this.createdTs,
      required this.location,
      required this.rawMaterials,
      this.chainCid});

  toJson() {
    return {
      "batchId": batchId,
      "name": name,
      "desc": desc,
      "weight": weight,
      "createdTs": createdTs,
      "location": location,
      "rawMaterials": rawMaterials,
      "chainCid": chainCid ?? ""
    };
  }

  ProductChain toChain() {
    return ProductChain(
        batchId: batchId,
        name: name,
        desc: desc,
        weight: weight,
        createdTs: createdTs,
        location: location,
        rawMaterials: []);
  }

  Product copyWith({
    String? batchId,
    String? name,
    String? desc,
    double? weight,
    int? createdTs,
    List<double>? location,
    List<String>? rawMaterials,
    String? chainCid,
  }) {
    return Product(
      batchId: batchId ?? this.batchId,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      weight: weight ?? this.weight,
      createdTs: createdTs ?? this.createdTs,
      location: location ?? this.location,
      rawMaterials: rawMaterials ?? this.rawMaterials,
      chainCid: chainCid ?? this.chainCid,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      batchId: json["batchId"],
      name: json["name"],
      desc: json["desc"],
      weight: double.parse((json["weight"] as double).toStringAsFixed(3)),
      createdTs: json["createdTs"],
      chainCid: (json['chainCid'] == null || json['chainCid'].length == 0)
          ? null
          : json['chainCid'],
      location:
          (json["location"] as List<dynamic>).map((v) => v as double).toList(),
      rawMaterials: (json["rawMaterials"] as List<dynamic>)
          .map((v) => v as String)
          .toList(),
    );
  }
}

class ProductChain {
  final String batchId;
  final String name;
  final String desc;
  final double weight; // in kg
  final int createdTs;
  final List<double> location;
  final List<ProductChain> rawMaterials;

  ProductChain(
      {required this.batchId,
      required this.name,
      required this.desc,
      required this.weight,
      required this.createdTs,
      required this.location,
      required this.rawMaterials});

  toJson() {
    return {
      "batchId": batchId,
      "name": name,
      "desc": desc,
      "weight": weight,
      "createdTs": createdTs,
      "location": location,
      "rawMaterials": rawMaterials.map((e) => e.toJson()).toList()
    };
  }

  toProduct() {
    return Product(
        batchId: batchId,
        name: name,
        desc: desc,
        weight: weight,
        createdTs: createdTs,
        location: location,
        rawMaterials: rawMaterials.map((e) => e.name).toList());
  }

  ProductChain copyWith({
    String? batchId,
    String? name,
    String? desc,
    double? weight,
    int? createdTs,
    List<double>? location,
    List<ProductChain>? rawMaterials,
  }) {
    return ProductChain(
      batchId: batchId ?? this.batchId,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      weight: weight ?? this.weight,
      createdTs: createdTs ?? this.createdTs,
      location: location ?? this.location,
      rawMaterials: rawMaterials ?? this.rawMaterials,
    );
  }

  factory ProductChain.fromJson(Map<String, dynamic> json) {
    return ProductChain(
      batchId: json["batchId"],
      name: json["name"],
      desc: json["desc"],
      weight: double.parse((json["weight"] as double).toStringAsFixed(3)),
      createdTs: json["createdTs"],
      location:
          (json["location"] as List<dynamic>).map((v) => v as double).toList(),
      rawMaterials: (json["rawMaterials"] as List<dynamic>)
          .map((v) => ProductChain.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}
