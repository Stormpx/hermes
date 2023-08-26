import 'package:hermes/kit/Util.dart';
import 'package:hermes/page/room/Model.dart';

class FeeSnapshot {

  static String room_fee_snapshot_key=":room:fee:snapshot:";


  DateTime date;

  double electFee;
  double waterFee;
  double rent;

  double electAmount;
  double waterAmount;

  double total;

  List<FeeItem>? items;

  FeeSnapshot(
      {required this.date,required this.electFee, required this.waterFee, required this.rent, required this.total, this.items,required this.electAmount,required this.waterAmount});




  factory FeeSnapshot.fromJson(Map<String, dynamic> json) {
    return FeeSnapshot(
      date: Util.parseDay(json['date'] as String),
      electFee: json['electFee'] as double,
      waterFee: json['waterFee'] as double,
      rent: json['rent'] as double,
      electAmount: json['electAmount'] as double,
      waterAmount: json['waterAmount'] as double,
      total: json['total'] as double,
      items: (json['items'] as List?)?.map((e) => FeeItem.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': Util.formatDay(date),
        'electFee': electFee,
        'waterFee': waterFee,
        'rent': rent,
        'total': total,
    'electAmount': electAmount,
    'waterAmount':waterAmount,
        'items': items,
      };

  @override
  String toString() {
    return 'FeeSnapshot{date: $date, electFee: $electFee, waterFee: $waterFee, rent: $rent, electAmount: $electAmount, waterAmount: $waterAmount, total: $total, items: $items}';
  }
}

