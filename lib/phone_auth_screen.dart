import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool _otpSent = false;
  String _statusMessage = "";

  void _verifyPhoneNumber() async {
    setState(() {
      _statusMessage = "Sending OTP...";
    });

    String phoneNumber = "+91${_phoneController.text}"; // Prepend +91

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        setState(() {
          _statusMessage = "Auto-verifying OTP...";
        });
        try {
          await _auth.signInWithCredential(credential);
          // Navigate to HomePage after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(phoneNumber: phoneNumber),
            ),
          );
        } catch (e) {
          setState(() {
            _statusMessage = "Auto-verification failed. Try manual OTP entry.";
          });
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _statusMessage = "Verification failed: ${e.message}";
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
          _statusMessage = "OTP sent to $phoneNumber";
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
          _statusMessage = "OTP auto-retrieval timeout. Please enter OTP manually.";
        });
      },
    );
  }

  void _verifyOTP() async {
    setState(() {
      _statusMessage = "Verifying OTP...";
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
      await _auth.signInWithCredential(credential);
      // Navigate to HomePage after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(phoneNumber: _phoneController.text),
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = "Invalid OTP. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_otpSent) ...[
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Enter phone number (without +91)',
                  prefixText: '+91 ',
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _verifyPhoneNumber,
                child: Text('Send OTP'),
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _verifyOTP,
                child: Text('Verify OTP'),
              ),
            ],
            SizedBox(height: 16),
            Text(
              _statusMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'home_page.dart';

// class PhoneAuthScreen extends StatefulWidget {
//   @override
//   _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
// }

// class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//   String? _verificationId;
//   bool _otpSent = false;
//   String _statusMessage = "";

//   void _verifyPhoneNumber() async {
//     setState(() {
//       _statusMessage = "Sending OTP...";
//     });

//     await _auth.verifyPhoneNumber(
//       phoneNumber: _phoneController.text,
//       timeout: const Duration(seconds: 60),
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         setState(() {
//           _statusMessage = "Auto-verifying OTP...";
//         });
//         try {
//           await _auth.signInWithCredential(credential);
//           // Navigate to HomePage after successful login
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => HomePage(phoneNumber: _phoneController.text),
//             ),
//           );
//         } catch (e) {
//           setState(() {
//             _statusMessage = "Auto-verification failed. Try manual OTP entry.";
//           });
//         }
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         setState(() {
//           _statusMessage = "Verification failed: ${e.message}";
//         });
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         setState(() {
//           _verificationId = verificationId;
//           _otpSent = true;
//           _statusMessage = "OTP sent to ${_phoneController.text}";
//         });
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         setState(() {
//           _verificationId = verificationId;
//           _statusMessage = "OTP auto-retrieval timeout. Please enter OTP manually.";
//         });
//       },
//     );
//   }

//   void _verifyOTP() async {
//     setState(() {
//       _statusMessage = "Verifying OTP...";
//     });

//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId!,
//         smsCode: _otpController.text,
//       );
//       await _auth.signInWithCredential(credential);
//       // Navigate to HomePage after successful login
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomePage(phoneNumber: _phoneController.text),
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         _statusMessage = "Invalid OTP. Please try again.";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Phone Authentication'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (!_otpSent) ...[
//               TextField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'Enter phone number',
//                   prefixText: '+',
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _verifyPhoneNumber,
//                 child: Text('Send OTP'),
//               ),
//             ] else ...[
//               TextField(
//                 controller: _otpController,
//                 decoration: InputDecoration(
//                   labelText: 'Enter OTP',
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _verifyOTP,
//                 child: Text('Verify OTP'),
//               ),
//             ],
//             SizedBox(height: 16),
//             Text(
//               _statusMessage,
//               style: TextStyle(color: Colors.red),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
