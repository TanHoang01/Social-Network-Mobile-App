class userModel {
  final String id;
  final String email;
  final String fullName;
  final String avatar;
  final List favoriteList;
  final List saveList;
  final List follow;
  final String id_social;
  userModel(
      {required this.id,
      required this.email,
      required this.fullName,
      required this.avatar,
      required this.favoriteList,
      required this.saveList,
      required this.follow,
      required this.id_social,});

  factory userModel.fromDocument(Map<String, dynamic> doc) {
    return userModel(
        avatar: doc['avatar'],
        email: doc['email'],
        favoriteList: doc['favoriteList'],
        fullName: doc['fullName'],
        saveList: doc['saveList'],
        id: doc['id'],
        id_social: doc['id_social'],
        follow: doc['follow'],
        );
  }
}