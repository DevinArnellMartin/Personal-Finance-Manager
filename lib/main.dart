import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'helper.dart';
import 'package:fl_chart/fl_chart.dart';

String custom_title = "";

void main() {
  runApp(const FinanceApp());
}

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});  

  @override
  _FinanceAppState createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  late Future<void> _dbInitFuture;
  final DatabaseHelper database = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _dbInitFuture = database.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dbInitFuture,  
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/verbose': (context) => const DataEntryScreen(),
              '/visuals': (context) => const GraphScreen(),
            },
          );
        } else if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error initializing database')),
            ),
          );
        } else {
        
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Finance Manager'),
      ),
      body: const Center(
        child: Text('Here is the tutorial how to use it '), //Embellish
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

// Navigation 
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.input),
          label: 'Enter Your Information',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'At a Glance...',
        ),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/verbose');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/visuals');
        }
      },
    );
  }
}

// Data Entry Screen
class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({super.key});

  @override
  _DataEntryScreenState createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final TextEditingController incControl = TextEditingController();
  final TextEditingController expControl = TextEditingController();
  final TextEditingController debtControl = TextEditingController();
  final TextEditingController savingsControl = TextEditingController();
  final TextEditingController nameControl = TextEditingController();

  @override
  void dispose() {
    incControl.dispose();
    expControl.dispose();
    savingsControl.dispose();
    debtControl.dispose();
    nameControl.dispose();
    super.dispose();
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    int income = int.parse(incControl.text);
    int expense = int.parse(expControl.text);
    int savingsGoal = int.parse(savingsControl.text);
    String name = nameControl.text; 
    double debt = double.parse(debtControl.text); 

    
    double incomeSpendingRatio = income / expense;
    await prefs.setString('name', name);
    await prefs.setInt('income', income);
    await prefs.setInt('expense', expense);
    await prefs.setInt('savingsGoal', savingsGoal);
    await prefs.setDouble('income-spending ratio', incomeSpendingRatio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Financial Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: incControl,
              decoration: const InputDecoration(labelText: 'Income'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: incControl,
              decoration: const InputDecoration(labelText: 'Income'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: expControl,
              decoration: const InputDecoration(labelText: 'Expenses'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: savingsControl,
              decoration: const InputDecoration(labelText: 'Savings Goal'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: debtControl,
              decoration: const InputDecoration(labelText: 'Debt'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveData();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// Graph Screen and Form
class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  double progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Graph and Progress')),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text("Custom Graph"),
            ),
          ),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                progress += 0.1;
                if (progress > 1) progress = 1;
              });
            },
            child: const Text('Update Progress'),
          ),
        ],
      ),
    );
  }
}

class FiPie extends StatefulWidget {
  @override
  _FiPieState createState() => _FiPieState();
}

class _FiPieState extends State<FiPie> {
  final DatabaseHelper database = DatabaseHelper();
  double income = 0.0;
  double expenses = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async { //diff on unpublished helper.dart
    final double fetchedIncome = await database.getIncomeByName();
    final double fetchedExpenses = await database.getExpensesByName();

    setState(() {
      income = fetchedIncome;
      expenses = fetchedExpenses;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Income Vs Expense")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: income,
                    color: Colors.green,
                    title: "Income",
                  ),
                  PieChartSectionData(
                    value: expenses,
                    color: Colors.red,
                    title: "Expenses",
                  ),
                ],
              ),
            ),
    );
  }
}


//TODO : Still implement the custom graph functionality: Comment out for extra debugging

class ParentWidget extends StatefulWidget {
  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  double xValue = 0;
  double yValue = 0;

  void updateGraphValues(double x, double y) {
    setState(() {
      xValue = x;
      yValue = y;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CGForm(onUpdate: updateGraphValues), 
        CustFiPie(xValue: xValue, yValue: yValue), 
      ],
    );
  }
}

class CustFiPie extends StatelessWidget {
  final double xValue;
  final double yValue;

  const CustFiPie({required this.xValue, required this.yValue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PieChart(
        PieChartData(
          centerSpaceColor: Colors.green,
          sections: [
            PieChartSectionData(
              value: xValue,
              color: Colors.blue,
              title: "X Axis",
            ),
            PieChartSectionData(
              value: yValue,
              color: Colors.orange,
              title: "Y Axis",
            ),
          ],
        ),
      ),
    );
  }
}

class CGForm extends StatefulWidget {
  final Function(double, double) onUpdate;

  const CGForm({required this.onUpdate});

  @override
  GraphFormState createState() => GraphFormState();
}

class GraphFormState extends State<CGForm> {
  String _x = '';
  String _y = '';
  final DatabaseHelper helper = DatabaseHelper();
  List<String> x_records = [];
  List<String> y_records = []; //not actual records: the column names

  void updateField(String field, String value) {
    setState(() {
      if (field == 'X') {
        _x = value;
      } else {
        _y = value;
      }
    });
    widget.onUpdate(double.tryParse(_x) ?? 0, double.tryParse(_y) ?? 0); 
  }

  @override
  void initState() {
    super.initState();
    loadColumns();
  }

  Future<void> loadColumns() async {
    final List<String> columns = await helper.getColumnNames();

    setState(() {
      x_records = columns;
      y_records = columns;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField(
          value: _x.isEmpty ? null : _x,
          items: x_records
              .map((col) => DropdownMenuItem(value: col, child: Text(col)))
              .toList(),
          onChanged: (value) => updateField('X', value!),
        ),
        DropdownButtonFormField(
          value: _y.isEmpty ? null : _y,
          items: y_records
              .map((col) => DropdownMenuItem(value: col, child: Text(col)))
              .toList(),
          onChanged: (value) => updateField('Y', value!),
        ),
      ],
    );
  }
}

// class CustomFiPie extends StatefulWidget {

//   @override
//   CustFiPieState createState() => CustFiPieState();


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(custom_title)),
//       body: PieChart(
//         PieChartData(
//           centerSpaceColor: Colors.green,
//           sections: [
//             PieChartSectionData(
//               value: 0 ,
//               color: Colors.blue,
//               title: _x,
//             ),
//             PieChartSectionData(
//               value: 0 ,
//               color: Colors.orange,
//               title: _y,
//             ),
//           ],
          
//         ),
//       ),
//     );
//   }
// }

// class CustomPieState extends State<CustFiPieState> {
//   final DatabaseHelper database = DatabaseHelper();
//   double income = 0.0;
//   double expenses = 0.0;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadFormData();
//   }

//   Future<void> _loadFormData() async {
//     final double x = await GraphFormState;
//     final double y = await GraphFormState;

//     setState(() {
//       x_ax = x;
//       y_ax = y;
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text(custom_title)),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : PieChart(
//               PieChartData(
//                 sections: [
//                   PieChartSectionData(
//                     value: income,
//                     color: Colors.green,
//                     title: _x,
//                   ),
//                   PieChartSectionData(
//                     value: expenses,
//                     color: Colors.red,
//                     title: "_y",
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// class CGForm extends StatefulWidget {
//   const CGForm({super.key});

//   @override
//   GraphFormState createState() => GraphFormState();
// }

// class GraphFormState extends State<CGForm> {
//   final DatabaseHelper helper = DatabaseHelper();
//   List<String> columns = [];

//   @override
//   void initState() {
//     super.initState();
//     loadColumns();
//   }

//   Future<void> loadColumns() async {
//     final columnNames = await helper.getColumnNames();
//     setState(() {
//       columns = columnNames;
//     });
//   }

//   void updateField(String field, String value) {
//     setState(() {
//       if (field == 'X') {
//         _x = value;
//       } else {
//         _y = value;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         DropdownButtonFormField(
//           value: _x.isEmpty ? null : _x,
//           items: columns.map((col) => DropdownMenuItem(value: col, child: Text(col))).toList(),
//           onChanged: (value) => updateField('X', value!),
//           decoration: const InputDecoration(labelText: 'X-Axis Variable'),
//         ),
//         DropdownButtonFormField(
//           value: _y.isEmpty ? null : _y,
//           items: columns.map((col) => DropdownMenuItem(value: col, child: Text(col))).toList(),
//           onChanged: (value) => updateField('Y', value!),
//           decoration: const InputDecoration(labelText: 'Y-Axis Variable'),
//         ),
//       ],
//     );
//   }
// }

// class CGForm extends StatefulWidget { 
//   @override 
//   GraphFormState createState() => GraphFormState(); 
// } 
  
// class GraphFormState extends State<CGForm> { 
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); 

//   void _submitForm() { 
    
//     if (_formKey.currentState!.validate()) { 
//       _formKey.currentState!.save(); 
//       print('X-Axis: $_x'); 
//       print('Y-Axis: $_y');  
//       custom_title = String.join(_y ,"vs" , _x);
//     } 
//   } 
  
//   @override 
//   Widget build(BuildContext context) { 
//     return Scaffold( 
//       appBar: AppBar( 
//         title: Text('Generate Graph'), 
//       ), 
//       body: Form( 
//         key: _formKey, 
//         child: Padding( 
//           padding: EdgeInsets.all(16.0), 
//           child: Column( 
//             children: <Widget>[ 
//               TextFormField( 
//                 decoration: InputDecoration(labelText: 'Independent Variable'), 
//                 validator: (value) { 
//                   if (value!.isEmpty) { 
//                     return 'Please enter an X.'; 
//                   } 
//                   else if (value not in database.getColumnNames ){
//                     return "Must be one of the follwing $database.getColumnNames"
//                   }
//                   return null; 
//                 }, 
//                 onSaved: (value) { 
//                   _x = value!; // Save the entered name 
//                 }, 
//               ), 
//               TextFormField( 
//                 decoration: InputDecoration(labelText: 'Dependent Variable'),  
//                 validator: (value) { 
//                   if (value!.isEmpty) { 
//                     return 'Please enter a Y.'; 
//                   } 
//                   else if ( value not in database.getColumnNames ){
//                     return "Must be one of the follwing $database.getColumnNames"
//                   }
//                   return null; // Return null if the email is valid 
//                 }, 
//                 onSaved: (value) { 
//                   _y = value!;
//                 }, 
//               ), 
//               SizedBox(height: 20.0), 
//               ElevatedButton( 
//                 onPressed: _submitForm, 
//                 child: Text('Generate'), 
//               ), 
//             ], 
//           ), 
//         ), 
//       ), 
//     ); 
//   } 
// } 