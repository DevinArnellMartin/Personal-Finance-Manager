import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'helper.dart';
import 'package:fl_chart/fl_chart.dart';

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
        child: Text('Here is the tutorial how to use it '),
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

// Graph Screen
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
              child: Text('Graph will be here (select X and Y axes)'),
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

// Other classes (like FiPie, CustomFiPie) remain unchanged
