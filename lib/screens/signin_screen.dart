import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:seraphina/screens/reset_password.dart';
import 'package:seraphina/screens/signup_screen.dart';
import 'package:seraphina/reuse_widgets/resuse_widgets.dart';
import 'package:seraphina/screens/home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xFF80a6eb),
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height*0.15, 20, 0),
              child: Column(
                children: <Widget>[
                  logoWidget("assets/images/logo.png"),
                  const SizedBox(
                    height: 30,
                  ),
                  reusableTextField("Enter Email Address", Icons.email_rounded, false,
                      _emailTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField("Enter Password", Icons.lock_rounded, true,
                      _passwordTextController),
                  const SizedBox(
                    height: 5,
                  ),
                  forgetPassword(context),
                  firebaseUIButton(context, "Sign In", Icons.login, () {
                    FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text).then((value) {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()));
                    }).onError((error, stackTrace) {
                      if (kDebugMode) {
                        print("Error ${error.toString()}");
                      }
                    });
                  }),
                  signUpOption()

                ],
              )
            ),
          ),
        ),
      );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.black)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomLeft,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPassword())),
      ),
    );
  }

}
