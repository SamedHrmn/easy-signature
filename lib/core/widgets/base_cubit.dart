import 'package:easy_signature/core/widgets/base_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseCubit<T extends BaseState> extends Cubit<T> {
  BaseCubit(super.state);

  void updatePageLoading(bool isLoading) {
    emit(state.copyWith(baseDataHolder: state.baseDataHolder.copyWith(isPageLoading: isLoading)) as T);
  }

  void setDataLoading(String key, bool isLoading) {
    final updatedLoadings = Map<String, bool>.from(state.baseDataHolder.dataLoadings);
    updatedLoadings[key] = isLoading;
    emit(state.copyWith(baseDataHolder: state.baseDataHolder.copyWith(dataLoadings: updatedLoadings)) as T);
  }

  bool isDataLoading(String key) {
    return state.baseDataHolder.dataLoadings[key] ?? false;
  }

  void updateState(T state) {
    emit(state);
  }
}
