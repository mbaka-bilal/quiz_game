class StagesMap {
  int id;
  String stagename;
  int lastStop;
  int locked;
  int done;

  StagesMap(
      {required this.id,
      required this.stagename,
      required this.lastStop,
      required this.locked,
      required this.done});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "stagename": stagename,
      "laststop": lastStop,
      "locked": locked,
      "done": done,
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    // return super.toString();
    return "Stages {id : $id, stagename : $stagename, laststop: $lastStop,locked : $locked, done : $done} ";
  }
}
