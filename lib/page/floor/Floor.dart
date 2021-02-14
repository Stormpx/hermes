
class Floor{

  String name;

  int sort=0;


  Floor({ this.name,this.sort});

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
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
          other is Floor &&
              runtimeType == other.runtimeType &&
              name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'Floor{name: $name}';
  }
}