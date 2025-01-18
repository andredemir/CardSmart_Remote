import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import '../flashcard/flashcard_model.dart';

class LearningModelHandwriting extends StatefulWidget {
  final List<Flashcard> flashcards;

  const LearningModelHandwriting({super.key, required this.flashcards});

  @override
  _LearningModelHandwritingState createState() => _LearningModelHandwritingState();
}

class _LearningModelHandwritingState extends State<LearningModelHandwriting> {
  int _currentFlashcardIndex = 0;
  String _recognizedText = "";
  String _feedbackMessage = "";
  final List<Offset> _points = [];
  File? _capturedImage;

  Future<void> _recognizeText() async {
    try {
      // Capture the drawing as an image
      final boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 5.0);  // Further increase resolution
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        print("ByteData is null");
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();

      // Save the image to a unique file
      final directory = await getTemporaryDirectory();
      final imgFile = File('${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png');
      await imgFile.writeAsBytes(pngBytes);
      print("Image saved to ${imgFile.path}");

      // Display the image to ensure it's correctly captured
      setState(() {
        _capturedImage = imgFile;
      });

      // Manual check
      print("Please manually check the saved image at: ${imgFile.path}");

      // Perform text recognition on the saved image
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFile(_capturedImage!);
      final RecognizedText recognisedText = await textRecognizer.processImage(inputImage);
      String text = recognisedText.text;

      setState(() {
        _recognizedText = text.toString();
      });

      print("Recognized text: $_recognizedText"); // Debugging output

      _checkAnswer();
      textRecognizer.close();
    } catch (e) {
      print("Error recognizing text: $e");
    }
  }

  void _checkAnswer() {
    String correctAnswer = widget.flashcards[_currentFlashcardIndex].answer.trim().toLowerCase();
    String userAnswer = _recognizedText.toLowerCase();

    setState(() {
      if (userAnswer == correctAnswer) {
        _feedbackMessage = "Correct!";
      } else {
        _feedbackMessage = "Incorrect. Try again.";
      }
      print("Correct answer: $correctAnswer, User answer: $userAnswer"); // Debugging output
    });
  }

  void _nextFlashcard() {
    setState(() {
      _currentFlashcardIndex = (_currentFlashcardIndex + 1) % widget.flashcards.length;
      _recognizedText = "";
      _points.clear();
      _feedbackMessage = "";
      _capturedImage = null; // Reset the captured image
    });
  }

  void _clearDrawing() {
    setState(() {
      _points.clear();
    });
  }

  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Handwriting Learning Model')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                widget.flashcards.isNotEmpty
                    ? widget.flashcards[_currentFlashcardIndex].question
                    : 'No flashcards available',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              Container(
                color: Colors.grey[200],
                child: RepaintBoundary(
                  key: _globalKey,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _points.add(details.localPosition);
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _points.add(Offset.zero);
                      });
                    },
                    child: CustomPaint(
                      size: const Size(double.infinity, 300),
                      painter: _HandwritingPainter(_points),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _recognizeText,
                    child: const Text('Recognize Handwriting'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _clearDrawing,
                    child: const Text('Clear Drawing'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_capturedImage != null) Image.file(_capturedImage!),
              const SizedBox(height: 20),
              Text('Recognized Text: $_recognizedText', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              Text(_feedbackMessage, style: const TextStyle(fontSize: 18, color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _nextFlashcard,
                child: const Text('Next Flashcard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HandwritingPainter extends CustomPainter {
  final List<Offset> points;

  _HandwritingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}
