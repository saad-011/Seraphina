//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:seraphina/reuse_widgets/resuse_widgets.dart';
import 'package:seraphina/screens/home_screen.dart';
import 'package:flutter/material.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color(0xFF0D2A3C),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the color of the back arrow to white
        ),
        title: const Text(
          "Sign Up",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Color(0xFF80a6eb),
          child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
                child: Column(
                  children: <Widget>[
                    logoWidget("assets/images/logo.png"),
                    const SizedBox(
                      height: 30,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter UserName", Icons.person, false,
                        _userNameTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Email Id", Icons.email_rounded, false,
                        _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Password", Icons.lock_rounded, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    firebaseUIButton(context, "Sign Up", Icons.login_rounded, () {
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                          .then((value) {
                        if (kDebugMode) {
                          print("Created New Account");
                        }
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => HomeScreen()));
                      }).onError((error, stackTrace) {
                        if (kDebugMode) {
                          print("Error ${error.toString()}");
                        }
                      });
                    })
                  ],
                ),
              ))),
    );
  }
}