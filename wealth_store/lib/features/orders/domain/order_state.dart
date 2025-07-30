import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wealth_app/shared/models/order.dart';

part 'order_state.freezed.dart';
part 'order_state.g.dart';

@freezed
class OrderState with _$OrderState {
  const factory OrderState({
    @Default([]) List<Order> orders,
    @Default(false) bool isLoading,
    String? error,
    Order? selectedOrder,
  }) = _OrderState;

  const OrderState._();

  factory OrderState.initial() => const OrderState();

  factory OrderState.loading() => const OrderState(isLoading: true);

  factory OrderState.error(String message) => OrderState(error: message);

  factory OrderState.loaded(List<Order> orders) => OrderState(orders: orders);

  factory OrderState.fromJson(Map<String, dynamic> json) => _$OrderStateFromJson(json);
}