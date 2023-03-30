import 'dart:convert';

class JsonParser {
  late int a;
  late int b;

  JsonParser(String jsonString) {
    try {
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      this.a = jsonMap['a'];
      this.b = jsonMap['b'];
    } catch (e) {
      throw FormatException('Failed to parse JSON: $e');
    }
  }
}

// void main() {
//   String jsonString = '{"a": 654, "b":0}';
//   JsonParser parser = JsonParser(jsonString);

//   print('a = ${parser.a}');
//   print('b = ${parser.b}');
// }
