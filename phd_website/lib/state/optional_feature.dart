class OptionalFeature<T> {
  final T? value;
  final bool enabled;

  OptionalFeature.enabled({required this.value}) : enabled = true;

  OptionalFeature.disabled()
      : value = null,
        enabled = false;

  @override
  bool operator ==(Object other) {
    return other is OptionalFeature<T> &&
        enabled == other.enabled &&
        value == other.value;
  }

  @override
  String toString() {
    return 'OptionalFeature<$T>[value=$value,enabled=$enabled]';
  }

  @override
  int get hashCode => enabled.hashCode ^ (value?.hashCode ?? 0);
}
