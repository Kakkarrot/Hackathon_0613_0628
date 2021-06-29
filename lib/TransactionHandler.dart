import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hackathon/model/Transaction.dart';

import 'apiKeys/covalent.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TransactionHandler {
  late final String address;
  static const num SCALING_FACTOR = 1.0e+18;
  Map<String, dynamic> wallet = new Map();

  TransactionHandler(String address) {
    this.address = address;
  }

  Future<http.Response> getTransactionLogsInChronologicalOrder() async {
    return await http.get(Uri.parse('https://api.covalenthq.com' +
        '/v1/250/address/' +
        address +
        '/transactions_v2/?block-signed-at-asc=true&quote-currency=USD&key=' +
        covalentApiNoPassword)
    );
  }

  void processTransactions(http.Response response) {
    Map<String, dynamic> transactions = jsonDecode(response.body);
    processSwaps(transactions['data']['items']);
    processFantomTransactions(transactions);
  }

  void processFantomTransactions(Map<String, dynamic> transactions){
    List<Transaction> allTransactions = [];

    for (int i = 0; i < transactions['data']['items'].length; i++) {
      //deposits
      if ((transactions['data']['items'][i]['from_address'] != this.address)
          && (transactions['data']['items'][i]['log_events'].length == 0)){
        allTransactions.add(
            Transaction(
                "FTM",
                double.parse(transactions['data']['items'][i]['value']) / SCALING_FACTOR,
                DateTime.parse(transactions['data']['items'][i]['block_signed_at'])
            ));
      }
      //withdrawal
      else if ((transactions['data']['items'][i]['from_address'] == this.address)
          && (transactions['data']['items'][i]['log_events'].length == 0)) {
        allTransactions.add(
            Transaction(
                "FTM",
                -1 * double.parse(transactions['data']['items'][i]['value']) / SCALING_FACTOR,
                DateTime.parse(transactions['data']['items'][i]['block_signed_at'])
            ));
      }
    }
  }

  void processSwaps(List<dynamic> transactions) {
    List<Transaction> allTransactions = [];
    for (dynamic transaction in transactions) {
      List<dynamic> logs = transaction['log_events'];
      if (logs.length >
          1 /*&& logs[logs.length-1]['decoded']['name'] == 'Swap'*/) {
        List<Transaction> processedLogs = processEventLogs(logs);
        allTransactions.addAll(processedLogs);
      }
    }
    updateWallet(allTransactions);
  }

  void updateWallet(List<Transaction> allTransactions) async {
    for (Transaction transaction in allTransactions) {
      final response = await getCoinPriceAtDate(transaction.ticker, transaction.date);

    }
  }

  Future<double> getCoinPriceAtDate(String ticker, DateTime date) async {
    var formattedDate = DateFormat('yyyy-MM-dd').format(date);
    var uri = "https://api.covalenthq.com/v1/pricing/historical/USD/" +
            ticker +
            "/?from=" +
            formattedDate +
            "&to=" +
            formattedDate +
            '&key=' +
            covalentApiNoPassword;
    var response = await http.get(Uri.parse(
        uri));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['data']['prices'].length > 0) {
        return jsonDecode(response.body)['data']['prices'][0]['price'];
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  List<Transaction> processEventLogs(List<dynamic> logs) {
    List<Transaction> decodedTransactions = [];
    for (dynamic log in logs) {
      if (log['decoded']['name'] == 'Transfer') {
        double amount = getTransferAmount(log);
        if (amount != 0) {
          DateTime date = DateTime.parse(log['block_signed_at']);
          String token = log['sender_contract_ticker_symbol'];
          if (token.compareTo('WFTM') == 0) {
            token = "FTM";
          }
          Transaction transaction = new Transaction(token, amount, date);
          decodedTransactions.add(transaction);
        }
      }
    }
    return decodedTransactions;
  }

  double getTransferAmount(dynamic transfer) {
    String fromAddress = transfer['decoded']['params'][0]['value'];
    String toAddress = transfer['decoded']['params'][1]['value'];
    if (fromAddress.compareTo('0x0000000000000000000000000000000000000000') ==
        0) {
      return (-1) * double.parse(transfer['decoded']['params'][2]['value']);
    } else if (fromAddress.compareTo(address.toLowerCase()) == 0) {
      return (-1) * double.parse(transfer['decoded']['params'][2]['value']);
    } else if (toAddress
            .compareTo('0x0000000000000000000000000000000000000000') ==
        0) {
      return double.parse(transfer['decoded']['params'][2]['value']);
    } else if (toAddress.compareTo(address.toLowerCase()) == 0) {
      return double.parse(transfer['decoded']['params'][2]['value']);
    } else {
      return 0.0;
    }
  }
}
