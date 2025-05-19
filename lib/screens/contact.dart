import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'footer.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _screenNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Loads the current user's details from Firestore (from the "users" collection).
  Future<void> _loadUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _screenNameController.text = data['screenName'] ?? "";
          _emailController.text = data['email'] ?? "";
          _phoneController.text = data['phone'] ?? "";
        });
      }
    }
  }

  // Submit the inquiry to Firestore collection "inquiries".
  Future<void> _submitInquiry() async {
    if (_formKey.currentState!.validate()) {
      // Build inquiry document data.
      Map<String, dynamic> inquiryData = {
        'screenName': _screenNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'issue': _issueController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('inquiries')
            .add(inquiryData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your inquiry has been submitted.")),
        );

        // Optionally clear the issue field (the personal details remain pre-filled).
        _issueController.clear();

        // Navigate to the home page after a brief delay.
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/home');
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission failed: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _screenNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.15;
    return Scaffold(
      appBar: AppBar(title: const Text("Contact"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Full-width header with maroon background and logo.
              Container(
                width: MediaQuery.of(context).size.width,
                height: headerHeight,
                color: Colors.brown, // Maroon color
                child: Center(
                  child: Image.asset("assets/kagtransparent.png"),
                ),
              ),
              const SizedBox(height: 16),
              // Form for submitting an inquiry.
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          "Contact Us",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 31),
                      // Screen Name
                      TextFormField(
                        controller: _screenNameController,
                        decoration: const InputDecoration(
                          labelText: "Screen Name",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your screen name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 31),
                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 31),
                      // Phone Number
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your phone number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 31),
                      // Describe your issue (multiline)
                      TextFormField(
                        controller: _issueController,
                        decoration: const InputDecoration(
                          labelText: "Please describe your issue",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please describe your issue";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      // Submit Inquiry Button
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF800000), // Maroon background
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            onPressed: _submitInquiry,
                            child: const Text(
                              "Submit Inquiry",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Footer(currentIndex: 4),
    );
  }
}