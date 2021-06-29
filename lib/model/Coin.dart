import 'dart:core';

import 'package:flutter/foundation.dart';

class Coin {
  final String name;
  final String urlImage;
  final double coinBalance;
  final double returnOnInvestment;
  late final double vwapCost;

  Coin(this.name, this.urlImage, this.coinBalance, this.vwapCost, this.returnOnInvestment);

  factory Coin.fromJson(Map<String, dynamic> json) {
    //handle the empty arrays also

    return Coin(
      json['data']['items'][0]['contract_ticker_symbol'],
      json['data']['items'][0]['logo_url'],
      json['data']['items'][0]['quote_rate'],
      1.00,
      0.21523,
    );
  }
}
