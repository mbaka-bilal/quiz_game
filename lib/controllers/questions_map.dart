class QuestionsMap {
  final int id;
  final String question;
  final String answer;

  final String hint;

  QuestionsMap({
    required this.id,
    required this.question,
    required this.answer,
    required this.hint,
  });

  Map<String, dynamic> toMap() {
    return {"id": id, "question": question, "answer": answer, "hint": hint};
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Questions {id : $id, question : $question, answer : $answer, hint: $hint} ";
  }
}
