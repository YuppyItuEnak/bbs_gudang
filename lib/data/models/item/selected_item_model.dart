import 'package:bbs_gudang/data/models/item/item_model.dart';

class SelectedItem {
  final ItemModel item;
  int quantity;

  SelectedItem({required this.item, this.quantity = 1});
}
