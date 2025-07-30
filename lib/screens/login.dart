import 'package:flutter/material.dart';
import 'package:ValuMate/main.dart';
import 'package:ValuMate/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _usernameController = TextEditingController();
  final _passwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                helperText: 'Alphabets,numbers,underscore allowed',
                iconColor: Colors.blue,
                // icon: IconButton(onPressed: (){}, icon: Icon(Icons.check_circle_outline_rounded)),
                border: OutlineInputBorder(),
                hintText: 'Username',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _passwdController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
                onPressed: () {
                  LoginCheck(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('Login'))
          ],
        ),
      )),
    );
  }

  void LoginCheck(BuildContext ctx) async{
    final username = _usernameController.text;
    final passwd = _passwdController.text;
    const String msg = 'Username and password do not match';
    if (username == passwd) {

      final sharedPrefs= await SharedPreferences.getInstance();
      final value= sharedPrefs.setBool(key_value, true);

      Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (ctx1){
        return const HomeScreen();
      }));
    } 
    
    else {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ));

      //Alert Dialog

      showDialog(context: ctx, builder: (ctx1){
        return AlertDialog(title: const Text('Error'),
        content: const Text(msg),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(ctx1).pop();
          }, child: const Text('Close'))
        ],
        
        );
      });


      
    }
  }
}
