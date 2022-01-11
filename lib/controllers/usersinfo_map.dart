class UsersInfoMap {
  final int id;
  final int livesLeft;
  final int sound;
  final String dateTime;
  final String playerName;

  UsersInfoMap({
    required this.id,
    required this.livesLeft,
    required this.sound,
    required this.dateTime,
    required this.playerName,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     "id": id,
  //     "livesLeft": livesLeft,
  //     "dateTime": dateTime,
  //   };
  // }

  @override
  String toString() {
    // TODO: implement toString
    return "Usersinfo {id:$id, livesleft: $livesLeft,dateTime:$dateTime,playerName: $playerName}";
  }
}
