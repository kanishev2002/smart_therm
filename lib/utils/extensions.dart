extension Separation<T> on List<T> {
  List<T> separatedBy(T divider) {
    if (isEmpty) {
      return [];
    }

    final result = <T>[first];
    for (final item in skip(1)) {
      result
        ..add(divider)
        ..add(item);
    }
    return result;
  }
}
