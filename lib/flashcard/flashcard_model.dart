import 'package:uuid/uuid.dart';

class Flashcard {
  String id;
  String question;
  String answer;

  Flashcard({required this.id, required this.question, required this.answer});

  factory Flashcard.fromMap(Map<String, dynamic> data, String id) {
    return Flashcard(
      id: id,
      question: data['question'] as String? ?? '',
      answer: data['answer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }
}

// Helper function to generate unique IDs
String generateUniqueId() {
  var uuid = const Uuid();
  return uuid.v4();
}