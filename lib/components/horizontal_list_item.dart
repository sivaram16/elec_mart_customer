import 'package:elec_mart_customer/constants/Colors.dart';
import 'package:flutter/material.dart';

class HorizontalListItem extends StatelessWidget {
  final String name, currentPrice, mrpPrice;
  final bool showBorder;

  HorizontalListItem(
      {this.name, this.currentPrice, this.mrpPrice, this.showBorder = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        border: showBorder ? Border.all(width: 2, color: PRIMARY_COLOR) : null,
        color: GREY_COLOR,
      ),
      child: Row(
        children: <Widget>[
          Image.asset("assets/images/Rectangle.png"),
          Container(margin: EdgeInsets.only(left: 10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 20),
                width: 220,
                child: Text(
                  "$name",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              priceWidget(mrpPrice, context),
              priceWidget(currentPrice, context, currentPrice: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget priceWidget(String price, context, {bool currentPrice = false}) {
    return Container(
      width: MediaQuery.of(context).size.width - 185,
      child: Text(
        "$price",
        textAlign: TextAlign.right,
        style: TextStyle(
            fontSize: currentPrice ? 16 : 12,
            color: currentPrice ? PRIMARY_COLOR : RED_COLOR,
            fontWeight: FontWeight.bold,
            decoration: !currentPrice ? TextDecoration.lineThrough : null),
      ),
    );
  }
}