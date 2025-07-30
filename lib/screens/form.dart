import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:ValuMate/screens/location.dart';
import 'package:ValuMate/screens/home.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {

  final TextEditingController length = TextEditingController();
  final TextEditingController width = TextEditingController();
   final TextEditingController area = TextEditingController();

  int _getArea(int length, int width){
    return length*width;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx){
            return const LocationScreen();
          }));
        }, icon: const Icon(Icons.arrow_back),
        color: Colors.white,),
        title: const Text('Form Screen', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        backgroundColor: const Color.fromARGB(255, 6, 37, 140),
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  const Text(
                    "Plot dimensions",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'North Dimension',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'South Dimension',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'East Dimension',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Wast Dimension',
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    "Building dimensions",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Length',
                    ),
                    controller: length, 
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Width',
                    ),
                    controller: width,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Area',
                    ),
                    controller: area,

                  ),
                  const SizedBox(height: 20,),

                  ElevatedButton(
                    onPressed: () {
                      int l = int.parse(length.text);
                      int w = int.parse(width.text);
                      area.text = _getArea(l, w).toString();
                    },
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                        side: WidgetStatePropertyAll(
                          BorderSide(color: Colors.black),
                        ),
                        minimumSize: WidgetStatePropertyAll(Size(100, 50)),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                        ),
                    ),
                    
                    child: const Text("Get Area", style: TextStyle(fontSize: 16, color: Colors.black),),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Building Information",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Land Owner Name',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Land Value As Per Client',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Year of Construction',
                    ),
                  ),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (ctx) {
                        return const HomeScreen();
                      }));
                    },
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                        side: WidgetStatePropertyAll(
                          BorderSide(color: Colors.black),
                        ),
                        minimumSize: WidgetStatePropertyAll(Size(100, 50)),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                        ),
                    ),
                    child: const Text('Submit', style: TextStyle(fontSize: 16, color: Colors.black),),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
