class Users {
  String user_id;
  String deliveryboy_id;
  String deliveryboy_name;
  String user_name;
  String user_mobile;
  String user_user_area;
  String user_area;
  String user_is_complete;
  String is_regular;
  String is_complete;
  String area_id;
  String area_name;
  String area_image;
  String deliveryboy_order;


  Users({
    this.user_id,
    this.deliveryboy_id,
    this.deliveryboy_name,
    this.user_name,
    this.user_mobile,
    this.user_user_area,
    this.user_area,
    this.user_is_complete,
    this.is_regular,
    this.is_complete,
    this.area_id,
    this.area_name,
    this.area_image,
    this.deliveryboy_order,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      user_id: json['user_id'],
      deliveryboy_id: json['deliveryboy_id'],
      deliveryboy_name: json['deliveryboy_name'],
      user_name: json['user_name'],
      user_mobile: json['user_mobile'],
      user_user_area: json['user_user_area'],
      user_area: json['user_area'],
      user_is_complete: json['user_is_complete'],
      is_regular: json['is_regular'],
      is_complete: json['is_complete'],
      area_id: json['area_id'],
      area_name: json['area_name'],
      area_image: json['area_image'],
      deliveryboy_order: json['deliveryboy_order'],
    );
  }

}