class ChatUser {
  ChatUser({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.isOnline,
    required this.lastActive,
    required this.id,
    required this.pushToken,
    required this.email,
  });
  late String image;
  late String name;
  late String about;
  late String createdAt;
  late bool isOnline;
  late String lastActive;
  late String id;
  late String pushToken;
  late String email;

  //json to dart
  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? [];
    name = json['name'] ?? [];
    about = json['about'] ?? [];
    createdAt = json['created_at'] ?? [];
    isOnline = json['isOnline'] ?? [];
    lastActive = json['last_active'] ?? [];
    id = json['id'] ?? [];
    pushToken = json['push_token'] ?? [];
    email = json['email'] ?? [];
  }
  //data send to json
  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['image'] = image;
    _data['name'] = name;
    _data['about'] = about;
    _data['created_at'] = createdAt;
    _data['isOnline'] = isOnline;
    _data['last_active'] = lastActive;
    _data['id'] = id;
    _data['push_token'] = pushToken;
    _data['email'] = email;
    return _data;
  }
}
