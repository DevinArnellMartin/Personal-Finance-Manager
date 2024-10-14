import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

void main() {
  runApp(FinanceApp());
}

class FinanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      routes: {
        '/verbose': (context) => DataEntryScreen(), //data entry and verbose route
        '/visuals': (context) => GraphScreen(), //graphs routes
      },
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Finance Manager'),
      ),
      body: Center(
        child: Text('Here is the tutorial how to use it '),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

//Navigation 
class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
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
  @override
  _DataEntryScreenState createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  //TODO: Add more (?)
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
    await prefs.setString('income', incControl.text);
    await prefs.setString('expense', expControl.text);
    await prefs.setString('savingsGoal', savingsControl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Financial Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: incControl,
              decoration: InputDecoration(labelText: 'Income'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: expControl,
              decoration: InputDecoration(labelText: 'Expenses'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: savingsControl,
              decoration: InputDecoration(labelText: 'Savings Goal'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveData();
              },
              child: Text('Save Data'),
            ),
          ],
        ),
      ),
    );
  }
}

// Graph Screen
class GraphScreen extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  double progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Graph and Progress')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text('Graph will be here (select X and Y axes)'),
            ),
          ),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                progress += 0.1;
                if (progress > 1) progress = 1;
              });
            },
            child: Text('Update Progress'),
          ),
        ],
      ),
    );
  }
}
