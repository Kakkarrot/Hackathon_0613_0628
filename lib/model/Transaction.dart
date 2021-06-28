class Transaction {
  late final String ticker;
  late final double amount;
  late final DateTime date;
  late double price;

  Transaction(String ticker, double amount, DateTime date) {
    this.ticker = ticker;
    this.amount = amount;
    this.date = date;
  }
}
