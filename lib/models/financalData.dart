class FinancialData {
  final int id;
  double income;
  double expenses;
  double debt;
  String name;

  FinancialData({
    required this.id,
    required this.income,
    required this.expenses,
    required this.name,
    this.debt = 0.0,  
  });

  // Debt-to-income 
  double get debtToIncomeRatio => (income == 0) ? 0 : debt / income;

  // Savings rate = (income - expenses) / income
  double get savingsRate => (income == 0) ? 0 : (income - expenses) / income;


  factory FinancialData.fromJson(Map<String, dynamic> json) => FinancialData(
        id: json['id'],           
        income: json['income'],    
        expenses: json['expenses'],
        name: json['name'],
        debt: json['debt'] ?? 0.0,  // Optional 
      );

  
  Map<String, dynamic> toJson() => {
        'id': id,
        'income': income,
        'expenses': expenses,
        'name': name,
        'debt': debt,
      };
}
