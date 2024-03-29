import 'package:elec_mart_customer/components/horizontal_list_item.dart';
import 'package:elec_mart_customer/constants/Colors.dart';
import 'package:flutter/material.dart';

class HorizontalNewItem extends StatelessWidget {
  final String name, currentPrice, mrpPrice;
  final bool outOfStock;
  final String id;
  final List imageURL;

  HorizontalNewItem({
    this.id,
    this.outOfStock = false,
    this.imageURL,
    this.name,
    this.currentPrice,
    this.mrpPrice,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 10),
          child: HorizontalListItem(
            outOfStock: outOfStock,
            id: id,
            imageURL: imageURL,
            name: name,
            currentPrice: currentPrice,
            mrpPrice: mrpPrice,
            showBorder: true,
          ),
        ),
        newLabel()
      ],
    );
  }

  Positioned newLabel() {
    return Positioned(
      right: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: outOfStock ? RED_COLOR : PRIMARY_COLOR,
        ),
        child: Text(
          "NEW",
          style: TextStyle(
              color: WHITE_COLOR, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
