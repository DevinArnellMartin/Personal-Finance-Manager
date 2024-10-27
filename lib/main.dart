import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FinanceApp());
}

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  _FinanceAppState createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      routes: {
        '/dataEntry': (context) => const DataEntryScreen(),
        '/graph': (context) => const GraphScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Finance Manager')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to the Personal Finance Manager!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tutorial: Go into the Enter Finance data page to enter your Income, Expenses, Savings Goal, name, and debt',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/dataEntry');
              },
              child: const Text('Enter Financial Data'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/graph');
              },
              child: const Text('View Graph'),
            ),
          ],
        ),
      ),
    );
  }
}

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({super.key});

  @override
  _DataEntryScreenState createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController expenseController = TextEditingController();
  final TextEditingController savingsController = TextEditingController();
  final TextEditingController debtController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  XFile? profileImage;
  List<Map<String, dynamic>> savedEntries = [];

  @override
  void dispose() {
    incomeController.dispose();
    expenseController.dispose();
    savingsController.dispose();
    debtController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> saveData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> newEntry = {
      'name': nameController.text,
      'income': int.tryParse(incomeController.text) ?? 0,
      'expense': int.tryParse(expenseController.text) ?? 0,
      'savings': int.tryParse(savingsController.text) ?? 0,
      'debt': double.tryParse(debtController.text) ?? 0.0,
    };
    
 setState(() {
      savedEntries.add(newEntry);
    });

  }


  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      profileImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Financial Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImage != null
                      ? FileImage(File(profileImage!.path))
                      : null,
                  child: profileImage == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: incomeController,
                decoration: const InputDecoration(labelText: 'Income'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: expenseController,
                decoration: const InputDecoration(labelText: 'Expenses'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: savingsController,
                decoration: const InputDecoration(labelText: 'Savings Goal'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: debtController,
                decoration: const InputDecoration(labelText: 'Debt'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveData,
                child: const Text('Save Data'),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const Text(
             'Previous Entries: ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
                            const SizedBox(height: 10),
              // Display the saved data in a scrollable ListView
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: savedEntries.length,
                  itemBuilder: (context, index) {
                    final entry = savedEntries[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text('Name: ${entry['name']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Income: \$${entry['income']}'),
                            Text('Expenses: \$${entry['expense']}'),
                            Text('Savings: \$${entry['savings']}'),
                            Text('Debt: \$${entry['debt']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  double income = 0.0;
  double expenses = 0.0;
  double savings = 0.0;
  bool isBarGraph = true;
  String selectedParameter = 'Income vs Expenses';
  Color selectedColor = Colors.blue;
  List<Color> colorOptions = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];

  @override
  void initState() {
    super.initState();
    loadGraphData();
  }

  Future<void> loadGraphData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      income = prefs.getInt('income')?.toDouble() ?? 0;
      expenses = prefs.getInt('expense')?.toDouble() ?? 0;
      savings = prefs.getInt('savings')?.toDouble() ?? 0;
    });
  }

  Widget buildGraph() {
    switch (selectedParameter) {
      case 'Income vs Expenses':
        return isBarGraph ? buildBarGraph([income, expenses]) : buildLineGraph([income, expenses]);
      case 'Savings Over Time':
        return isBarGraph ? buildBarGraph([savings]) : buildLineGraph([savings]);
      default:
        return Container();
    }
  }

  Widget buildBarGraph(List<double> data) {
    return BarChart(
      BarChartData(
        barGroups: data
            .asMap()
            .entries
            .map((entry) => BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: selectedColor,
                      width: 20,
                    ),
                  ],
                ))
            .toList(),
        titlesData: FlTitlesData(show: true),
      ),
    );
  }

  Widget buildLineGraph(List<double> data) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                .toList(),
            isCurved: true,
            color: selectedColor,
            barWidth: 4,
          ),
        ],
        titlesData: FlTitlesData(show: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Graphs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => isBarGraph = true),
                  child: const Text('Bar Graph'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => isBarGraph = false),
                  child: const Text('Line Graph'),
                ),
              ],
            ),
            DropdownButton<String>(
              value: selectedParameter,
              items: ['Income vs Expenses', 'Savings Over Time']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedParameter = newValue!;
                });
              },
            ),
            DropdownButton<Color>(
              value: selectedColor,
              items: colorOptions
                  .map((Color color) => DropdownMenuItem<Color>(
                        value: color,
                        child: Container(
                          width: 100,
                          height: 20,
                          color: color,
                        ),
                      ))
                  .toList(),
              onChanged: (Color? newColor) {
                setState(() {
                  selectedColor = newColor!;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(child: buildGraph()),
          ],
        ),
      ),
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
