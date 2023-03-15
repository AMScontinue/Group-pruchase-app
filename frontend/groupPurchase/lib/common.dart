// ignore: camel_case_types
class groupInfo {
  const groupInfo({
    required this.id,
    required this.name,
    required this.description,
    // ignore: non_constant_identifier_names
    required this.begin_time,
    // ignore: non_constant_identifier_names
    required this.end_time,
    required this.post,
    required this.participants,
    required this.commodity,
    required this.link,
  });
  final int id;
  final String name;
  final String description;

  // ignore: non_constant_identifier_names
  final String begin_time;

  // ignore: non_constant_identifier_names
  final String end_time;
  final String post;
  final int participants;
  final List<Commodity> commodity;
  final link;
}

class Commodity {
  const Commodity({
    required this.cid,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.number,
    required this.miao,
  });

  final int cid;
  final String name;
  final String imageUrl;
  final String description;
  final int price;
  final int number;
  final bool miao;
}

class Order{
  const Order({
    required this.orderid,
    required this.groupname,
    required this.username,
    required this.commodityname,
    required this.cid,
    required this.commodityamount,
    required this.money,
    required this.pay_time,
    required this.post,
});
    final int orderid;
    final String groupname;
    final String username;
    final String commodityname;
    final int cid;
    final int commodityamount;
    final int money;
    final String pay_time;
    final String post;
}
