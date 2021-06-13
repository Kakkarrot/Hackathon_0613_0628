import 'dart:core';

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
}
