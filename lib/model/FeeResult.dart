import 'package:hermes/kit/Util.dart';

class FeeSnapshot {

  static String room_fee_snapshot_key=":room:fee:snapshot:";


  DateTime date;

  double electFee;
  double waterFee;
  double rent;

  double total;

  List<FeeItem> items;

  FeeSnapshot(
      {this.date,this.electFee, this.waterFee, this.rent, this.total, this.items});




  factory FeeSnapshot.fromJson(Map<String, dynamic> json) {

    return FeeSnapshot(
      date: Util.parseDay(json['date'] as String),
      electFee: json['electFee'] as double,
      waterFee: json['waterFee'] as double,
      rent: json['rent'] as double,
      total: json['total'] as double,
      items: (json['items'] as List).map((e) => FeeItem.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': Util.formatDay(date),
        'electFee': electFee,
        'waterFee': waterFee,
        'rent': rent,
        'total': total,
        'items': items,
      };

  @override
  String toString() {
    return 'FeeSnapshot{electFee: $electFee, waterFee: $waterFee, rent: $rent, total: $total, items: $items}';
  }
}

class FeeItem {
  String name;
  String desc;
  double fee;

  FeeItem({this.name, this.desc, this.fee});

  factory FeeItem.get(String name, String desc, double fee) {
    return FeeItem(name: name, desc: desc, fee: fee);
  }

  factory FeeItem.fromJson(Map<String, dynamic> json) {
    return FeeItem(
        name: json['name'] as String,
        desc: json['desc'] as String,
        fee: json['fee'] as double);
  }

  Map<String, dynamic> toJson() => {'name': name, 'desc': desc, 'fee': fee};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          desc == other.desc &&
          fee == other.fee;

  @override
  int get hashCode => name.hashCode ^ desc.hashCode ^ fee.hashCode;

  @override
  String toString() {
    return 'FeeItem{name: $name, desc: $desc, fee: $fee}';
  }
}
