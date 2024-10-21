class FinancialData {
  final int id;
  double income;
  double expenses;
  String name;

  FinancialData({
    required this.id,
    required this.income,
    required this.expenses,
    required this.name,
  });


  factory FinancialData.fromJson(Map<String, dynamic> json) => FinancialData(
        id: json['id'],           
        income: json['income'],    
        expenses: json['expenses'],
        name: json['name'],
      );

  // Convert an instance to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'income': income,
        'expenses': expenses,
        'name': name,
      };
}
