import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/data/startingCoins.dart';
import 'package:hackathon/widgets/coin_list_widget.dart';

import 'model/Coin.dart';

class CoinsPage extends StatefulWidget {
  CoinsPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _CoinsPageState createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  final List<Coin> coins = List.from(initialCoins);

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
                    animation: animation,
                    onClicked: () {}),
      ),
    );
  }
}