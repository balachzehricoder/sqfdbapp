import 'package:flutter/material.dart';
import 'package:sqfdb/Db/Dbhelper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameinput = TextEditingController();
  TextEditingController emailinput = TextEditingController();

  List<Map<String, dynamic>> data = [];

  alldata() async {
    List<Map<String, dynamic>> datalist = await Dbhelper.instance.querydatabase();
    print("Fetched data: $datalist"); // Debug print to check if data is fetched
    setState(() {
      data = datalist;
    });
  }

  @override
  void initState() {
    super.initState();
    alldata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nameinput.clear();
          emailinput.clear();
          custom(0); // for adding a new entry
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("HACKING BAG LIST"),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(data[index]['name'] ?? 'No Name'),
            subtitle: Text(data[index]['email'] ?? 'No Email'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    nameinput.text = data[index]["name"];
                    emailinput.text = data[index]["email"];
                    custom(data[index]["id"]); // for editing an entry
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    Dbhelper.instance.deleterecord(data[index]["id"]);
                    alldata(); // Refresh data after deletion
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Custom widget to display a dialog for adding/editing entries
  void custom(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == 0 ? 'Add Entry' : 'Edit Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameinput,
                decoration: const InputDecoration(labelText: 'name'),
              ),
              TextField(
                controller: emailinput,
                decoration: const InputDecoration(labelText: 'other things'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (id == 0) {
                  Dbhelper.instance.insertRecord({
                    'name': nameinput.text,
                    'email': emailinput.text,
                  }).then((_) => alldata()); // Refresh data after insertion
                } else {
                  Dbhelper.instance.updaterecord({
                    'id': id,
                    'name': nameinput.text,
                    'email': emailinput.text,
                  }).then((_) => alldata()); // Refresh data after update
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
