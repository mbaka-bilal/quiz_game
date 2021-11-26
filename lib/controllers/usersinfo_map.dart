class UsersInfoMap {
  final int id;
  final int livesLeft;

  UsersInfoMap({
    required this.id,
    required this.livesLeft

});

  Map<String,dynamic> toMap(){
    return {
      "id": id,
      "livesLeft": livesLeft
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
    return "Usersinfo {id:$id, livesleft: $livesLeft}";
  }


}