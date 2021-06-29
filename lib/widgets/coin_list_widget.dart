import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/apiKeys/covalent.dart';
import 'package:hackathon/model/Coin.dart';

class CoinListWidget extends StatelessWidget {
  final Future<Coin> coinFuture;
  final VoidCallback? onClicked;

  const CoinListWidget({
    required this.coinFuture,
    required this.onClicked,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => buildCoin();

  Widget buildCoin() => CoinTile(coin: coinFuture);
}

class CoinTile extends StatelessWidget {
  const CoinTile({
    Key? key,
    required this.coin,
  }) : super(key: key);

  final Future<Coin> coin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: FutureBuilder<Coin>(
        future: coin,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return buildListTileFromFuture(snapshot.data!);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  ListTile buildListTileFromFuture(Coin coin) {
    return ListTile(
      contentPadding: EdgeInsets.all(16),
      leading: getCoinImage(coin),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getCoinName(coin),
          Text(
            coin.coinBalance.toStringAsFixed(4),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ROI: ' + coin.returnOnInvestment.toStringAsFixed(2) + '%',
          ),
          Text(
            'Cost Each: \$' + coin.vwapCost.toStringAsFixed(2),
          ),
        ],
      ),
    );
  }

  CircleAvatar getCoinImage(Coin coin) {
    return CircleAvatar(
      radius: 32,
      backgroundImage: NetworkImage(coin.urlImage),
    );
  }

  Text getCoinName(Coin coin) {
    return Text(
      coin.name,
    );
  }
}
