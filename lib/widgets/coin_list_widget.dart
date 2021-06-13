import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/model/Coin.dart';

class CoinListWidget extends StatelessWidget {
  final Coin coin;
  final Animation<double> animation;
  final VoidCallback? onClicked;

  const CoinListWidget({
    required this.coin,
    required this.animation,
    required this.onClicked,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => buildCoin();

  Widget buildCoin() => CoinTile(coin: coin);
}

class CoinTile extends StatelessWidget {
  const CoinTile({
    Key? key,
    required this.coin,
  }) : super(key: key);

  final Coin coin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 32,
          backgroundImage: NetworkImage(coin.urlImage),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              coin.name,
            ),
            Text(
              coin.coinBalance.toString(),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              coin.returnOnInvestment.toString(),
            ),
            Text(
              coin.coinBalanceInDollars.toString(),
            ),
          ],
        ),
      ),
    );
  }
}
