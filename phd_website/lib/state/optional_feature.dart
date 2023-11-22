class OptionalFeature<T> {
  final T? value;
  final bool enabled;

  OptionalFeature.enabled({required this.value}) : enabled = true;

  OptionalFeature.disabled()
      : value = null,
        enabled = false;
}
