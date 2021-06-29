import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/data/startingCoins.dart';
import 'package:hackathon/model/Transaction.dart';
import 'package:hackathon/widgets/coin_list_widget.dart';

import 'apiKeys/covalent.dart';
import 'model/Coin.dart';
import 'package:http/http.dart' as http;

class CoinsPage extends StatefulWidget {
  CoinsPage({Key? key, required this.title, required this.transactions}) : super(key: key);

  final String title;
  late List<Transaction> transactions;

  @override
  _CoinsPageState createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  final List<Coin> coins = List.from(initialCoins);
  late List<Future<Coin>> futureCoins;
  double totalAccountValue = 0;

  final String address = "";

  List<Future<Coin>> fetchCoins() {
    print(widget.transactions.length);
    Map<String, DateTime> coinToEarliestDateMap = updateEarliestTransactionDateMap(widget.transactions);
    List<Future<Coin>> list = [];

    for (String ticker in coinToEarliestDateMap.keys) {
      // list.add(fetchCoin(ticker, coinToEarliestDateMap![ticker], DateTime.now()));
      list.add(fetchCoin(ticker));
    }


    // list.add(fetchCoin('wftm'));

    // list.add(fetchCoin('ftm'));
    // list.add(fetchCoin('bnb'));
    // list.add(fetchCoin('btc'));
    // list.add(fetchCoin('eth'));
    // list.add(fetchCoin('bnb'));
    // list.add(fetchCoin('btc'));
    // list.add(fetchCoin('eth'));
    // list.add(fetchCoin('bnb'));

    return list;
  }

  Map<String, DateTime> updateEarliestTransactionDateMap(List<Transaction> transactions){
    Map<String, DateTime> earliestTransactionDate = new Map();
    for (Transaction transaction in transactions) {
      if (!earliestTransactionDate.containsKey(transaction.ticker)) {
        earliestTransactionDate[transaction.ticker] = transaction.date;
      } else {
        if (earliestTransactionDate[transaction.ticker]!.isAfter(transaction.date)) {
          earliestTransactionDate[transaction.ticker] = transaction.date;
        }
      }
    }
    return earliestTransactionDate;
  }

  void increaseAccountValue(double value) {
    setState(() {
      totalAccountValue += value;
    });
  }

  Future<Coin> fetchCoin(String ticker) async {
    //change this to do the call for prices within a range
    //we only take the first and last price
    // String uri = "https://api.covalenthq.com/v1/pricing/historical/USD/" +
    //     ticker +
    //     "/?from=" +
    //     startDate +
    //     "&to=" +
    //     endDate +
    //     '&key=' +
    //     covalentApiNoPassword;
    // final response = await http.get(Uri.parse(uri));

    final response = await http.get(Uri.parse('https://api.covalenthq.com' +
        '/v1/pricing/tickers/' +
        '?tickers=' +
        ticker +
        '&key=' +
        covalentApiNoPassword));
    if (response.statusCode == 200) {
      //we can do the vwap calculation

      //redefine the fromJson to use the new values
      var coin = Coin.fromJson(jsonDecode(response.body));
      increaseAccountValue(coin.coinBalanceInDollars);
      return coin;
    } else {
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
            height: MediaQuery.of(context).size.height / 5,
            child: Column(
              children: [
                SizedBox(height: spacingHeight),
                Text(
                  hideAddress(widget.title),
                  textAlign: TextAlign.center,
                  style: createTextStyle(15),
                ),
                Text(
                  '\$' + '$totalAccountValue',
                  style: createTextStyle(20),
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

  String hideAddress(String address) {
    String result = "";
    for (int i = 0; i < 3; i++) {
      result += address[i];
    }
    result += '...';
    for (int i = address.length - 3; i < address.length; i++) {
      result += address[i];
    }
    return result;
  }

  TextStyle createTextStyle(double fontSize) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
    );
  }
}
