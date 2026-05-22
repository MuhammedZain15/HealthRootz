/// Common async UI flags for feature state models (MVVM presentation layer).
mixin AsyncState {
  bool get isLoading;
  String? get errorMessage;
  String? get successMessage;
}
