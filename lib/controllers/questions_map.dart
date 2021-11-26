class QuestionsMap {
  final int id;
  final String question;
  final String answer;
  final int solved; // A bool representing if question has been solved or not
  final String hint;

  QuestionsMap({
    required this.id,
    required this.question,
    required this.answer,
    required this.solved,
    required this.hint,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "question": question,
      "answer": answer,
      "solved": solved,
      "hint": hint
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Questions {id : $id, question : $question, answer : $answer, solved : $solved, hint: $hint} ";
  }
}
