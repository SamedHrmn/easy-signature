class BaseDataHolder {
  const BaseDataHolder({
    this.isPageLoading = false,
    this.dataLoadings = const {},
    this.error,
  });
  final bool isPageLoading;
  final Map<String, bool> dataLoadings;
  final String? error;

  BaseDataHolder copyWith({
    bool? isPageLoading,
    Map<String, bool>? dataLoadings,
    String? error,
  }) {
    return BaseDataHolder(
      isPageLoading: isPageLoading ?? this.isPageLoading,
      dataLoadings: dataLoadings ?? this.dataLoadings,
      error: error ?? this.error,
    );
  }
}
