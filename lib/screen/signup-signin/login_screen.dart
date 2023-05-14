import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketzone/screen/main/main_screen.dart';
import 'package:ticketzone/screen/signup-signin/forgot_password_screen.dart';
import 'package:ticketzone/screen/signup-signin/google_registration_screen.dart';
import 'package:ticketzone/screen/signup-signin/registration_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../model/ticket.dart';
import '../../model/user.dart';
import '../../service/ticket_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  //form key
  final _formKey = GlobalKey<FormState>();

  //editing controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // firebase
  final _auth = FirebaseAuth.instance;

  final TicketService ticketService = TicketService();

  // string for displaying the error
  String? errorMessage;

  bool isLoggedIn = true;

  late SharedPreferences prefs;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  late AnimationController animationController;

  double angleRotation = 0;
  double scale = 0;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    animationController.forward();
    animationController.addListener(() {
      setState(() {
        angleRotation = animationController.value * 6.25;
        scale = animationController.value;
      });
    });
    autoLogIn();
  }

  Future<void> autoLogIn() async {
    prefs = await SharedPreferences.getInstance();
    String? emailSharedPreferences = prefs.getString("email");
    String? passSharedPreferences = prefs.getString("password");

    if (emailSharedPreferences != null && passSharedPreferences != null) {
      autoSignIn(emailSharedPreferences, passSharedPreferences);
    } else {
      String? accessToken = prefs.getString("googleAuth.accessToken");
      String? idToken = prefs.getString("googleAuth.idToken");

      if (accessToken != null && idToken != null) {
        autoSignInWithGoogle(accessToken, idToken);
      } else {
        isLoggedIn = false;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    //email field
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please enter your email");
        }

        //reg ex for email valid
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please eneter a valid email");
        }

        return null;
      },
      onSaved: (value) {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.mail, color: Colors.white),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        hintStyle: TextStyle(color: Colors.white),
        errorStyle: TextStyle(color: Colors.white),
        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.white)),
      ),
    );

    //password field
    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      controller: passwordController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Password is required for login");
        }

        if (!regex.hasMatch(value)) {
          return ("Enter a valid password (min 6 characters)");
        }

        return null;
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.vpn_key, color: Colors.white),
        hintStyle: TextStyle(color: Colors.white),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Password",
        errorStyle: TextStyle(color: Colors.white),
        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.white)),
      ),
    );

    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.black,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.white)),
        minWidth: MediaQuery.of(context).size.width / 1.5,
        onPressed: () {
          signIn(emailController.text, passwordController.text);
        },
        child: const Text(
          "Login",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // emailController.text = "tirynel@yahoo.com";
    // passwordController.text = "12345678";

    if (isLoggedIn) {
      return Scaffold(
        body: Container(
            color: Colors.black,
            child: const Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            ))),
      );
    }
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: SingleChildScrollView(
          child: Container(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 200,
                      child: Transform.scale(
                        scale: scale,
                        child: Transform.rotate(
                          angle: angleRotation,
                          child: Image.asset(
                            "assets/logo/ticketzone-logo-black.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: const [
                        Text('Welcome Back,',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontFamily: 'Kanit-Regular')),
                        Text('Sign in to your account',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Kanit-Regular',
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                    const SizedBox(height: 45),
                    emailField,
                    const SizedBox(height: 20),
                    passwordField,
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen()));
                          },
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(
                              inherit: true,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 35),
                    loginButton,
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        signInWithGoogle();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            width: width / 7,
                            child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset("assets/google.png")),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistrationScreen()));
                          },
                          child: const Text(
                            "Create",
                            style: TextStyle(
                              inherit: true,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    color: Color(0xFF303d21),
                                    offset: Offset(-1, 1)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )));
  }

  // login function
  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((uid) async => {
                  prefs = await SharedPreferences.getInstance(),
                  prefs.setString("email", email),
                  prefs.setString("password", password),
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Login Successful"),
                    backgroundColor: Colors.green,
                    showCloseIcon: true,
                    closeIconColor: Colors.white,
                  )),
                  await getTickets(uid.user!.uid),
                  //Fluttertoast.showToast(msg: "Login Successful"),
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const MainScreen())),
                });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";

            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }

        // Fluttertoast.showToast(msg: errorMessage!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage!,
            ),
            backgroundColor: Colors.red,
            closeIconColor: Colors.white,
            showCloseIcon: true,
          ),
        );
      }
    }
  }

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      ) as GoogleAuthCredential;

      prefs = await SharedPreferences.getInstance();
      prefs.setString("googleAuth.accessToken", googleAuth.accessToken!);
      prefs.setString("googleAuth.idToken", googleAuth.idToken!);

      // Once signed in, return the UserCredential

      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((value) async {
        User? user = value.user;
        var usersRef =
            await FirebaseFirestore.instance.collection("user").doc(user!.uid);

        usersRef.get().then((value) async {
          if (value.exists) {
            await getTickets(user.uid);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Google Login Successful"),
              backgroundColor: Colors.blue,
              showCloseIcon: true,
              closeIconColor: Colors.white,
            ));
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScreen()));
          } else {
            UserModel userModel = UserModel(
                email: user.email,
                firstname: user.displayName!.split(' ')[0],
                lastname: user.displayName!.split(' ')[1],
                uid: user.uid,
                dob: "");
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) =>
                    GoogleRegistrationScreen(user: userModel)));
          }
        });
      });

      //Fluttertoast.showToast(msg: "Login Successful"),
    } catch (err) {
      throw err;
    }
  }

  Future<void> autoSignInWithGoogle(String accessToken, String idToken) async {
    // Trigger the authentication flow
    try {
      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      ) as GoogleAuthCredential;

      prefs = await SharedPreferences.getInstance();
      prefs.setString("googleAuth.accessToken", accessToken);
      prefs.setString("googleAuth.idToken", idToken);

      try {
        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => getTickets(value.user!.uid));
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-credential":
            errorMessage = error.message;
            prefs = await SharedPreferences.getInstance();

            prefs.remove("googleAuth.accessToken");
            prefs.remove("googleAuth.idToken");
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }

        // Fluttertoast.showToast(msg: errorMessage!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage!,
            ),
            backgroundColor: Colors.red,
            closeIconColor: Colors.white,
            showCloseIcon: true,
          ),
        );
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Google Login Successful"),
        backgroundColor: Colors.blue,
        showCloseIcon: true,
        closeIconColor: Colors.white,
      ));

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()));
    } catch (e) {
      print(e);
    }
  }

// login function
  void autoSignIn(String email, String password) async {
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((uid) async => {
                prefs = await SharedPreferences.getInstance(),
                prefs.setString("email", email),
                prefs.setString("password", password),
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Login Successful"),
                  backgroundColor: Colors.green,
                  showCloseIcon: true,
                  closeIconColor: Colors.white,
                )),
                await getTickets(uid.user!.uid),
                //Fluttertoast.showToast(msg: "Login Successful"),
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const MainScreen())),
              });
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Your email address appears to be malformed.";

          break;
        case "wrong-password":
          errorMessage = "Your password is wrong.";
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          break;
        case "too-many-requests":
          errorMessage = "Too many requests";
          break;
        case "operation-not-allowed":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }

      // Fluttertoast.showToast(msg: errorMessage!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage!,
          ),
          backgroundColor: Colors.red,
          closeIconColor: Colors.white,
          showCloseIcon: true,
        ),
      );
    }
  }

  Future<void> getTickets(String uid) async {
    await FirebaseFirestore.instance
        .collection("ticket")
        .get()
        .then((value) async {
      Ticket ticket;
      for (var element in value.docs) {
        if (element.data().isNotEmpty) {
          ticket = Ticket.fromMap(element.data());

          if (await ticketService.existsTicket(ticket)) {
            ticketService.updateTicket(ticket);
          } else {
            if (uid == ticket.userId) {
              ticketService.saveTicket(ticket);
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
