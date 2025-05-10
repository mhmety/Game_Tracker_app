import 'package:flutter_test/flutter_test.dart';
import 'counter.dart'; // Counter sınıfı burada import edilmeli

void main() {
  test('Counter value should be 0', () {
    final counter = Counter();
    expect(counter.value, 0);
  });

  test('Counter should increment', () {
    final counter = Counter();
    counter.increment();
    expect(counter.value, 1);
  });

  test('Counter should decrement', () {
    final counter = Counter();
    counter.increment();
    counter.decrement();
    expect(counter.value, 0);
  });
}
