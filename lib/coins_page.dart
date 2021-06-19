import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/data/startingCoins.dart';
import 'package:hackathon/widgets/coin_list_widget.dart';

import 'apiKeys/covalent.dart';
import 'model/Coin.dart';
import 'package:http/http.dart' as http;

class CoinsPage extends StatefulWidget {
  CoinsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _CoinsPageState createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  final List<Coin> coins = List.from(initialCoins);
  late List<Future<Coin>> futureCoins;
  double totalAccountValue = 0;

  final String address = "";

  List<Future<Coin>> fetchCoins() {
    List<Future<Coin>> list = [];
    // for (int i = 0; i < 10; i++) {
    //   list.add(fetchCoin());
    // }
    list.add(fetchCoin('btc'));
    list.add(fetchCoin('eth'));
    list.add(fetchCoin('bnb'));
    list.add(fetchCoin('btc'));
    list.add(fetchCoin('eth'));
    list.add(fetchCoin('bnb'));
    list.add(fetchCoin('btc'));
    list.add(fetchCoin('eth'));
    list.add(fetchCoin('bnb'));

    return list;
  }

  void increaseAccountValue(double value) {
    setState(() {
      totalAccountValue += value;
    });
  }

  Future<Coin> fetchCoin(String coinTicker) async {
    final response = await http.get(Uri.parse('https://api.covalenthq.com' +
        '/v1/pricing/tickers/' +
        '?tickers=' +
        coinTicker +
        '&key=' +
        covalentApiNoPassword));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var coin = Coin.fromJson(jsonDecode(response.body));
      increaseAccountValue(coin.coinBalanceInDollars);
      return coin;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load coin');
    }
  }

  @override
  void initState() {
    super.initState();
    futureCoins = fetchCoins();
  }

  @override
  Widget build(BuildContext context) {
    var spacingHeight = MediaQuery.of(context).size.height / 20;
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(""),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: Column(
              children: [
                SizedBox(height: spacingHeight),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: createTextStyle(),
                ),
                SizedBox(height: spacingHeight),
                Text(
                  '\$' + '$totalAccountValue',
                  style: createTextStyle(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: futureCoins.length,
              itemBuilder: (
                BuildContext context,
                int index,
              ) =>
                  CoinListWidget(
                      coinFuture: futureCoins[index],
                      onClicked: () {}),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle createTextStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
  }
}
