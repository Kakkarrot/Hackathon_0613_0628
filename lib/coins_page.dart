import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/data/startingCoins.dart';
import 'package:hackathon/model/Transaction.dart';
import 'package:hackathon/widgets/coin_list_widget.dart';
import 'package:intl/intl.dart';

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
  double totalProfit = 0;
  double totalTaxes = 0;

  final String address = "";

  List<Future<Coin>> fetchCoins() {
    Map<String, DateTime> coinToEarliestDateMap = getEarliestTransactionDateMap(widget.transactions);
    List<Future<Coin>> list = [];

    for (String ticker in coinToEarliestDateMap.keys) {
      list.add(fetchCoin(ticker, coinToEarliestDateMap[ticker], DateTime.now().subtract(const Duration(days: 1))));
    }

    return list;
  }

  Map<String, DateTime> getEarliestTransactionDateMap(List<Transaction> transactions){
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

  void updateAccountValue(double value) {
    setState(() {
      totalAccountValue += value;
    });
  }

  void updateProfit(double value) {
    setState(() {
      totalProfit += value;
    });
  }

  void updateTax() {
    setState(() {
      totalProfit > 0 ? totalTaxes = totalProfit * 0.15 : totalTaxes = 0;
    });
  }

  Future<Coin> fetchCoin(String ticker, DateTime? startDate, DateTime endDate) async {
    String uri = "https://api.covalenthq.com/v1/pricing/historical/USD/" +
        ticker +
        "/?from=" +
        DateFormat('yyyy-MM-dd').format(startDate!) +
        "&to=" +
        DateFormat('yyyy-MM-dd').format(endDate!) +
        '&prices-at-asc=true&key=' +
        covalentApiNoPassword;
    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(response.body);
      updatePriceOfTransactionsForCoin(widget.transactions, ticker, decodedJson['data']['prices']);
      Map<String, List<double>> vwapCostAndPositionMapForCoin = getVwapCostAndPositionMapForCoin(widget.transactions, ticker);
      double cost = vwapCostAndPositionMapForCoin[ticker]![0];
      double coinBalance = vwapCostAndPositionMapForCoin[ticker]![1];


      Coin coin = new Coin(ticker, decodedJson['data']['logo_url'], coinBalance, cost, calculateReturnOnInvestment(cost, decodedJson['data']['prices']));
      double currentValue = coin.coinBalance * coin.vwapCost * (1 + coin.returnOnInvestment/100);
      updateAccountValue(currentValue);
      double currentProfit = currentValue - coin.coinBalance * coin.vwapCost;
      updateProfit(currentProfit);
      updateTax();
      return coin;
    } else {
      Coin coin = new Coin(ticker + ": Missing Data", "https://cryptocurrencyjobs.co/startups/assets/logos/covalent.jpg", 0, 0, 0);
      return coin;
    }
  }

  double calculateReturnOnInvestment(double cost, List<dynamic> prices){
    if (prices.isEmpty)
      return 0;
    double priceToday = prices[prices.length-1]['price'];
    return (priceToday - cost) / cost * 100;
  }
  
  void updatePriceOfTransactionsForCoin(List<Transaction> transactions, String ticker, List<dynamic> prices) {
    for (Transaction transaction in transactions) {
      if (transaction.ticker != ticker) {
        continue;
      } else {
        transaction.price = getPriceFromPrices(prices, transaction.date);
      }
    }
  }

  double getPriceFromPrices(List<dynamic> prices, DateTime date) {
    for (dynamic price in prices) {
      if (price['date'] == DateFormat('yyyy-MM-dd').format(date)) {
        return price['price'];
      }
    }
    return 0;
  }

  //call inside of fetch coin
  Map<String, List<double>> getVwapCostAndPositionMapForCoin(List<Transaction> transactions, String ticker) {
    //List = price, amount
    Map<String, List<double>> transactionVwapCostAndPosition = new Map();
    for (Transaction transaction in transactions) {
      if (transaction.ticker != ticker) {
        continue;
      }
      if (transactionVwapCostAndPosition.containsKey(transaction.ticker)) {
        //we need to do math
        if (transaction.amount < 0) {
          transactionVwapCostAndPosition[transaction.ticker]![1] += transaction.amount;
        } else {
          double oldPrice = transactionVwapCostAndPosition[transaction.ticker]![0];
          double oldAmount = transactionVwapCostAndPosition[transaction.ticker]![1];
          double oldCost = oldPrice * oldAmount;
          double transactionCost = transaction.price * transaction.amount;

          double newAmount = oldAmount + transaction.amount;
          double newCost = (oldCost + transactionCost) / newAmount;
          transactionVwapCostAndPosition[transaction.ticker] = [newCost, newAmount];
        }
      } else {
        transactionVwapCostAndPosition[transaction.ticker] = [transaction.price, transaction.amount];
      }
    }
    return transactionVwapCostAndPosition;
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
                  style: createTextStyle(15, Colors.black),
                ),
                SizedBox(height: spacingHeight/2),
                Text(
                  'Balance: \$ ' + totalAccountValue.toStringAsFixed(2),
                  style: createTextStyle(15, Colors.black),
                ),
                Text(
                  'Profit: \$ ' + totalProfit.toStringAsFixed(2),
                  style: totalProfit < 0 ? createTextStyle(15, Colors.red) : createTextStyle(15, Colors.green),
                ),
                Text(
                  'Tax: \$ ' + totalTaxes.toStringAsFixed(2),
                  style: createTextStyle(15, Colors.black),
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

  TextStyle createTextStyle(double fontSize, Color color) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      color: color,
    );
  }
}
