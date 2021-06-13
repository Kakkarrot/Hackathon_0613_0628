import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/data/startingCoins.dart';
import 'package:hackathon/widgets/coin_list_widget.dart';

import 'model/Coin.dart';

class CoinsPage extends StatefulWidget {
  CoinsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _CoinsPageState createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  final List<Coin> coins = List.from(initialCoins);
  final String address = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height / 3),
        child: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Center(
            heightFactor: 100,
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: AnimatedList(
        initialItemCount: coins.length,
        itemBuilder:
            (BuildContext context, int index, Animation<double> animation) =>
                CoinListWidget(
                    coin: coins[index],
                    onClicked: () {}),
      ),
    );
  }
}
