// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:chatapp/AuthFirebase/login_screen.dart';
import 'package:chatapp/AuthFirebase/register_screen.dart';
import 'package:flutter/material.dart';




class FireBaseAuth extends StatefulWidget {
  const FireBaseAuth({super.key});

  @override
  _FireBaseAuthState createState() => _FireBaseAuthState();

  // void out2(BuildContext context) {
  //   Navigator.pop(context);
  // }
}

class _FireBaseAuthState extends State<FireBaseAuth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/image-medical.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(top: 80.0, left: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HELLO',
                      style:TextStyle(
                          color: Colors.black,
                          fontSize: 50,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Online Doctor Application',
                      style: TextStyle(
                          color: Colors.indigo[800],
                          fontSize: 17,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.black26.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 1.1,
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: double.infinity,
                            height: 50.0,
                            child: ElevatedButton(
                              onPressed: () => _pushPage(context,  const SignIn()),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.indigo[800], backgroundColor: Colors.indigo[800], elevation: 2,
                                shape: RoundedRectangleBorder(
                                  
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                              ),
                              child: const Text(
                                "Sign in",
                                style:TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.1,
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: double.infinity,
                            height: 50.0,
                            child: ElevatedButton(
                              onPressed: () => _pushPage(context,  const Register()),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.white, elevation: 2,
                                shape: RoundedRectangleBorder(
                                  
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                              ),
                              child: const Text(
                                "Create an Account",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Container(
                        //   width: MediaQuery.of(context).size.width / 1.1,
                        //   child: ButtonTheme(
                        //     minWidth: double.infinity,
                        //     height: 50.0,
                        //     child: RaisedButton(
                        //       color: Colors.indigo[800],
                        //       child: Text(
                        //         "Create an account",
                        //         style: GoogleFonts.lato(
                        //           color: Colors.white,
                        //           fontSize: 18.0,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //       onPressed: () => _pushPage(context, Register()),
                        //     ),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: new BorderRadius.circular(25),
                        //     ),
                        //   ),
                        //   padding: const EdgeInsets.all(16),
                        //   alignment: Alignment.center,
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                ],
              ),
            ),
          ),
        ],
      ), //<--
    );
  }

  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}
