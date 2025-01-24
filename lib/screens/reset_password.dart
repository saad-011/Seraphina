import 'package:firebase_auth/firebase_auth.dart';
import 'package:seraphina/reuse_widgets/resuse_widgets.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color(0xFF0D2A3C),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Reset Password",
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
                    reusableTextField("Enter Email Address", Icons.email_rounded, false,
                        _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    firebaseUIButton(context, "Reset Password", Icons.lock_reset_rounded, () {
                      FirebaseAuth.instance
                          .sendPasswordResetEmail(email: _emailTextController.text)
                          .then((value) => Navigator.of(context).pop());
                    })
                  ],
                ),
              ))),
    );
  }
}