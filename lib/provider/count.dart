import 'package:flutter_riverpod/flutter_riverpod.dart';

class Counter extends StateNotifier<int> {
  Counter(this.ref) : super(0);

  final Ref ref;

  void increment() {
    // Counter can use the "ref" to read other providers
    state++;
  }

  void decrement() {
    // Counter can use the "ref" to read other providers
    state--;
  }
}

final countProvider = StateNotifierProvider<Counter, int>((ref) {
  return Counter(ref);
});
