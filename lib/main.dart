import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Firebase Authentication'),
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
  late FirebaseAuth auth;
  final String _email = "bfc@gmail.com";
  final String _password = "password";

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;

    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint("User is currently signed out!");
      } else {
        debugPrint("User is signed in ${user.email}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                createUserEmailAndPassword();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text("Email/Password Register"),
            ),
            ElevatedButton(
              onPressed: () {
                loginUserEmailAndPassword();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text("Email/Password Login"),
            ),
            ElevatedButton(
              onPressed: () {
                signOutUser();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text("Sign Out"),
            ),
            ElevatedButton(
              onPressed: () {
                deleteUser();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white),
              child: const Text("Delete User"),
            ),
            ElevatedButton(
              onPressed: () {
                changePassword();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown, foregroundColor: Colors.white),
              child: const Text("Change Password"),
            ),
            ElevatedButton(
              onPressed: () {
                changeEmail();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink, foregroundColor: Colors.white),
              child: const Text("Change Email"),
            ),
            ElevatedButton(
              onPressed: () {
                signUpWithGoogle();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white),
              child: const Text("Sign Up with Google"),
            ),
            ElevatedButton(
              onPressed: () {
                loginWithPhoneNumber();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan, foregroundColor: Colors.white),
              child: const Text("Sign Up with Phone Number"),
            ),
          ],
        ),
      ),
    );
  }

  void loginWithPhoneNumber() async{
  await auth.verifyPhoneNumber(
  phoneNumber: '+905543807109',
  verificationCompleted: (PhoneAuthCredential credential) async{
    debugPrint("Phone Verification Completed!");
    debugPrint(credential.toString());
    await auth.signInWithCredential(credential);
  },
  verificationFailed: (FirebaseAuthException e) {
    debugPrint(e.toString());
  },
  codeSent: (String verificationId, int? resendToken) async{
    String _smsCode = "123456";
    debugPrint("Code Sent!");

    var _credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: _smsCode);

    await auth.signInWithCredential(_credential);
  },
  codeAutoRetrievalTimeout: (String verificationId) {
    debugPrint("Code Auto Retrieval Timeout");
  }
  );}

  void createUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      var _myUser = _userCredential.user;

      if (!_myUser!.emailVerified) {
        await _myUser.sendEmailVerification();
      } else {
        debugPrint("User email is verified!");
      }

      debugPrint(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loginUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      debugPrint(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void signOutUser() async {
    var _user = GoogleSignIn().currentUser;
    if(_user != null) {
      await GoogleSignIn().signOut();
    }
    await auth.signOut();
  }

  void deleteUser() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.delete();
    } else {
      debugPrint("User must be sign in for delete");
    }
  }

  void changePassword() async {
    try {
      await auth.currentUser!.updatePassword("password");
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        debugPrint("User must be sign in before password change");
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.updatePassword("password");
        await auth.signOut();
        debugPrint("Password Updated!");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void changeEmail() async {
    try {
      await auth.currentUser!.verifyBeforeUpdateEmail("berk@gmail.com");
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        debugPrint("User must be sign in before email change");
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.verifyBeforeUpdateEmail("berk@gmail.com");
        await auth.signOut();
        debugPrint("Email Updated!");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void signUpWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
