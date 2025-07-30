import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ValuMate/screens/form.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable location services")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission permanently denied")),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _latController.text = position.latitude.toString();
        _lonController.text = position.longitude.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: const Icon(Icons.arrow_back),
          color: Colors.white,),
        title: const Text('Location Screen', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        backgroundColor: const Color.fromARGB(255, 6, 37, 140),
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Latitude',
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _lonController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Longitude',
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                      onPressed: _getCurrentLocation,
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
                      child: const Text(
                        'Get Location',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),



                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => const FormScreen()));
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
                    child: const Text('Next', style: TextStyle(fontSize: 16, color: Colors.black),),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

