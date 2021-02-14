
class Room{


  String name;

  int sort;

  Room({this.name,this.sort});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      name: json['name'] as String,
      sort: json['sort'] as int
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'sort': sort,
      };



  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Room &&
              runtimeType == other.runtimeType &&
              name == other.name;

  @override
  int get hashCode => name.hashCode;

}