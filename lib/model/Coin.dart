import 'dart:core';

import 'package:flutter/foundation.dart';

class Coin {
  final String name;
  final String urlImage;
  final double coinTradingValue;
  final double coinBalance;
  final double returnOnInvestment;
  late final double coinBalanceInDollars;

  Coin(this.name, this.urlImage, this.coinTradingValue, this.coinBalance, this.returnOnInvestment){
    coinBalanceInDollars = coinBalance*coinTradingValue;
  }

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      json['data']['items'][0]['contract_ticker_symbol'],
      json['data']['items'][0]['logo_url'],
      json['data']['items'][0]['quote_rate'],
      1.00,
      0.21523,
    );
  }
}
