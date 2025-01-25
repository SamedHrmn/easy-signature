import 'package:easy_signature/core/widgets/base_data_holder.dart';
import 'package:equatable/equatable.dart';

abstract class BaseState extends Equatable {
  const BaseState({
    required this.baseDataHolder,
  });
  final BaseDataHolder baseDataHolder;

  @override
  List<Object?> get props => [baseDataHolder];

  BaseState copyWith({
    BaseDataHolder? baseDataHolder,
  });
}
