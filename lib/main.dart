import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:sqflite/sqflite.dart';
import 'helper.dart';

void main() {
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});  // Bracket should not close here

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper database = DatabaseHelper();  // Initialize DatabaseHelper instance

    return FutureBuilder(
      future: database.init(),  // Ensure the database is initialized
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/verbose': (context) => const DataEntryScreen(),
              '/visuals': (context) => const GraphScreen(),
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());  
        }
      },
    );
  }  // Closing bracket was added here correctly
}

// Home Screen
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

//Navigation 
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
  //TODO: Add more controllers (?)
  final TextEditingController incControl = TextEditingController();
  final TextEditingController expControl = TextEditingController();
  final TextEditingController savingsControl = TextEditingController();

  @override
  void dispose() {
    incControl.dispose();
    expControl.dispose();
    savingsControl.dispose();
    super.dispose();
  }

Future<void> saveData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  int income = int.parse(incControl.text);
  int expense = int.parse(expControl.text);
  int savingsGoal = int.parse(savingsControl.text);
  
  double incomeSpendingRatio = income / expense;

  
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
              controller: expControl,
              decoration: const InputDecoration(labelText: 'Expenses'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: savingsControl,
              decoration: const InputDecoration(labelText: 'Savings Goal'),
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

class ProgressBarExample extends StatefulWidget {
  @override
  _ProgressBarExampleState createState() => _ProgressBarExampleState();
}

class _ProgressBarExampleState extends State<ProgressBarExample> {
  double progress = 0.0; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int income = prefs.getInt('income') ?? 0;
    int expense = prefs.getInt('expense') ?? 1; 
    int savingsGoal = prefs.getInt('savingsGoal') ?? 100; 

    // Calculate progress towards savings goal
    double incomeSpendingRatio = income / expense;
    double savingsProgress = incomeSpendingRatio / savingsGoal;

    setState(() {
      progress = savingsProgress.clamp(0.0, 1.0); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Savings Progress'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Progress toward your savings goal',
            style: TextStyle(fontSize: 18),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: progress, 
              minHeight: 10.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          Text(
            '${(progress * 100).toStringAsFixed(2)}% of goal reached',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}