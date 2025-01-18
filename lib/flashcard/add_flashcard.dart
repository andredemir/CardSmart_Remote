class Flashcard {
  int? id;
  String question;
  String answer;
  int folderId;

  Flashcard({this.id, required this.question, required this.answer, required this.folderId});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'question': question,
      'answer': answer,
      'folder_id': folderId,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
      folderId: map['folder_id'],
    );
  }
}
